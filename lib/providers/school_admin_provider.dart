import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/academic/grade_naming.dart';
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
import '../core/catalog/academic_catalog.dart';

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
  List<UserModel> admins = [];
  List<ClassSubjectModel> classAssignments = [];

  bool isLoading = true;
  bool bootstrapNeeded = true;
  bool canClaimAdmin = false;
  String? error;

  StreamSubscription<List<UserModel>>? _adminsSub;

  String? get primaryAdminUid => school?.primaryAdminUid;

  bool isPrimaryAdmin(String uid) {
    final primary = primaryAdminUid;
    if (primary != null && primary.isNotEmpty) return primary == uid;
    return admins.length == 1 && admins.first.uid == uid;
  }

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
      grades = value.where((g) => g.isActive).toList();
      notifyListeners();
    });

    _structure.watchClassRooms(schoolId).listen((value) {
      classes = value.where((c) => c.isActive).toList();
      notifyListeners();
    });

    _structure.watchSubjects(schoolId).listen((value) {
      subjects = value.where((s) => s.isActive).toList();
      notifyListeners();
    });

    _structure.watchTeachers(schoolId).listen((value) {
      teachers = value;
      notifyListeners();
    });

    _structure.watchSchoolClassSubjects(schoolId).listen((value) {
      classAssignments = value;
      notifyListeners();
    });

    _adminsSub?.cancel();
    _adminsSub = _users.watchUsersByRole('', 'Admin').listen((value) {
      admins = value..sort((a, b) => a.fullName.compareTo(b.fullName));
      notifyListeners();
    });
  }

  void stopListening() {
    _adminsSub?.cancel();
    _adminsSub = null;
  }

  /// Backfill primary admin on schools created before governance was added.
  Future<void> ensurePrimaryAdminRecord(String fallbackAdminUid) async {
    if (fallbackAdminUid.isEmpty) return;
    await _admin.ensurePrimaryAdminUid(
      schoolId: schoolId,
      adminUid: fallbackAdminUid,
    );
  }

  Future<bool> promoteUserToAdminByEmail(String email) async {
    error = null;
    notifyListeners();
    try {
      final user = await _users.findUserByEmail(email);
      if (user == null) {
        error = 'No account found with that email. They must register first.';
        notifyListeners();
        return false;
      }
      if (user.role == 'Admin') {
        error = '${user.fullName} is already an admin.';
        notifyListeners();
        return false;
      }
      await _admin.promoteToAdmin(targetUid: user.uid, schoolId: schoolId);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeAdminRole({
    required UserModel target,
    required String actingAdminUid,
  }) async {
    error = null;
    notifyListeners();
    try {
      if (admins.length <= 1) {
        error = 'Cannot remove the only admin. Promote someone else first.';
        notifyListeners();
        return false;
      }
      if (target.uid == actingAdminUid && isPrimaryAdmin(actingAdminUid)) {
        error = 'Transfer main admin to someone else before removing yourself.';
        notifyListeners();
        return false;
      }
      if (isPrimaryAdmin(target.uid)) {
        final next = admins.firstWhere((a) => a.uid != target.uid);
        await _admin.transferPrimaryAdmin(
          schoolId: schoolId,
          newPrimaryAdminUid: next.uid,
        );
      }
      final fallbackRole = target.teacherProfile != null ? 'Teacher' : 'Parent';
      await _admin.demoteAdmin(targetUid: target.uid, fallbackRole: fallbackRole);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> transferPrimaryAdmin({
    required String actingAdminUid,
    required String newPrimaryAdminUid,
  }) async {
    error = null;
    notifyListeners();
    try {
      if (!isPrimaryAdmin(actingAdminUid)) {
        error = 'Only the main admin can transfer that role.';
        notifyListeners();
        return false;
      }
      if (newPrimaryAdminUid == actingAdminUid) {
        error = 'Choose a different admin.';
        notifyListeners();
        return false;
      }
      if (!admins.any((a) => a.uid == newPrimaryAdminUid)) {
        error = 'Selected user is not an admin.';
        notifyListeners();
        return false;
      }
      await _admin.transferPrimaryAdmin(
        schoolId: schoolId,
        newPrimaryAdminUid: newPrimaryAdminUid,
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
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
    error = null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      error = 'Enter a grade name.';
      notifyListeners();
      return false;
    }
    if (_gradeNameExists(trimmed)) {
      error = '"$trimmed" already exists. Each grade level must have a unique name.';
      notifyListeners();
      return false;
    }
    try {
      final sortOrder = GradeNaming.computeSortOrder(
        trimmed,
        grades.map((g) => g.sortOrder),
      );
      final gradeId = await _structure.createGradeLevel(
        GradeLevelModel(
          id: '',
          schoolId: schoolId,
          name: trimmed,
          sortOrder: sortOrder,
          band: band,
        ),
      );
      final sectionName = '$trimmed-A';
      final classId = await _structure.createClassRoom(
        ClassRoomModel(
          id: '',
          schoolId: schoolId,
          gradeLevelId: gradeId,
          name: sectionName,
        ),
      );
      await _ensureSubjectSlotsForSection(
        classRoomId: classId,
        gradeLevelId: gradeId,
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool _gradeNameExists(String name) {
    final key = GradeNaming.normalizeKey(name);
    return grades.any((g) => GradeNaming.normalizeKey(g.name) == key);
  }

  Future<bool> updateSchoolName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      error = 'School name cannot be empty.';
      notifyListeners();
      return false;
    }
    try {
      await _structure.updateSchoolName(schoolId, trimmed);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Copy subject slots from a sibling section, or use school-wide subjects.
  Future<void> _ensureSubjectSlotsForSection({
    required String classRoomId,
    required String gradeLevelId,
    String? templateSectionId,
  }) async {
    final existing = assignmentsForSection(classRoomId);
    if (existing.isNotEmpty) return;

    var subjectIds = <String>[];
    if (templateSectionId != null && templateSectionId.isNotEmpty) {
      subjectIds = assignmentsForSection(templateSectionId)
          .map((a) => a.subjectId)
          .where((id) => id.isNotEmpty)
          .toList();
    }
    if (subjectIds.isEmpty && subjects.isNotEmpty) {
      subjectIds = subjects.map((s) => s.id).toList();
    }
    if (subjectIds.isEmpty) {
      for (final assignment in AcademicCatalog.defaultCoreSubjects) {
        final id = await _findOrCreateSubjectByName(assignment.subjectName);
        subjectIds.add(id);
      }
    }

    for (final subjectId in subjectIds) {
      final already = classAssignments.any(
        (a) => a.classRoomId == classRoomId && a.subjectId == subjectId,
      );
      if (already) continue;
      await _structure.assignTeacherToClassSubject(
        ClassSubjectModel(
          id: '',
          schoolId: schoolId,
          classRoomId: classRoomId,
          subjectId: subjectId,
          teacherId: '',
        ),
      );
    }
  }

  Future<String> _findOrCreateSubjectByName(String name) async {
    for (final s in subjects) {
      if (s.name.toLowerCase() == name.toLowerCase()) return s.id;
    }
    return _structure.createSubject(
      SubjectModel(id: '', schoolId: schoolId, name: name),
    );
  }

  SectionEnrollmentStatus sectionEnrollmentStatus(String classRoomId) {
    final slots = assignmentsForSection(classRoomId);
    if (slots.isEmpty) {
      return const SectionEnrollmentStatus(
        hasSubjectSlots: false,
        canEnroll: false,
      );
    }
    final assigned = <String>[];
    final unassigned = <String>[];
    for (final slot in slots) {
      final subjectName = subjectNameForId(slot.subjectId) ?? 'Subject';
      if (slot.teacherId.isNotEmpty) {
        assigned.add(subjectName);
      } else {
        unassigned.add(subjectName);
      }
    }
    return SectionEnrollmentStatus(
      hasSubjectSlots: true,
      canEnroll: unassigned.isEmpty,
      assignedSubjectNames: assigned,
      unassignedSubjectNames: unassigned,
    );
  }

  (int linked, int total) sectionAssignmentCounts(String classRoomId) {
    final slots = assignmentsForSection(classRoomId);
    if (slots.isEmpty) return (0, 0);
    final linked = slots.where((a) => a.teacherId.isNotEmpty).length;
    return (linked, slots.length);
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
      final existing = await FirebaseFirestore.instance
          .collection(FirestoreCollections.classSubjects)
          .where('classRoomId', isEqualTo: classRoomId)
          .where('subjectId', isEqualTo: subjectId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      String? previousTeacherId;
      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        previousTeacherId = doc.data()['teacherId'] as String? ?? '';
        await doc.reference.update({
          'teacherId': teacherId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _structure.assignTeacherToClassSubject(
          ClassSubjectModel(
            id: '',
            schoolId: schoolId,
            classRoomId: classRoomId,
            subjectId: subjectId,
            teacherId: teacherId,
          ),
        );
      }

      await syncTeacherAssignedClasses(teacherId);
      if (previousTeacherId != null &&
          previousTeacherId.isNotEmpty &&
          previousTeacherId != teacherId) {
        await syncTeacherAssignedClasses(previousTeacherId);
      }
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Denormalizes class room IDs onto the teacher user doc for Firestore security rules.
  Future<void> syncTeacherAssignedClasses(String teacherId) async {
    if (teacherId.isEmpty) return;
    final snap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.classSubjects)
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .get();
    final classIds = snap.docs
        .map((d) => d.data()['classRoomId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(teacherId).set(
      {
        'assignedClassRoomIds': classIds,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Syncs school link + class access for every teacher account.
  Future<int> linkAllTeachersToSchool() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: 'Teacher')
        .get();
    var count = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};
      if (data['schoolId'] == null || data['schoolId'] == '') {
        updates['schoolId'] = schoolId;
      }
      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await doc.reference.set(updates, SetOptions(merge: true));
        count++;
      }
      await syncTeacherAssignedClasses(doc.id);
    }
    return count;
  }

  /// Load starter curriculum for a grade range (skips grades that already exist).
  Future<String> seedGradesRange({required int fromLevel, required int toLevel}) async {
    error = null;
    notifyListeners();
    try {
      if (fromLevel < 1 || toLevel < fromLevel) {
        error = 'Choose a valid grade range (e.g. 1 to 8).';
        return error!;
      }
      final service = AcademicCatalogSeedService();
      final added = await service.seedGradesInRange(
        schoolId: schoolId,
        fromLevel: fromLevel,
        toLevel: toLevel,
      );
      if (added > 0) {
        return 'Added $added grade(s) with section A and subject slots. '
            'Assign teachers in the Staff tab before parents enroll.';
      }
      return 'No new grades added — names in that range may already exist.';
    } catch (e) {
      error = e.toString();
      return error!;
    } finally {
      notifyListeners();
    }
  }

  /// @deprecated Use [seedGradesRange] instead.
  Future<String> seedDefaultCatalog() async {
    return seedGradesRange(fromLevel: 1, toLevel: 5);
  }

  List<ClassRoomModel> sectionsForGrade(String gradeLevelId) {
    return classes.where((c) => c.gradeLevelId == gradeLevelId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String? gradeNameForId(String gradeLevelId) {
    for (final g in grades) {
      if (g.id == gradeLevelId) return g.name;
    }
    return null;
  }

  String? subjectNameForId(String subjectId) {
    for (final s in subjects) {
      if (s.id == subjectId) return s.name;
    }
    return null;
  }

  List<ClassSubjectModel> assignmentsForSection(String classRoomId) {
    return classAssignments.where((a) => a.classRoomId == classRoomId).toList();
  }

  bool sectionHasLinkedTeacher(String classRoomId) {
    return assignmentsForSection(classRoomId)
        .any((a) => a.teacherId.isNotEmpty);
  }

  /// Sections with no teacher linked to any subject slot.
  List<ClassRoomModel> get sectionsWithoutTeachers {
    return classes.where((c) => !sectionHasLinkedTeacher(c.id)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  int get unlinkedSubjectSlotCount {
    return classAssignments.where((a) => a.teacherId.isEmpty).length;
  }

  /// Section label shown to parents, e.g. "Grade 1-A" → section "A".
  static String sectionLabel(ClassRoomModel section, String gradeName) {
    final prefix = '$gradeName-';
    if (section.name.startsWith(prefix)) {
      return section.name.substring(prefix.length);
    }
    if (section.name.startsWith(gradeName)) {
      return section.name.substring(gradeName.length).replaceFirst(RegExp(r'^[\s\-–]+'), '');
    }
    return section.name;
  }

  Future<bool> addSectionToGrade({
    required String gradeLevelId,
    required String sectionCode,
  }) async {
    final gradeName = gradeNameForId(gradeLevelId);
    if (gradeName == null) return false;
    final code = sectionCode.trim().toUpperCase();
    if (code.isEmpty) return false;
    final fullName = '$gradeName-$code';
    final exists = classes.any(
      (c) => c.gradeLevelId == gradeLevelId && c.name.toLowerCase() == fullName.toLowerCase(),
    );
    if (exists) {
      error = 'Section $fullName already exists.';
      notifyListeners();
      return false;
    }
    try {
      final classId = await _structure.createClassRoom(
        ClassRoomModel(
          id: '',
          schoolId: schoolId,
          gradeLevelId: gradeLevelId,
          name: fullName,
        ),
      );
      final siblings = sectionsForGrade(gradeLevelId);
      await _ensureSubjectSlotsForSection(
        classRoomId: classId,
        gradeLevelId: gradeLevelId,
        templateSectionId: siblings.isNotEmpty ? siblings.first.id : null,
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  GradeLevelModel? _gradeById(String id) {
    for (final g in grades) {
      if (g.id == id) return g;
    }
    return null;
  }

  ClassRoomModel? _classById(String id) {
    for (final c in classes) {
      if (c.id == id) return c;
    }
    return null;
  }

  SubjectModel? _subjectById(String id) {
    for (final s in subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<bool> removeGradeLevel(String gradeId) async {
    try {
      final grade = _gradeById(gradeId);
      if (grade == null) return false;
      await _structure.updateGradeLevel(
        GradeLevelModel(
          id: grade.id,
          schoolId: grade.schoolId,
          name: grade.name,
          sortOrder: grade.sortOrder,
          band: grade.band,
          isActive: false,
        ),
      );
      for (final section in sectionsForGrade(gradeId)) {
        await removeClassRoom(section.id);
      }
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeClassRoom(String classRoomId) async {
    try {
      final room = _classById(classRoomId);
      if (room == null) return false;
      await _structure.updateClassRoom(
        ClassRoomModel(
          id: room.id,
          schoolId: room.schoolId,
          gradeLevelId: room.gradeLevelId,
          name: room.name,
          homeroomTeacherId: room.homeroomTeacherId,
          capacity: room.capacity,
          isActive: false,
        ),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeSubject(String subjectId) async {
    try {
      final subject = _subjectById(subjectId);
      if (subject == null) return false;
      await _structure.updateSubject(
        SubjectModel(
          id: subject.id,
          schoolId: subject.schoolId,
          name: subject.name,
          code: subject.code,
          isActive: false,
        ),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeTeacherFromSchool(String teacherUid) async {
    try {
      final teacher = await _users.getUser(teacherUid);
      if (teacher == null) return false;
      await _users.updateUser(
        teacher.copyWith(schoolId: ''),
      );
      final assignments = await FirebaseFirestore.instance
          .collection(FirestoreCollections.classSubjects)
          .where('teacherId', isEqualTo: teacherUid)
          .where('isActive', isEqualTo: true)
          .get();
      for (final doc in assignments.docs) {
        await _structure.removeClassSubject(doc.id);
      }
      await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(teacherUid).set(
        {
          'assignedClassRoomIds': <String>[],
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
