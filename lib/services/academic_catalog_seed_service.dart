import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/catalog/academic_catalog.dart';
import '../core/config/school_config.dart';
import '../core/domain/domain_enums.dart';
import '../data/firestore/firestore_helpers.dart';
import '../models/class_room_model.dart';
import '../models/class_subject_model.dart';
import '../models/grade_level_model.dart';
import '../models/subject_model.dart';

/// Seeds Firestore school structure from [AcademicCatalog] (idempotent when grades exist).
class AcademicCatalogSeedService {
  final FirebaseFirestore _db;

  AcademicCatalogSeedService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<bool> seedSchoolCatalogIfEmpty({String? schoolId}) async {
    final sid = schoolId ?? SchoolConfig.defaultSchoolId;
    final existing = await _db
        .collection(FirestoreCollections.gradeLevels)
        .where('schoolId', isEqualTo: sid)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return false;
    await seedSchoolCatalog(schoolId: sid, force: true);
    return true;
  }

  /// [force] replaces nothing — only used when collection is empty unless force with empty check above.
  Future<void> seedSchoolCatalog({
    String? schoolId,
    bool force = false,
  }) async {
    final sid = schoolId ?? SchoolConfig.defaultSchoolId;

    if (!force) {
      final existing = await _db
          .collection(FirestoreCollections.gradeLevels)
          .where('schoolId', isEqualTo: sid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return;
    }

    final subjectNameToId = <String, String>{};

    for (final catalogGrade in AcademicCatalog.grades) {
      final gradeRef = await _db.collection(FirestoreCollections.gradeLevels).add(
            FirestoreHelpers.withTimestamps(
              GradeLevelModel(
                id: '',
                schoolId: sid,
                name: catalogGrade.displayName,
                sortOrder: catalogGrade.level,
                band: 'Primary',
              ).toMap()
                ..['catalogLevel'] = catalogGrade.level,
              isCreate: true,
            ),
          );

      final classRef = await _db.collection(FirestoreCollections.classRooms).add(
            FirestoreHelpers.withTimestamps(
              ClassRoomModel(
                id: '',
                schoolId: sid,
                gradeLevelId: gradeRef.id,
                name: catalogGrade.classSectionName,
              ).toMap(),
              isCreate: true,
            ),
          );

      for (final assignment in catalogGrade.subjects) {
        var subjectId = subjectNameToId[assignment.subjectName];
        if (subjectId == null) {
          final subjectRef = await _db.collection(FirestoreCollections.subjects).add(
                FirestoreHelpers.withTimestamps(
                  SubjectModel(
                    id: '',
                    schoolId: sid,
                    name: assignment.subjectName,
                    code: _subjectCode(assignment.subjectName),
                  ).toMap(),
                  isCreate: true,
                ),
              );
          subjectId = subjectRef.id;
          subjectNameToId[assignment.subjectName] = subjectId;
        }

        await _db.collection(FirestoreCollections.classSubjects).add(
              FirestoreHelpers.withTimestamps(
                {
                  'schoolId': sid,
                  'classRoomId': classRef.id,
                  'subjectId': subjectId,
                  'teacherId': '',
                  'isActive': true,
                  'catalogTeacherName': assignment.teacherName,
                  'catalogTeacherEmail': assignment.teacherEmail,
                  'catalogSubjectIcon': assignment.subjectIcon,
                },
                isCreate: true,
              ),
            );
      }
    }
  }

  static String _subjectCode(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, parts.first.length.clamp(0, 4)).toUpperCase();
    return parts.map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }
}
