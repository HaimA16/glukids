import 'package:cloud_firestore/cloud_firestore.dart';

class GlucoseReading {
  final String id;
  final String childId;
  final DateTime measuredAt;
  final double value;
  final String context; // "before_meal" | "after_meal" | "other"
  final String? note;
  final bool isLow;
  final bool isHigh;

  GlucoseReading({
    required this.id,
    required this.childId,
    required this.measuredAt,
    required this.value,
    required this.context,
    this.note,
    required this.isLow,
    required this.isHigh,
  });

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'measuredAt': Timestamp.fromDate(measuredAt),
      'value': value,
      'context': context,
      'note': note,
      'isLow': isLow,
      'isHigh': isHigh,
    };
  }

  factory GlucoseReading.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return GlucoseReading(
      id: doc.id,
      childId: data['childId'] as String,
      measuredAt: (data['measuredAt'] as Timestamp).toDate(),
      value: (data['value'] as num).toDouble(),
      context: data['context'] as String,
      note: data['note'] as String?,
      isLow: data['isLow'] as bool,
      isHigh: data['isHigh'] as bool,
    );
  }
}

