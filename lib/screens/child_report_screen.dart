import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import '../models/glucose_reading.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../repositories/glucose_repository.dart';
import '../repositories/firebase_glucose_repository.dart';
import 'package:intl/intl.dart';

final childRepositoryForReportProvider = Provider<ChildRepository>((ref) {
  return FirebaseChildRepository();
});

final childForReportProvider = FutureProvider.family<ChildModel, String>((ref, childId) async {
  final repository = ref.watch(childRepositoryForReportProvider);
  return repository.getChildById(childId);
});

final glucoseRepositoryForReportProvider = Provider<GlucoseRepository>((ref) {
  return FirebaseGlucoseRepository();
});

final readingsInRangeProvider = StreamProvider.family<List<GlucoseReading>, Map<String, dynamic>>(
  (ref, params) {
    final childId = params['childId'] as String;
    final from = params['from'] as DateTime;
    final to = params['to'] as DateTime;
    final repository = ref.watch(glucoseRepositoryForReportProvider);
    return repository.watchReadingsForChildInRange(childId, from, to);
  },
);

class ChildReportScreen extends ConsumerStatefulWidget {
  final String childId;

  const ChildReportScreen({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<ChildReportScreen> createState() => _ChildReportScreenState();
}

class _ChildReportScreenState extends ConsumerState<ChildReportScreen> {
  int _selectedTimeframe = 7; // 7, 14, or 30 days

  Map<String, DateTime> _getTimeframeDates(int days) {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: days));
    return {'from': from, 'to': to};
  }

  Map<String, dynamic> _calculateStats(
    List<GlucoseReading> readings,
    double hypoThreshold,
    double hyperThreshold,
  ) {
    if (readings.isEmpty) {
      return {
        'total': 0,
        'average': 0.0,
        'hypoCount': 0,
        'hyperCount': 0,
        'normalCount': 0,
        'timeInRange': 0.0,
      };
    }

    final total = readings.length;
    final sum = readings.fold<double>(0.0, (sum, reading) => sum + reading.value);
    final average = sum / total;

    final hypoCount = readings.where((r) => r.value < hypoThreshold).length;
    final hyperCount = readings.where((r) => r.value > hyperThreshold).length;
    final normalCount = readings.where((r) =>
        r.value >= hypoThreshold && r.value <= hyperThreshold).length;
    final timeInRange = (normalCount / total) * 100;

    return {
      'total': total,
      'average': average,
      'hypoCount': hypoCount,
      'hyperCount': hyperCount,
      'normalCount': normalCount,
      'timeInRange': timeInRange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childForReportProvider(widget.childId));
    final dates = _getTimeframeDates(_selectedTimeframe);
    final readingsAsync = ref.watch(readingsInRangeProvider({
      'childId': widget.childId,
      'from': dates['from']!,
      'to': dates['to']!,
    }));

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'דוח מדדים',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: childAsync.when(
          data: (child) {
            return Column(
              children: [
                // Timeframe Selector
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTimeframeButton(7, '7 ימים'),
                      ),
                      Expanded(
                        child: _buildTimeframeButton(14, '14 ימים'),
                      ),
                      Expanded(
                        child: _buildTimeframeButton(30, '30 ימים'),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: readingsAsync.when(
                    data: (readings) {
                      final stats = _calculateStats(
                        readings,
                        child.glucoseMin,
                        child.glucoseMax,
                      );

                      if (readings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'אין מדידות בטווח הזמן שנבחר',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats Cards
                            _buildStatCard(
                              'סה"כ מדידות',
                              stats['total'].toString(),
                              Icons.monitor_heart_rounded,
                              Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'ממוצע',
                                    stats['average'].toStringAsFixed(1),
                                    Icons.trending_flat_rounded,
                                    Colors.purple,
                                    unit: ' mg/dL',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'זמן בטווח',
                                    stats['timeInRange'].toStringAsFixed(1),
                                    Icons.check_circle_rounded,
                                    const Color(0xFF4CAF50),
                                    unit: '%',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'היפו',
                                    stats['hypoCount'].toString(),
                                    Icons.arrow_downward_rounded,
                                    Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'היפר',
                                    stats['hyperCount'].toString(),
                                    Icons.arrow_upward_rounded,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Recent Readings List
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
                                          Icons.history_rounded,
                                          color: const Color(0xFF2196F3),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'מדידות אחרונות',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...readings.take(10).map((reading) {
                                      final color = reading.isLow
                                          ? Colors.red
                                          : reading.isHigh
                                              ? Colors.orange
                                              : const Color(0xFF4CAF50);
                                      final dateFormat = DateFormat('dd/MM HH:mm');
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                '${reading.value} mg/dL',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              dateFormat.format(reading.measuredAt),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                              'שגיאה בטעינת נתונים',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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

  Widget _buildTimeframeButton(int days, String label) {
    final isSelected = _selectedTimeframe == days;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimeframe = days;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    String unit = '',
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$value$unit',
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
      ),
    );
  }
}

