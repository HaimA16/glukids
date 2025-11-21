import 'package:flutter_test/flutter_test.dart';
import 'package:glukids/services/insulin_calculator_service.dart';

void main() {
  group('InsulinCalculatorService', () {
    test('calculates normal bolus correctly', () {
      final result = InsulinCalculatorService.calculateBolus(
        currentGlucose: 120.0,
        carbs: 50.0,
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 80.0,
        targetMax: 150.0,
      );

      // Carb bolus: (50 / 10) * 2.0 = 10.0 units
      expect(result.carbBolus, closeTo(10.0, 0.01));
      // No correction needed (120 is within target range 80-150)
      expect(result.correctionBolus, isNull);
      expect(result.totalBolus, closeTo(10.0, 0.01));
      expect(result.roundedBolus, 10.0);
    });

    test('includes correction bolus for hyperglycemia', () {
      final result = InsulinCalculatorService.calculateBolus(
        currentGlucose: 200.0, // Above target max (150)
        carbs: 30.0,
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 80.0,
        targetMax: 150.0,
      );

      // Carb bolus: (30 / 10) * 2.0 = 6.0 units
      expect(result.carbBolus, closeTo(6.0, 0.01));
      // Correction bolus: (200 - 115) / 50 = 85 / 50 = 1.7 units
      // Target midpoint: (80 + 150) / 2 = 115
      expect(result.correctionBolus, isNotNull);
      expect(result.correctionBolus!, closeTo(1.7, 0.1));
      expect(result.totalBolus, closeTo(7.7, 0.1));
      expect(result.roundedBolus, 7.5); // Rounded to nearest 0.5
    });

    test('no correction bolus for hypo', () {
      final result = InsulinCalculatorService.calculateBolus(
        currentGlucose: 70.0, // Below target min (80)
        carbs: 40.0,
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 80.0,
        targetMax: 150.0,
      );

      // Carb bolus: (40 / 10) * 2.0 = 8.0 units
      expect(result.carbBolus, closeTo(8.0, 0.01));
      // No correction (below target range)
      expect(result.correctionBolus, isNull);
      expect(result.totalBolus, closeTo(8.0, 0.01));
    });

    test('rounds bolus to nearest 0.5 units', () {
      final result = InsulinCalculatorService.calculateBolus(
        currentGlucose: 120.0,
        carbs: 45.0, // Will give 9.0 units
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 80.0,
        targetMax: 150.0,
      );

      // Carb bolus: (45 / 10) * 2.0 = 9.0 units
      expect(result.roundedBolus, 9.0);

      // Test rounding: 7.3 should round to 7.5, 7.2 should round to 7.0
      final result2 = InsulinCalculatorService.calculateBolus(
        currentGlucose: 120.0,
        carbs: 36.5,
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 80.0,
        targetMax: 150.0,
      );

      expect(result2.roundedBolus, 7.5);
    });

    test('generates explanation text', () {
      final result = InsulinCalculatorService.calculateBolus(
        currentGlucose: 200.0,
        carbs: 50.0,
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 80.0,
        targetMax: 150.0,
      );

      expect(result.explanation, isNotEmpty);
      expect(result.explanation, contains('בולוס פחמימות'));
      expect(result.explanation, contains('בולוס תיקון'));
      expect(result.explanation, contains('סה"כ'));
      expect(result.explanation, contains('מעוגל'));
    });
  });
}

