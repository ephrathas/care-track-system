import '../../models/academic_models.dart';

/// Attendance, assignments, and assessments — no synthetic data.
abstract class AcademicRepository {
  Stream<List<AttendanceRecordModel>> watchAttendanceForClass(
    String classRoomId,
    DateTime date,
  );

  Future<void> markAttendance(AttendanceRecordModel record);

  Stream<List<AssignmentModel>> watchAssignmentsForClass(String classRoomId);
  Stream<List<AssignmentModel>> watchAssignmentsForTeacher(String teacherId);
  Stream<List<AssignmentModel>> watchAssignmentsForStudent(String studentId);
  Future<String> createAssignment(AssignmentModel assignment);

  Stream<List<AssessmentModel>> watchPublishedAssessmentsForStudent(
    String studentId,
  );

  Stream<List<AssessmentModel>> watchAssessmentsForTeacher(String teacherId);
  Future<String> createAssessment(AssessmentModel assessment);
  Future<void> publishAssessment(String assessmentId);
}
