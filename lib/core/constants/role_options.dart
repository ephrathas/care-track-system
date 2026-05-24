import 'auth_assets.dart';
import 'user_role.dart';

class RoleOption {
  final UserRole role;
  final String subtitle;
  final String featureAsset;

  const RoleOption({
    required this.role,
    required this.subtitle,
    required this.featureAsset,
  });

  String get title => role.label;
}

class RoleOptions {
  RoleOptions._();

  static const List<RoleOption> all = [
    RoleOption(
      role: UserRole.parent,
      subtitle: "Track your child's progress, health, and school updates.",
      featureAsset: AuthAssets.featureParent,
    ),
    RoleOption(
      role: UserRole.teacher,
      subtitle: 'Manage attendance, grades, and parent communication.',
      featureAsset: AuthAssets.featureTeacher,
    ),
    RoleOption(
      role: UserRole.child,
      subtitle: 'View assignments, schedules, and earn progress badges.',
      featureAsset: AuthAssets.featureChild,
    ),
    RoleOption(
      role: UserRole.healthcare,
      subtitle: 'Manage medical records, vaccinations, and appointments.',
      featureAsset: AuthAssets.featureHealthcare,
    ),
  ];

  static RoleOption? forRole(UserRole role) {
    for (final option in all) {
      if (option.role == role) return option;
    }
    return null;
  }
}
