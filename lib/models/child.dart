import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String assistantUid;
  final String name;
  final String grade;
  final String parentPhone;
  final double glucoseMin;
  final double glucoseMax;
  final String instructions;
  
  // Insulin calculator parameters (optional)
  final double? insulinToCarbRatio; // units per 10g carbs
  final double? correctionFactor; // mg/dL per unit
  final double? targetMin; // target range min
  final double? targetMax; // target range max

  ChildModel({
    required this.id,
    required this.assistantUid,
    required this.name,
    required this.grade,
    required this.parentPhone,
    required this.glucoseMin,
    required this.glucoseMax,
    required this.instructions,
    this.insulinToCarbRatio,
    this.correctionFactor,
    this.targetMin,
    this.targetMax,
  });

  ChildModel copyWith({
    String? id,
    String? assistantUid,
    String? name,
    String? grade,
    String? parentPhone,
    double? glucoseMin,
    double? glucoseMax,
    String? instructions,
    double? insulinToCarbRatio,
    double? correctionFactor,
    double? targetMin,
    double? targetMax,
  }) {
    return ChildModel(
      id: id ?? this.id,
      assistantUid: assistantUid ?? this.assistantUid,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      parentPhone: parentPhone ?? this.parentPhone,
      glucoseMin: glucoseMin ?? this.glucoseMin,
      glucoseMax: glucoseMax ?? this.glucoseMax,
      instructions: instructions ?? this.instructions,
      insulinToCarbRatio: insulinToCarbRatio ?? this.insulinToCarbRatio,
      correctionFactor: correctionFactor ?? this.correctionFactor,
      targetMin: targetMin ?? this.targetMin,
      targetMax: targetMax ?? this.targetMax,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assistantUid': assistantUid,
      'name': name,
      'grade': grade,
      'parentPhone': parentPhone,
      'glucoseMin': glucoseMin,
      'glucoseMax': glucoseMax,
      'instructions': instructions,
      'insulinToCarbRatio': insulinToCarbRatio,
      'correctionFactor': correctionFactor,
      'targetMin': targetMin,
      'targetMax': targetMax,
    };
  }

  // Factory to create from a plain map (useful for testing)
  factory ChildModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return ChildModel(
      id: id,
      assistantUid: map['assistantUid'] as String,
      name: map['name'] as String,
      grade: map['grade'] as String,
      parentPhone: map['parentPhone'] as String,
      glucoseMin: (map['glucoseMin'] as num).toDouble(),
      glucoseMax: (map['glucoseMax'] as num).toDouble(),
      instructions: map['instructions'] as String,
      insulinToCarbRatio: map['insulinToCarbRatio'] != null
          ? (map['insulinToCarbRatio'] as num).toDouble()
          : null,
      correctionFactor: map['correctionFactor'] != null
          ? (map['correctionFactor'] as num).toDouble()
          : null,
      targetMin: map['targetMin'] != null
          ? (map['targetMin'] as num).toDouble()
          : null,
      targetMax: map['targetMax'] != null
          ? (map['targetMax'] as num).toDouble()
          : null,
    );
  }

  factory ChildModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChildModel.fromMap(data, id: doc.id);
  }
}

