import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';
import '../models/health_appointment_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 👶 Function to add a child to the database
  Future<void> addChild(ChildModel child) async {
    try {
      await _db.collection('children').add(child.toMap()).timeout(const Duration(seconds: 10));
      print("Child added successfully!");
    } catch (e) {
      print("Error adding child: $e");
      rethrow;
    }
  }

  // 👶 Function to save a child with a pre-generated ID (useful for photo uploads)
  Future<void> setChild(String childId, ChildModel child) async {
    try {
      await _db.collection('children').doc(childId).set(child.toMap()).timeout(const Duration(seconds: 10));
      print("Child set successfully!");
    } catch (e) {
      print("Error setting child: $e");
      rethrow;
    }
  }

  Future<void> updateChildFields(String childId, Map<String, dynamic> fields) async {
    try {
      await _db.collection('children').doc(childId).update(fields).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error updating child: $e');
      rethrow;
    }
  }

  // 📝 Function to get all children for a specific parent
  Stream<List<ChildModel>> getChildrenByParent(String parentId) {
    return _db
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChildModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 🏥 All registered children (healthcare directory)
  Stream<List<ChildModel>> getAllChildren() {
    return _db.collection('children').snapshots().map((snapshot) {
      final children = snapshot.docs
          .map((doc) => ChildModel.fromMap(doc.data(), doc.id))
          .toList();
      children.sort((a, b) => a.name.compareTo(b.name));
      return children;
    });
  }

  Stream<List<HealthAppointment>> getHealthAppointments() {
    return _db
        .collection('health_appointments')
        .orderBy('scheduledAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthAppointment.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addHealthAppointment(HealthAppointment appointment) async {
    await _db
        .collection('health_appointments')
        .add(appointment.toMap())
        .timeout(const Duration(seconds: 10));
  }
}
