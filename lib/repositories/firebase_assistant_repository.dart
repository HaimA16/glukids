import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assistant.dart';
import 'assistant_repository.dart';

class FirebaseAssistantRepository implements AssistantRepository {
  final FirebaseFirestore _firestore;

  FirebaseAssistantRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createAssistant(Assistant assistant) async {
    await _firestore
        .collection('assistants')
        .doc(assistant.id)
        .set(assistant.toMap());
  }

  @override
  Future<Assistant?> getAssistantById(String id) async {
    final doc = await _firestore.collection('assistants').doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return Assistant.fromFirestore(doc);
  }
}

