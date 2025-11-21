import '../models/assistant.dart';

abstract class AssistantRepository {
  Future<void> createAssistant(Assistant assistant);
  Future<Assistant?> getAssistantById(String id);
}

