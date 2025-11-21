import 'package:cloud_firestore/cloud_firestore.dart';

class Treatment {
  final String id;
  final String childId;
  final DateTime givenAt;
  final String type; // "insulin_injection" | "pump_bolus" | "other"
  final double? units;
  final String? note;

  Treatment({
    required this.id,
    required this.childId,
    required this.givenAt,
    required this.type,
    this.units,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'givenAt': Timestamp.fromDate(givenAt),
      'type': type,
      'units': units,
      'note': note,
    };
  }

  factory Treatment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Treatment(
      id: doc.id,
      childId: data['childId'] as String,
      givenAt: (data['givenAt'] as Timestamp).toDate(),
      type: data['type'] as String,
      units: data['units'] != null ? (data['units'] as num).toDouble() : null,
      note: data['note'] as String?,
    );
  }
}

