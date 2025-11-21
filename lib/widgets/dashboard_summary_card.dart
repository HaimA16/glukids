import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import '../models/glucose_reading.dart';
import '../repositories/glucose_repository.dart';
import '../repositories/firebase_glucose_repository.dart';
import 'package:intl/intl.dart';

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return FirebaseGlucoseRepository();
});

final lastReadingProvider = StreamProvider.family<GlucoseReading?, String>(
  (ref, childId) async* {
    final repository = ref.watch(glucoseRepositoryProvider);
    await for (final readings in repository.watchReadingsForChildInLastHours(childId, 24)) {
      if (readings.isNotEmpty) {
        yield readings.first; // Most recent reading
      } else {
        yield null;
      }
    }
  },
);

class DashboardSummaryCard extends ConsumerWidget {
  final ChildModel child;

  const DashboardSummaryCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadingAsync = ref.watch(lastReadingProvider(child.id));

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 24,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'כיתה ${child.grade}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: lastReadingAsync.when(
                data: (lastReading) {
                if (lastReading == null) {
                  return Container(
                    key: const ValueKey('no-reading'),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'אין מדידות ב-24 שעות האחרונות',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final statusColor = lastReading.isLow
                    ? Colors.red
                    : lastReading.isHigh
                        ? Colors.orange
                        : const Color(0xFF4CAF50);

                final statusText = lastReading.isLow
                    ? 'היפו'
                    : lastReading.isHigh
                        ? 'היפר'
                        : 'בטווח';

                final statusIcon = lastReading.isLow
                    ? Icons.arrow_downward_rounded
                    : lastReading.isHigh
                        ? Icons.arrow_upward_rounded
                        : Icons.check_circle_rounded;

                final timeFormat = DateFormat('HH:mm');
                final dateFormat = DateFormat('dd/MM/yyyy');
                final isToday = DateTime.now().difference(lastReading.measuredAt).inDays == 0;
                final timeText = isToday
                    ? 'היום ${timeFormat.format(lastReading.measuredAt)}'
                    : '${dateFormat.format(lastReading.measuredAt)} ${timeFormat.format(lastReading.measuredAt)}';

                return Container(
                  key: ValueKey('reading-${lastReading.id}-${lastReading.value}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${lastReading.value} mg/dL',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  ),
                );
              },
              loading: () => Container(
                key: const ValueKey('loading'),
                child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'טוען...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                ),
              ),
              error: (error, stack) => Container(
                key: ValueKey('error-${error.hashCode}'),
                child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'שגיאה בטעינת נתונים',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

