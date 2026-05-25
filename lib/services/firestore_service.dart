import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a new child profile
  Future<void> addChild(ChildModel child) {
    return _db.collection('children').add(child.toMap());
  }

  // Get children for a specific parent
  Stream<List<ChildModel>> getChildren(String parentId) {
    return _db
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChildModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
