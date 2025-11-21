import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/glucose_reading.dart';
import '../models/treatment.dart';
import '../repositories/glucose_repository.dart';
import '../repositories/firebase_glucose_repository.dart';
import '../repositories/treatment_repository.dart';
import '../repositories/firebase_treatment_repository.dart';
import '../widgets/reading_tile.dart';
import '../widgets/treatment_tile.dart';

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return FirebaseGlucoseRepository();
});

final treatmentRepositoryProvider = Provider<TreatmentRepository>((ref) {
  return FirebaseTreatmentRepository();
});

final readingsForDayProvider =
    StreamProvider.family<List<GlucoseReading>, Map<String, dynamic>>(
  (ref, params) {
    final repository = ref.watch(glucoseRepositoryProvider);
    final childId = params['childId'] as String;
    final day = params['day'] as DateTime;
    return repository.watchReadingsForChildOnDay(childId, day);
  },
);

final treatmentsForDayProvider =
    StreamProvider.family<List<Treatment>, Map<String, dynamic>>(
  (ref, params) {
    final repository = ref.watch(treatmentRepositoryProvider);
    final childId = params['childId'] as String;
    final day = params['day'] as DateTime;
    return repository.watchTreatmentsForChildOnDay(childId, day);
  },
);

class _LogItem {
  final DateTime timestamp;
  final bool isReading;
  final GlucoseReading? reading;
  final Treatment? treatment;

  _LogItem({
    required this.timestamp,
    required this.isReading,
    this.reading,
    this.treatment,
  });
}

class DailyLogScreen extends ConsumerStatefulWidget {
  final String childId;

  const DailyLogScreen({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    // Normalize to date only (ignore time)
    _selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDay = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _changeDay(int days) {
    setState(() {
      _selectedDay = _selectedDay.add(Duration(days: days));
    });
  }

  List<_LogItem> _mergeAndSortLogs(
    List<GlucoseReading> readings,
    List<Treatment> treatments,
  ) {
    final items = <_LogItem>[];

    for (final reading in readings) {
      items.add(_LogItem(
        timestamp: reading.measuredAt,
        isReading: true,
        reading: reading,
      ));
    }

    for (final treatment in treatments) {
      items.add(_LogItem(
        timestamp: treatment.givenAt,
        isReading: false,
        treatment: treatment,
      ));
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final readingsParams = {'childId': widget.childId, 'day': _selectedDay};
    final treatmentsParams = {'childId': widget.childId, 'day': _selectedDay};

    final readingsAsync = ref.watch(readingsForDayProvider(readingsParams));
    final treatmentsAsync = ref.watch(treatmentsForDayProvider(treatmentsParams));

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'יומן יומי',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => _changeDay(1),
                      tooltip: 'יום הבא',
                      color: const Color(0xFF2196F3),
                      iconSize: 28,
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: const Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(_selectedDay),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => _changeDay(-1),
                      tooltip: 'יום קודם',
                      color: const Color(0xFF2196F3),
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: readingsAsync.when(
                data: (readings) {
                  return treatmentsAsync.when(
                    data: (treatments) {
                      final mergedItems = _mergeAndSortLogs(readings, treatments);

                      if (mergedItems.isEmpty) {
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
                                  Icons.event_note_rounded,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'אין פריטים לתאריך זה',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: mergedItems.length,
                        itemBuilder: (context, index) {
                          final item = mergedItems[index];
                          if (item.isReading && item.reading != null) {
                            return ReadingTile(reading: item.reading!);
                          } else if (!item.isReading && item.treatment != null) {
                            return TreatmentTile(treatment: item.treatment!);
                          }
                          return const SizedBox.shrink();
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
                              'שגיאה בטיפולים: ${error.toString()}',
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
                          'שגיאה במדידות: ${error.toString()}',
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
          ],
        ),
      ),
    );
  }
}

