import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../models/child.dart';
import '../widgets/primary_button.dart';
import '../widgets/glucose_stats_card.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return FirebaseChildRepository();
});

final childByIdProvider = FutureProvider.family<ChildModel, String>((ref, id) async {
  final repository = ref.watch(childRepositoryProvider);
  return repository.getChildById(id);
});

class ChildDetailScreen extends ConsumerWidget {
  final String childId;

  const ChildDetailScreen({
    super.key,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childByIdProvider(childId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'פרטי ילד',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: childAsync.when(
          data: (child) {
            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                GlucoseStatsCard(
                  childId: childId,
                  hypoThreshold: child.glucoseMin,
                  hyperThreshold: child.glucoseMax,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.child_care_rounded,
                                size: 28,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'כיתה ${child.grade}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoRow(
                          context,
                          Icons.phone_rounded,
                          'טלפון הורה',
                          child.parentPhone,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Icons.favorite_rounded,
                          'טווח סוכר',
                          '${child.glucoseMin} - ${child.glucoseMax}',
                          iconColor: const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medical_information_rounded,
                              color: const Color(0xFF2196F3),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'הוראות לטיפול',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            child.instructions,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'מדידת סוכר חדשה',
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/add-reading',
                      arguments: {'childId': childId},
                    );
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'טיפול / אינסולין חדש',
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/add-treatment',
                      arguments: {'childId': childId},
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/insulin-calculator',
                      arguments: {'childId': childId},
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calculate_rounded, color: Color(0xFF4CAF50)),
                  label: const Text(
                    'מחשבון אינסולין',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/daily-log',
                      arguments: {'childId': childId},
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'יומן יומי',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? iconColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

