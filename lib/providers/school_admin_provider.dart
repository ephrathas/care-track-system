import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/config/school_config.dart';
import '../core/domain/domain_enums.dart';
import '../data/firestore/firestore_admin_repository.dart';
import '../data/firestore/firestore_school_structure_repository.dart';
import '../data/firestore/firestore_user_repository.dart';
import '../data/repositories/user_repository.dart';
import '../models/class_room_model.dart';
import '../models/class_subject_model.dart';
import '../models/grade_level_model.dart';
import '../models/school_model.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../services/academic_catalog_seed_service.dart';

/// Admin school setup — grades, classes, subjects, teacher links.
class SchoolAdminProvider with ChangeNotifier {
  final FirestoreSchoolStructureRepository _structure;
  final FirestoreAdminRepository _admin;
  final UserRepository _users;

  SchoolAdminProvider({
    FirestoreSchoolStructureRepository? structure,
    FirestoreAdminRepository? admin,
    UserRepository? users,
  })  : _structure = structure ?? FirestoreSchoolStructureRepository(),
        _admin = admin ?? FirestoreAdminRepository(),
        _users = users ?? FirestoreUserRepository();

  String get schoolId => SchoolConfig.defaultSchoolId;

  SchoolModel? school;
  List<GradeLevelModel> grades = [];
  List<ClassRoomModel> classes = [];
  List<SubjectModel> subjects = [];
  List<UserModel> teachers = [];

  bool isLoading = true;
  bool bootstrapNeeded = true;
  bool canClaimAdmin = false;
  String? error;

  void startListening() {
    isLoading = true;
    notifyListeners();
    _refreshBootstrapFlags();

    _structure.watchSchool(schoolId).listen((value) {
      school = value;
      bootstrapNeeded = value == null;
      notifyListeners();
    });

    _structure.watchGradeLevels(schoolId).listen((value) {
      grades = value;
      notifyListeners();
    });

    _structure.watchClassRooms(schoolId).listen((value) {
      classes = value;
      notifyListeners();
    });

    _structure.watchSubjects(schoolId).listen((value) {
      subjects = value;
      notifyListeners();
    });

    _structure.watchTeachers(schoolId).listen((value) {
      teachers = value;
      notifyListeners();
    });
  }

  Future<void> _refreshBootstrapFlags() async {
    try {
      bootstrapNeeded = await _admin.isAdminBootstrapNeeded(schoolId);
      canClaimAdmin = await _admin.canClaimFirstAdmin();
    } catch (e) {
      debugPrint('Bootstrap check error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bootstrapSchool({
    required String schoolName,
    required UserModel admin,
  }) async {
    error = null;
    notifyListeners();
    try {
      await _admin.bootstrapSchool(
        SchoolBootstrapRequest(
          schoolName: schoolName,
          adminUid: admin.uid,
          adminEmail: admin.email,
          adminFullName: admin.fullName,
        ),
      );
      bootstrapNeeded = false;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> claimFirstAdmin({
    required String schoolName,
    required UserModel user,
  }) async {
    error = null;
    notifyListeners();
    try {
      await _admin.claimFirstAdminAndBootstrap(
        SchoolBootstrapRequest(
          schoolName: schoolName,
          adminUid: user.uid,
          adminEmail: user.email,
          adminFullName: user.fullName,
        ),
      );
      bootstrapNeeded = false;
      canClaimAdmin = false;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addGradeLevel(String name, {String? band}) async {
    try {
      final order = grades.length + 1;
      await _structure.createGradeLevel(
        GradeLevelModel(
          id: '',
          schoolId: schoolId,
          name: name,
          sortOrder: order,
          band: band,
        ),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addClassRoom({
    required String name,
    required String gradeLevelId,
    String? homeroomTeacherId,
  }) async {
    try {
      await _structure.createClassRoom(
        ClassRoomModel(
          id: '',
          schoolId: schoolId,
          gradeLevelId: gradeLevelId,
          name: name,
          homeroomTeacherId: homeroomTeacherId,
        ),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSubject(String name, {String? code}) async {
    try {
      await _structure.createSubject(
        SubjectModel(
          id: '',
          schoolId: schoolId,
          name: name,
          code: code,
        ),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignTeacher({
    required String classRoomId,
    required String subjectId,
    required String teacherId,
  }) async {
    try {
      await _structure.assignTeacherToClassSubject(
        ClassSubjectModel(
          id: '',
          schoolId: schoolId,
          classRoomId: classRoomId,
          subjectId: subjectId,
          teacherId: teacherId,
        ),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Seeds Grades 1–5 catalog into Firestore when no grades exist yet.
  Future<bool> seedDefaultCatalog() async {
    error = null;
    notifyListeners();
    try {
      final seeded = await AcademicCatalogSeedService().seedSchoolCatalogIfEmpty(
        schoolId: schoolId,
      );
      if (!seeded) {
        error = 'Catalog already loaded. Use Grades/Classes tabs to edit.';
      }
      return seeded;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<int> linkAllTeachersToSchool() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: 'Teacher')
        .get();
    var count = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['schoolId'] == null || data['schoolId'] == '') {
        await doc.reference.update({'schoolId': schoolId});
        count++;
      }
    }
    return count;
  }
}
