import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/glucose_reading.dart';
import 'glucose_repository.dart';

class FirebaseGlucoseRepository implements GlucoseRepository {
  final FirebaseFirestore _firestore;

  FirebaseGlucoseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<GlucoseReading>> watchReadingsForChildOnDay(
    String childId,
    DateTime day,
  ) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('glucose_readings')
        .where('childId', isEqualTo: childId)
        .where('measuredAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('measuredAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('measuredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlucoseReading.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<GlucoseReading>> watchReadingsForChildInLastHours(
    String childId,
    int hours,
  ) {
    final cutoffTime = DateTime.now().subtract(Duration(hours: hours));

    return _firestore
        .collection('glucose_readings')
        .where('childId', isEqualTo: childId)
        .where('measuredAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffTime))
        .orderBy('measuredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlucoseReading.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<GlucoseReading>> watchReadingsForChildInRange(
    String childId,
    DateTime from,
    DateTime to,
  ) {
    return _firestore
        .collection('glucose_readings')
        .where('childId', isEqualTo: childId)
        .where('measuredAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('measuredAt', isLessThan: Timestamp.fromDate(to))
        .orderBy('measuredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlucoseReading.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> addReading(GlucoseReading reading) async {
    await _firestore
        .collection('glucose_readings')
        .doc(reading.id)
        .set(reading.toMap());
  }
}

