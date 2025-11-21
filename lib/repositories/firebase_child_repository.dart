import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child.dart';
import 'child_repository.dart';

class FirebaseChildRepository implements ChildRepository {
  final FirebaseFirestore _firestore;

  FirebaseChildRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ChildModel>> watchChildrenForAssistant(String assistantUid) {
    return _firestore
        .collection('children')
        .where('assistantUid', isEqualTo: assistantUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChildModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> addChild(ChildModel child) async {
    await _firestore.collection('children').doc(child.id).set(child.toMap());
  }

  @override
  Future<ChildModel> getChildById(String id) async {
    final doc = await _firestore.collection('children').doc(id).get();
    if (!doc.exists) {
      throw Exception('Child not found');
    }
    return ChildModel.fromFirestore(doc);
  }
}

