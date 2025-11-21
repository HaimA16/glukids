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
  Future<void> addReading(GlucoseReading reading);
}

