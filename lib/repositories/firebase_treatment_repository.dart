import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/treatment.dart';
import 'treatment_repository.dart';

class FirebaseTreatmentRepository implements TreatmentRepository {
  final FirebaseFirestore _firestore;

  FirebaseTreatmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Treatment>> watchTreatmentsForChildOnDay(
    String childId,
    DateTime day,
  ) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('treatments')
        .where('childId', isEqualTo: childId)
        .where('givenAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('givenAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('givenAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Treatment.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> addTreatment(Treatment treatment) async {
    await _firestore
        .collection('treatments')
        .doc(treatment.id)
        .set(treatment.toMap());
  }
}

