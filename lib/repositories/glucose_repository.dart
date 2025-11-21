import '../models/glucose_reading.dart';

abstract class GlucoseRepository {
  Stream<List<GlucoseReading>> watchReadingsForChildOnDay(
    String childId,
    DateTime day,
  );
  Stream<List<GlucoseReading>> watchReadingsForChildInLastHours(
    String childId,
    int hours,
  );
  Stream<List<GlucoseReading>> watchReadingsForChildInRange(
    String childId,
    DateTime from,
    DateTime to,
  );
  Future<void> addReading(GlucoseReading reading);
}

