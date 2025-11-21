import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';
import 'package:intl/intl.dart';

class ReadingTile extends StatelessWidget {
  final GlucoseReading reading;

  const ReadingTile({
    super.key,
    required this.reading,
  });

  String _getContextLabel(String context) {
    switch (context) {
      case 'before_meal':
        return 'לפני אוכל';
      case 'after_meal':
        return 'אחרי אוכל';
      default:
        return 'אחר';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final color = reading.isLow
        ? Colors.red
        : reading.isHigh
            ? Colors.orange
            : const Color(0xFF4CAF50);

    return Card(
      elevation: reading.isLow || reading.isHigh ? 3 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: reading.isLow || reading.isHigh
              ? color.withOpacity(0.5)
              : Colors.transparent,
          width: reading.isLow || reading.isHigh ? 2 : 0,
        ),
      ),
      color: reading.isLow || reading.isHigh
          ? color.withOpacity(0.08)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                reading.isLow
                    ? Icons.arrow_downward_rounded
                    : reading.isHigh
                        ? Icons.arrow_upward_rounded
                        : Icons.check_circle_rounded,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${reading.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'mg/dL',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (reading.isLow || reading.isHigh)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reading.isLow ? 'נמוך' : 'גבוה',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${timeFormat.format(reading.measuredAt)} - ${_getContextLabel(reading.context)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (reading.note != null && reading.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reading.note!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  if (reading.isLow || reading.isHigh) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reading.isLow
                                  ? 'מדד נמוך. יש לפעול בהתאם להנחיות הצוות הרפואי.'
                                  : 'מדד גבוה. יש לפעול בהתאם להנחיות הצוות הרפואי.',
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

