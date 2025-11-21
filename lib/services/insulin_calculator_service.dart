/// Insulin Calculator Service
/// 
/// Calculates bolus insulin dose based on:
/// - Current blood glucose
/// - Planned carbohydrate intake
/// - Child-specific insulin parameters (ICR, correction factor, target range)
/// 
/// IMPORTANT: This is a decision-support tool only.
/// All calculations must be verified with medical professionals.

class InsulinCalculationResult {
  final double carbBolus;
  final double? correctionBolus;
  final double totalBolus;
  final double roundedBolus;
  final String explanation;

  InsulinCalculationResult({
    required this.carbBolus,
    this.correctionBolus,
    required this.totalBolus,
    required this.roundedBolus,
    required this.explanation,
  });
}

class InsulinCalculatorService {
  /// Calculate bolus insulin dose
  /// 
  /// [currentGlucose] - Current blood glucose in mg/dL
  /// [carbs] - Planned carbohydrate intake in grams
  /// [insulinToCarbRatio] - Units of insulin per 10g carbs (e.g., 2.0 = 2 units per 10g)
  /// [correctionFactor] - mg/dL lowered per unit (e.g., 50 = 1 unit lowers by 50 mg/dL)
  /// [targetMin] - Target range minimum in mg/dL
  /// [targetMax] - Target range maximum in mg/dL
  static InsulinCalculationResult calculateBolus({
    required double currentGlucose,
    required double carbs,
    required double insulinToCarbRatio,
    required double correctionFactor,
    required double targetMin,
    required double targetMax,
  }) {
    // Carb bolus calculation
    // Convert ratio to units per gram: if ICR is units per 10g, divide by 10
    final carbBolus = (carbs / 10.0) * insulinToCarbRatio;

    // Correction bolus calculation (only if above target)
    double? correctionBolus;
    final targetMidpoint = (targetMin + targetMax) / 2.0;
    
    if (currentGlucose > targetMax) {
      final glucoseExcess = currentGlucose - targetMidpoint;
      correctionBolus = glucoseExcess / correctionFactor;
      // Don't allow negative correction
      if (correctionBolus! < 0) {
        correctionBolus = 0;
      }
    }

    // Total bolus
    final totalBolus = carbBolus + (correctionBolus ?? 0.0);

    // Round to nearest 0.5 units
    final roundedBolus = (totalBolus * 2).round() / 2.0;

    // Build explanation
    final buffer = StringBuffer();
    buffer.writeln('חישוב בולוס אינסולין:');
    buffer.writeln('');
    buffer.writeln('בולוס פחמימות: ${carbs}g ÷ 10 × ${insulinToCarbRatio} = ${carbBolus.toStringAsFixed(2)} יחידות');
    
    if (correctionBolus != null && correctionBolus > 0) {
      buffer.writeln('בולוס תיקון: (${currentGlucose} - ${targetMidpoint.toStringAsFixed(0)}) ÷ ${correctionFactor} = ${correctionBolus.toStringAsFixed(2)} יחידות');
    } else {
      buffer.writeln('בולוס תיקון: לא נדרש (ערך סוכר בטווח)');
    }
    
    buffer.writeln('סה"כ: ${totalBolus.toStringAsFixed(2)} יחידות');
    buffer.writeln('מעוגל: ${roundedBolus} יחידות');

    return InsulinCalculationResult(
      carbBolus: carbBolus,
      correctionBolus: correctionBolus,
      totalBolus: totalBolus,
      roundedBolus: roundedBolus,
      explanation: buffer.toString(),
    );
  }
}

