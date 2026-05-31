/// How a student accesses the platform.
enum StudentAccountMode {
  /// Profile managed by parent only — no student login.
  parentManaged('parent_managed'),

  /// Student has their own Firebase Auth account linked to profile.
  selfLogin('self_login');

  const StudentAccountMode(this.id);
  final String id;

  static StudentAccountMode fromId(String? value) {
    for (final mode in StudentAccountMode.values) {
      if (mode.id == value) return mode;
    }
    return StudentAccountMode.parentManaged;
  }
}

enum EnrollmentStatus {
  active('active'),
  withdrawn('withdrawn'),
  graduated('graduated');

  const EnrollmentStatus(this.id);
  final String id;

  static EnrollmentStatus fromId(String? value) {
    for (final status in EnrollmentStatus.values) {
      if (status.id == value) return status;
    }
    return EnrollmentStatus.active;
  }
}

enum AttendanceStatus {
  present('present'),
  absent('absent'),
  late('late'),
  excused('excused');

  const AttendanceStatus(this.id);
  final String id;

  static AttendanceStatus fromId(String? value) {
    for (final status in AttendanceStatus.values) {
      if (status.id == value) return status;
    }
    return AttendanceStatus.present;
  }
}

enum NotificationType {
  enrollmentCreated('enrollment_created'),
  assignmentAdded('assignment_added'),
  gradePublished('grade_published'),
  attendanceAlert('attendance_alert'),
  healthAppointment('health_appointment'),
  messageReceived('message_received'),
  marketplaceOrder('marketplace_order'),
  announcement('announcement');

  const NotificationType(this.id);
  final String id;

  static NotificationType fromId(String? value) {
    for (final type in NotificationType.values) {
      if (type.id == value) return type;
    }
    return NotificationType.announcement;
  }
}

enum SchoolType {
  school('school'),
  childcare('childcare');

  const SchoolType(this.id);
  final String id;

  static SchoolType fromId(String? value) {
    for (final type in SchoolType.values) {
      if (type.id == value) return type;
    }
    return SchoolType.school;
  }
}

enum Gender {
  male('male'),
  female('female'),
  other('other'),
  preferNotToSay('prefer_not_to_say');

  const Gender(this.id);
  final String id;

  static Gender? fromId(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final g in Gender.values) {
      if (g.id == value) return g;
    }
    return null;
  }
}

/// Firestore collection names — single source of truth.
class FirestoreCollections {
  FirestoreCollections._();

  static const schools = 'schools';
  static const gradeLevels = 'grade_levels';
  static const classRooms = 'class_rooms';
  static const subjects = 'subjects';
  static const classSubjects = 'class_subjects';
  static const users = 'users';
  static const children = 'children';
  static const enrollments = 'enrollments';
  static const assignments = 'assignments';
  static const assessments = 'assessments';
  static const attendance = 'attendance';
  static const healthProfiles = 'health_profiles';
  static const healthcareAccess = 'healthcare_access';
  static const healthAppointments = 'health_appointments';
  static const messageThreads = 'message_threads';
  static const messages = 'messages';
  static const notifications = 'notifications';
  static const marketplaceOrders = 'marketplace_orders';
  static const products = 'products';
}
