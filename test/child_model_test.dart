import 'package:flutter_test/flutter_test.dart';
import 'package:glukids/models/child.dart';

void main() {
  group('ChildModel', () {
    test('toMap includes all fields', () {
      final child = ChildModel(
        id: 'test-id',
        assistantUid: 'assistant-uid',
        name: 'Test Child',
        grade: 'ג1',
        parentPhone: '0501234567',
        glucoseMin: 80.0,
        glucoseMax: 180.0,
        instructions: 'Test instructions',
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 90.0,
        targetMax: 150.0,
      );

      final map = child.toMap();

      expect(map['assistantUid'], 'assistant-uid');
      expect(map['name'], 'Test Child');
      expect(map['grade'], 'ג1');
      expect(map['parentPhone'], '0501234567');
      expect(map['glucoseMin'], 80.0);
      expect(map['glucoseMax'], 180.0);
      expect(map['instructions'], 'Test instructions');
      expect(map['insulinToCarbRatio'], 2.0);
      expect(map['correctionFactor'], 50.0);
      expect(map['targetMin'], 90.0);
      expect(map['targetMax'], 150.0);
    });

    test('toMap handles null optional fields', () {
      final child = ChildModel(
        id: 'test-id',
        assistantUid: 'assistant-uid',
        name: 'Test Child',
        grade: 'ג1',
        parentPhone: '0501234567',
        glucoseMin: 80.0,
        glucoseMax: 180.0,
        instructions: 'Test instructions',
      );

      final map = child.toMap();

      expect(map['insulinToCarbRatio'], isNull);
      expect(map['correctionFactor'], isNull);
      expect(map['targetMin'], isNull);
      expect(map['targetMax'], isNull);
    });

    test('fromMap creates model from plain map', () {
      final map = {
        'assistantUid': 'assistant-uid',
        'name': 'Test Child',
        'grade': 'ג1',
        'parentPhone': '0501234567',
        'glucoseMin': 80.0,
        'glucoseMax': 180.0,
        'instructions': 'Test instructions',
        'insulinToCarbRatio': 2.0,
        'correctionFactor': 50.0,
        'targetMin': 90.0,
        'targetMax': 150.0,
      };

      final child = ChildModel.fromMap(map, id: 'test-id');

      expect(child.id, 'test-id');
      expect(child.assistantUid, 'assistant-uid');
      expect(child.name, 'Test Child');
      expect(child.grade, 'ג1');
      expect(child.parentPhone, '0501234567');
      expect(child.glucoseMin, 80.0);
      expect(child.glucoseMax, 180.0);
      expect(child.instructions, 'Test instructions');
      expect(child.insulinToCarbRatio, 2.0);
      expect(child.correctionFactor, 50.0);
      expect(child.targetMin, 90.0);
      expect(child.targetMax, 150.0);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'assistantUid': 'assistant-uid',
        'name': 'Test Child',
        'grade': 'ג1',
        'parentPhone': '0501234567',
        'glucoseMin': 80.0,
        'glucoseMax': 180.0,
        'instructions': 'Test instructions',
      };

      final child = ChildModel.fromMap(map, id: 'test-id');

      expect(child.insulinToCarbRatio, isNull);
      expect(child.correctionFactor, isNull);
      expect(child.targetMin, isNull);
      expect(child.targetMax, isNull);
    });

    test('fromMap and toMap are inverse operations', () {
      final original = ChildModel(
        id: 'test-id',
        assistantUid: 'assistant-uid',
        name: 'Test Child',
        grade: 'ג1',
        parentPhone: '0501234567',
        glucoseMin: 80.0,
        glucoseMax: 180.0,
        instructions: 'Test instructions',
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 90.0,
        targetMax: 150.0,
      );

      final map = original.toMap();
      final reconstructed = ChildModel.fromMap(map, id: original.id);

      expect(reconstructed.id, original.id);
      expect(reconstructed.assistantUid, original.assistantUid);
      expect(reconstructed.name, original.name);
      expect(reconstructed.grade, original.grade);
      expect(reconstructed.parentPhone, original.parentPhone);
      expect(reconstructed.glucoseMin, original.glucoseMin);
      expect(reconstructed.glucoseMax, original.glucoseMax);
      expect(reconstructed.instructions, original.instructions);
      expect(reconstructed.insulinToCarbRatio, original.insulinToCarbRatio);
      expect(reconstructed.correctionFactor, original.correctionFactor);
      expect(reconstructed.targetMin, original.targetMin);
      expect(reconstructed.targetMax, original.targetMax);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = ChildModel(
        id: 'test-id',
        assistantUid: 'assistant-uid',
        name: 'Original Name',
        grade: 'ג1',
        parentPhone: '0501234567',
        glucoseMin: 80.0,
        glucoseMax: 180.0,
        instructions: 'Original instructions',
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        glucoseMin: 90.0,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Updated Name');
      expect(updated.grade, original.grade);
      expect(updated.glucoseMin, 90.0);
      expect(updated.glucoseMax, original.glucoseMax);
      expect(original.name, 'Original Name'); // Original unchanged
    });

    test('copyWith handles insulin parameters', () {
      final original = ChildModel(
        id: 'test-id',
        assistantUid: 'assistant-uid',
        name: 'Test Child',
        grade: 'ג1',
        parentPhone: '0501234567',
        glucoseMin: 80.0,
        glucoseMax: 180.0,
        instructions: 'Test instructions',
      );

      final updated = original.copyWith(
        insulinToCarbRatio: 2.0,
        correctionFactor: 50.0,
        targetMin: 90.0,
        targetMax: 150.0,
      );

      expect(updated.insulinToCarbRatio, 2.0);
      expect(updated.correctionFactor, 50.0);
      expect(updated.targetMin, 90.0);
      expect(updated.targetMax, 150.0);
      expect(original.insulinToCarbRatio, isNull); // Original unchanged
    });
  });
}
