import '../models/child.dart';

abstract class ChildRepository {
  Stream<List<ChildModel>> watchChildrenForAssistant(String assistantUid);
  Future<void> addChild(ChildModel child);
  Future<void> updateChild(ChildModel child);
  Future<ChildModel> getChildById(String id);
}

