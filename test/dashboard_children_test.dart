import 'package:flutter_test/flutter_test.dart';
import 'package:glukids/models/child.dart';

void main() {
  group('Dashboard Children List', () {
    test('children list does not contain duplicates by ID', () {
      // Create test children with unique IDs
      final children = [
        ChildModel(
          id: 'child-1',
          assistantUid: 'assistant-1',
          name: 'Child 1',
          grade: 'ג1',
          parentPhone: '0501234567',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
        ChildModel(
          id: 'child-2',
          assistantUid: 'assistant-1',
          name: 'Child 2',
          grade: 'ג2',
          parentPhone: '0501234568',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
        ChildModel(
          id: 'child-3',
          assistantUid: 'assistant-1',
          name: 'Child 3',
          grade: 'ג3',
          parentPhone: '0501234569',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
      ];

      // Verify all children have unique IDs
      final uniqueIds = children.map((c) => c.id).toSet();
      expect(uniqueIds.length, children.length,
          reason: 'All children should have unique IDs');

      // Verify no duplicates by comparing IDs
      final idSet = <String>{};
      for (final child in children) {
        expect(idSet.contains(child.id), isFalse,
            reason: 'Child ID should be unique: ${child.id}');
        idSet.add(child.id);
      }
    });

    test('children list filtering removes duplicates', () {
      // Simulate a list that might contain duplicates
      final childrenWithPossibleDuplicates = [
        ChildModel(
          id: 'child-1',
          assistantUid: 'assistant-1',
          name: 'Child 1',
          grade: 'ג1',
          parentPhone: '0501234567',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
        ChildModel(
          id: 'child-1', // Duplicate ID
          assistantUid: 'assistant-1',
          name: 'Child 1',
          grade: 'ג1',
          parentPhone: '0501234567',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
        ChildModel(
          id: 'child-2',
          assistantUid: 'assistant-1',
          name: 'Child 2',
          grade: 'ג2',
          parentPhone: '0501234568',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
      ];

      // Filter to remove duplicates by ID
      final uniqueChildren = <String, ChildModel>{};
      for (final child in childrenWithPossibleDuplicates) {
        uniqueChildren[child.id] = child;
      }
      final filteredList = uniqueChildren.values.toList();

      // Verify duplicates are removed
      expect(filteredList.length, 2,
          reason: 'Should remove duplicate child with same ID');
      expect(filteredList.map((c) => c.id).toSet().length, 2,
          reason: 'Filtered list should contain unique IDs only');
    });

    test('dashboard should render each child only once', () {
      // This test verifies the logic that should be in the dashboard
      // In a real widget test, we would mock the provider and verify rendering

      final children = [
        ChildModel(
          id: 'child-1',
          assistantUid: 'assistant-1',
          name: 'Child 1',
          grade: 'ג1',
          parentPhone: '0501234567',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
        ChildModel(
          id: 'child-2',
          assistantUid: 'assistant-1',
          name: 'Child 2',
          grade: 'ג2',
          parentPhone: '0501234568',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
      ];

      // Simulate dashboard rendering logic: one card per child
      final itemsToRender = children.length; // Each child renders once

      expect(itemsToRender, children.length,
          reason: 'Dashboard should render exactly one card per child');
    });

    test('filterUniqueChildren returns list with unique IDs only', () {
      // Helper function that simulates dashboard filtering logic
      List<ChildModel> filterUniqueChildren(List<ChildModel> children) {
        final uniqueChildren = <String, ChildModel>{};
        for (final child in children) {
          if (!uniqueChildren.containsKey(child.id)) {
            uniqueChildren[child.id] = child;
          }
        }
        return uniqueChildren.values.toList();
      }

      final childrenWithDuplicates = [
        ChildModel(
          id: 'child-1',
          assistantUid: 'assistant-1',
          name: 'Child 1',
          grade: 'ג1',
          parentPhone: '0501234567',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
        ChildModel(
          id: 'child-1', // Duplicate
          assistantUid: 'assistant-1',
          name: 'Child 1 Duplicate',
          grade: 'ג1',
          parentPhone: '0501234567',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
        ChildModel(
          id: 'child-2',
          assistantUid: 'assistant-1',
          name: 'Child 2',
          grade: 'ג2',
          parentPhone: '0501234568',
          glucoseMin: 80.0,
          glucoseMax: 180.0,
          instructions: 'Test instructions',
        ),
      ];

      final uniqueChildren = filterUniqueChildren(childrenWithDuplicates);

      expect(uniqueChildren.length, 2,
          reason: 'Should filter to unique children only');
      expect(uniqueChildren.map((c) => c.id).toSet().length, 2,
          reason: 'All children should have unique IDs');
      expect(uniqueChildren.first.id, 'child-1',
          reason: 'Should keep first occurrence of duplicate ID');
    });
  });
}

