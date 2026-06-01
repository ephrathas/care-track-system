import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/config/school_config.dart';
import '../core/domain/domain_enums.dart';
import '../data/firestore/firestore_student_repository.dart';
import '../models/child_model.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class ChildProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final StorageService _storageService = StorageService();
  final FirestoreStudentRepository _students = FirestoreStudentRepository();

  List<ChildModel> _children = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<ChildModel>>? _childrenSubscription;

  List<ChildModel> get children => _children;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 📝 Listen to children profiles in real-time
  void startListeningToChildren(String parentId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _childrenSubscription?.cancel();
    _childrenSubscription = _dbService.getChildrenByParent(parentId).listen(
      (data) {
        _children = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // 🚪 Stop listening (e.g. on logout)
  void stopListening() {
    _childrenSubscription?.cancel();
    _childrenSubscription = null;
    _children = [];
    notifyListeners();
  }

  // 🧹 Clear Errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateChildPhoto({
    required String childId,
    Uint8List? imageBytes,
    File? imageFile,
  }) async {
    if (imageBytes == null && imageFile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrl = imageBytes != null
          ? await _storageService.uploadChildPhotoFromBytes(childId, imageBytes)
          : await _storageService.uploadChildPhotoFromFile(childId, imageFile!);

      await _dbService.updateChildFields(childId, {'imageUrl': imageUrl});

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 👶 Add Child Profile with dynamic photo upload
  Future<bool> addChild({
    required String name,
    required int age,
    required String parentId,
    String schoolId = SchoolConfig.defaultSchoolId,
    String? gradeLevelId,
    String? classRoomId,
    DateTime? dateOfBirth,
    Gender? gender,
    Uint8List? imageBytes,
    File? imageFile,
    List<String> vaccinations = const [],
    bool createEnrollment = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Generate unique doc reference to obtain ID in advance
      final docRef = FirebaseFirestore.instance.collection('children').doc();
      final childId = docRef.id;

      // 2. Save profile first so enrollment is fast; photo uploads in background.
      final child = ChildModel(
        id: childId,
        name: name,
        age: age,
        parentId: parentId,
        schoolId: schoolId,
        gradeLevelId: gradeLevelId,
        classRoomId: classRoomId,
        dateOfBirth: dateOfBirth,
        gender: gender,
        imageUrl: '',
        vaccinations: vaccinations,
      );

      await _dbService.setChild(childId, child);

      if (imageBytes != null || imageFile != null) {
        _uploadChildPhotoInBackground(
          childId: childId,
          imageBytes: imageBytes,
          imageFile: imageFile,
        );
      }

      if (createEnrollment &&
          gradeLevelId != null &&
          classRoomId != null &&
          gradeLevelId.isNotEmpty &&
          classRoomId.isNotEmpty) {
        final student = StudentModel(
          id: childId,
          schemaVersion: SchoolConfig.currentStudentSchemaVersion,
          schoolId: schoolId,
          parentId: parentId,
          fullName: name,
          dateOfBirth: dateOfBirth,
          age: age,
          gender: gender,
          imageUrl: '',
          vaccinations: vaccinations,
          gradeLevelId: gradeLevelId,
          classRoomId: classRoomId,
        );
        await _students.enrollStudent(
          student: student,
          classRoomId: classRoomId,
          gradeLevelId: gradeLevelId,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _uploadChildPhotoInBackground({
    required String childId,
    Uint8List? imageBytes,
    File? imageFile,
  }) async {
    try {
      final imageUrl = imageBytes != null
          ? await _storageService
              .uploadChildPhotoFromBytes(childId, imageBytes)
              .timeout(const Duration(seconds: 45))
          : await _storageService
              .uploadChildPhotoFromFile(childId, imageFile!)
              .timeout(const Duration(seconds: 45));
      await _dbService.updateChildFields(childId, {'imageUrl': imageUrl});
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Photo upload failed: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _childrenSubscription?.cancel();
    super.dispose();
  }
}
