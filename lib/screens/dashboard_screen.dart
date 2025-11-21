import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../models/child.dart';
import '../widgets/child_card.dart';
import '../widgets/dashboard_summary_card.dart';
import '../core/snackbar_helper.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return FirebaseChildRepository();
});

final childrenStreamProvider = StreamProvider.family<List<ChildModel>, String>(
  (ref, assistantUid) {
    final repository = ref.watch(childRepositoryProvider);
    return repository.watchChildrenForAssistant(assistantUid);
  },
);

// Animated card widget with micro-interactions
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: widget.child,
        ),
      ),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _handleLogout(BuildContext context) {
    // Navigate to logout confirmation screen
    Navigator.of(context).pushNamed('/logout');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('התחבר'),
            ),
          ),
        ),
      );
    }

    final childrenAsync = ref.watch(childrenStreamProvider(currentUser.uid));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'התלמידים שלי',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_rounded),
              color: Colors.grey.shade700,
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
              },
              tooltip: 'פרופיל',
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              color: Colors.grey.shade700,
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              tooltip: 'הגדרות',
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              color: Colors.grey.shade700,
              onPressed: () => _handleLogout(context),
              tooltip: 'יציאה',
            ),
          ],
        ),
        body: childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.child_care_rounded,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'אין עדיין ילדים משויכים',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'הוסף ילד חדש כדי להתחיל',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Show children - use summary cards which are tappable with animations
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _AnimatedCard(
                      child: DashboardSummaryCard(child: child),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/child',
                          arguments: {'childId': child.id},
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'שגיאה: ${error.toString()}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return FloatingActionButton.extended(
                heroTag: 'add_child',
                onPressed: () {
                  Navigator.of(context).pushNamed('/add-child');
                },
                backgroundColor: const Color(0xFF2196F3),
                elevation: 4,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'הוספת ילד',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'calculator',
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/insulin-calculator',
                      arguments: {'childId': children.first.id},
                    );
                  },
                  backgroundColor: const Color(0xFF4CAF50),
                  elevation: 4,
                  tooltip: 'מחשבון אינסולין',
                  child: const Icon(Icons.calculate_rounded),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'add_child',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/add-child');
                  },
                  backgroundColor: const Color(0xFF2196F3),
                  elevation: 4,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'הוספת ילד',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => FloatingActionButton.extended(
            heroTag: 'add_child',
            onPressed: () {
              Navigator.of(context).pushNamed('/add-child');
            },
            backgroundColor: const Color(0xFF2196F3),
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'הוספת ילד',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          error: (error, stack) => FloatingActionButton.extended(
            heroTag: 'add_child',
            onPressed: () {
              Navigator.of(context).pushNamed('/add-child');
            },
            backgroundColor: const Color(0xFF2196F3),
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'הוספת ילד',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

