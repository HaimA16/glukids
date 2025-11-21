import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../models/child.dart';
import '../widgets/child_card.dart';
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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (context.mounted) {
        // Navigate to welcome screen after logout
        // The auth state changes will ensure WelcomeScreen is shown
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, 'יציאה נכשלה: ${e.toString()}');
      }
    }
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
              icon: const Icon(Icons.logout_rounded),
              color: Colors.grey.shade700,
              onPressed: () => _handleLogout(context, ref),
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
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return ChildCard(
                  child: child,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/child',
                      arguments: {'childId': child.id},
                    );
                  },
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

