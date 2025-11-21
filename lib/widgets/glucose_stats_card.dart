import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/glucose_reading.dart';
import '../repositories/glucose_repository.dart';
import '../repositories/firebase_glucose_repository.dart';

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return FirebaseGlucoseRepository();
});

final readingsLast24hProvider =
    StreamProvider.family<List<GlucoseReading>, String>(
  (ref, childId) {
    final repository = ref.watch(glucoseRepositoryProvider);
    return repository.watchReadingsForChildInLastHours(childId, 24);
  },
);

class GlucoseStatsCard extends ConsumerWidget {
  final String childId;
  final double hypoThreshold;
  final double hyperThreshold;

  const GlucoseStatsCard({
    super.key,
    required this.childId,
    required this.hypoThreshold,
    required this.hyperThreshold,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsAsync = ref.watch(readingsLast24hProvider(childId));

    return readingsAsync.when(
      data: (readings) {
        final lowCount = readings.where((r) => r.value < hypoThreshold).length;
        final highCount = readings.where((r) => r.value > hyperThreshold).length;
        final normalCount = readings.where((r) =>
            r.value >= hypoThreshold && r.value <= hyperThreshold).length;
        final totalCount = readings.length;

        if (totalCount == 0) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'אין מדידות ב-24 שעות האחרונות',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
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
                      Icons.analytics_rounded,
                      color: const Color(0xFF2196F3),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'סטטיסטיקה - 24 שעות אחרונות',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'מספר המדידות ב-24 השעות האחרונות',
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'סה"כ מדידות',
                        totalCount.toString(),
                        Icons.monitor_heart_rounded,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'נמוכות',
                        lowCount.toString(),
                        Icons.arrow_downward_rounded,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'גבוהות',
                        highCount.toString(),
                        Icons.arrow_upward_rounded,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        'בטווח',
                        normalCount.toString(),
                        Icons.check_circle_rounded,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade300,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'שגיאה בטעינת נתונים',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

