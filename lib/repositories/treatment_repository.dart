import '../models/treatment.dart';

abstract class TreatmentRepository {
  Stream<List<Treatment>> watchTreatmentsForChildOnDay(
    String childId,
    DateTime day,
  );
  Future<void> addTreatment(Treatment treatment);
}

