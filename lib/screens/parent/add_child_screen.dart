import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/academic/academic_resolver.dart';
import '../../core/academic/grade_naming.dart';
import '../../core/config/school_config.dart';
import '../../core/domain/domain_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../models/grade_level_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../widgets/parent/link_code_dialog.dart';
import '../../providers/school_admin_provider.dart';
import '../../core/health/health_concerns.dart';
import '../../widgets/parent/grade_teacher_preview.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _dob;
  Gender? _gender;
  RelationshipType _relationship = RelationshipType.guardian;
  String? _selectedGradeId;
  String? _selectedSectionId;
  String? _resolvedClassId;
  final _ageController = TextEditingController();
  final _resolver = AcademicResolver();
  GradeEnrollmentPreview? _gradePreview;
  bool _loadingPreview = false;
  bool _healthExpanded = true;
  bool _usesPrivateDoctor = false;
  final Set<String> _selectedConcernIds = {HealthConcerns.none};

  SectionEnrollmentStatus? _statusForClass(SchoolAdminProvider admin) {
    final classId = _resolvedClassId ?? _selectedSectionId;
    if (classId == null || classId.isEmpty) return null;
    return admin.sectionEnrollmentStatus(classId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  int? _calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 7),
      firstDate: DateTime(1995),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _dob = picked;
      final age = _calculateAge(picked);
      if (age != null) _ageController.text = '$age';
    });
  }

  Future<void> _onGradeSelected(String? gradeId) async {
    setState(() {
      _selectedGradeId = gradeId;
      _selectedSectionId = null;
      _resolvedClassId = null;
      _gradePreview = null;
    });
    if (gradeId == null) return;

    final schoolAdmin = Provider.of<SchoolAdminProvider>(context, listen: false);
    final sections = _resolver.sectionsForGrade(gradeId, schoolAdmin);
    if (sections.length == 1) {
      _selectedSectionId = sections.first.id;
      _resolvedClassId = sections.first.id;
    }
    await _refreshPreview();
  }

  Future<void> _onSectionSelected(String? sectionId) async {
    setState(() {
      _selectedSectionId = sectionId;
      _resolvedClassId = sectionId;
    });
    await _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    final gradeId = _selectedGradeId;
    if (gradeId == null) return;

    setState(() => _loadingPreview = true);
    final schoolAdmin = Provider.of<SchoolAdminProvider>(context, listen: false);
    final preview = await _resolver.previewForGrade(
      gradeLevelId: gradeId,
      admin: schoolAdmin,
      classRoomId: _selectedSectionId ?? _resolvedClassId,
    );
    if (!mounted) return;
    setState(() {
      _gradePreview = preview;
      _resolvedClassId = preview?.classRoom?.id ?? _resolvedClassId;
      _loadingPreview = false;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
                child: Text(message,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
                child: Text(message,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: AppTheme.softGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitChildForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final childProvider = Provider.of<ChildProvider>(context, listen: false);

    final parentId = authProvider.currentUser?.uid;
    if (parentId == null) {
      _showErrorSnackbar("Session expired. Please log in again.");
      return;
    }

    final String name = _nameController.text.trim();
    final int age = int.parse(_ageController.text.trim());

    final concernIds = _usesPrivateDoctor
        ? <String>[]
        : _selectedConcernIds.toList();

    // Call provider
    if (_selectedGradeId != null && (_resolvedClassId == null || _resolvedClassId!.isEmpty)) {
      _showErrorSnackbar('Select a section for this grade, or ask admin to add sections.');
      return;
    }

    final enrollStatus = _statusForClass(
      Provider.of<SchoolAdminProvider>(context, listen: false),
    );
    if (enrollStatus != null && !enrollStatus.canEnroll) {
      _showErrorSnackbar(enrollStatus.blockingMessage);
      return;
    }

    final result = await childProvider.addChild(
      name: name,
      age: age,
      parentId: parentId,
      relationshipType: _relationship,
      schoolId: SchoolConfig.defaultSchoolId,
      gradeLevelId: _selectedGradeId,
      classRoomId: _resolvedClassId,
      dateOfBirth: _dob,
      gender: _gender,
      healthConcernIds: concernIds,
      usesPrivateDoctor: _usesPrivateDoctor,
    );

    if (result.success) {
      if (!mounted) return;
      if (result.linkCode != null) {
        await LinkCodeDialog.show(
          context,
          title: 'Child enrolled',
          message:
              'When your child registers, they must choose "My parent already enrolled me", '
              'enter this code, and use the exact same full name: $name. '
              'They can complete their profile after signing in.',
          linkCode: result.linkCode!,
          childName: name,
        );
      }
      if (mounted) Navigator.pop(context);
    } else {
      _showErrorSnackbar(
        childProvider.errorMessage ?? 'Failed to save profile. Try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final childProvider = Provider.of<ChildProvider>(context);
    final schoolAdmin = Provider.of<SchoolAdminProvider>(context);
    final List<GradeLevelModel> grades = schoolAdmin.grades;
    final enrollmentStatus = _statusForClass(schoolAdmin);
    final canEnroll = _selectedGradeId == null ||
        ((_resolvedClassId != null && _resolvedClassId!.isNotEmpty) &&
            (enrollmentStatus?.canEnroll ?? false));

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Enroll Your Child",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name field
                TextFormField(
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter child's name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Child's Full Name",
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Date of birth
                InkWell(
                  onTap: _pickDob,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      prefixIcon: const Icon(Icons.event_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                    ),
                    child: Text(
                      _dob == null
                          ? 'Select date of birth'
                          : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                      style: TextStyle(
                        color: _dob == null
                            ? (isDark ? Colors.grey[400] : Colors.grey[600])
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<Gender>(
                  value: _gender,
                  items: Gender.values
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(_genderLabel(g)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _gender = value),
                  validator: (_) => _gender == null ? 'Select gender' : null,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: const Icon(Icons.wc_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<RelationshipType>(
                  value: _relationship,
                  items: RelationshipType.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _relationship = v);
                  },
                  decoration: InputDecoration(
                    labelText: 'Your relationship',
                    prefixIcon: const Icon(Icons.family_restroom_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Age field
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter age";
                    }
                    final age = int.tryParse(val.trim());
                    if (age == null || age < 0) {
                      return "Please enter a valid age";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Age (in Years)",
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Grade level
                DropdownButtonFormField<String>(
                  value: _selectedGradeId,
                  items: grades
                      .map((g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.name),
                          ))
                      .toList(),
                  onChanged: grades.isEmpty ? null : _onGradeSelected,
                  validator: (_) =>
                      grades.isEmpty ? null : (_selectedGradeId == null ? 'Select grade level' : null),
                  decoration: InputDecoration(
                    labelText: "Grade",
                    prefixIcon: const Icon(Icons.stacked_bar_chart_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                  ),
                ),
                if (grades.isEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'School setup not ready. Ask admin to add grades and assign teachers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    ),
                  ),
                ],

                if (_selectedGradeId != null) ...[
                  Builder(
                    builder: (context) {
                      final sections = _resolver.sectionsForGrade(
                        _selectedGradeId!,
                        schoolAdmin,
                      );
                      if (sections.length <= 1) return const SizedBox.shrink();
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedSectionId,
                            items: sections
                                .map((c) {
                                  final gradeName = schoolAdmin.gradeNameForId(_selectedGradeId!) ?? '';
                                  final label = SchoolAdminProvider.sectionLabel(c, gradeName);
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text('Section $label (${c.name})'),
                                  );
                                })
                                .toList(),
                            onChanged: _onSectionSelected,
                            validator: (_) => _selectedSectionId == null
                                ? 'Select a section (e.g. A or B)'
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Section / class group',
                              helperText: 'Each grade can have sections like A and B',
                              prefixIcon: const Icon(Icons.class_rounded),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  if (enrollmentStatus != null && !enrollmentStatus.canEnroll) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.orange.withOpacity(0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              enrollmentStatus.blockingMessage,
                              style: const TextStyle(fontSize: 12, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  GradeTeacherPreviewPanel(
                    preview: _gradePreview,
                    isLoading: _loadingPreview,
                    enrollmentStatus: enrollmentStatus,
                  ),
                ],

                const SizedBox(height: 24),

                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  initiallyExpanded: _healthExpanded,
                  onExpansionChanged: (v) => setState(() => _healthExpanded = v),
                  title: Text(
                    'Health follow-up (optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: const Text(
                    'Select areas where your child may need a school doctor',
                    style: TextStyle(fontSize: 12),
                  ),
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _usesPrivateDoctor,
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppTheme.primaryBlue;
                        }
                        return null;
                      }),
                      title: const Text(
                        'We use a private doctor outside school',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      onChanged: (v) => setState(() {
                        _usesPrivateDoctor = v;
                        if (v) _selectedConcernIds.clear();
                      }),
                    ),
                    if (!_usesPrivateDoctor)
                      ...HealthConcerns.catalog.map((concern) {
                        final selected = _selectedConcernIds.contains(concern.id);
                        return CheckboxListTile(
                          value: selected,
                          secondary: Icon(concern.icon, color: AppTheme.primaryBlue),
                          title: Text(
                            concern.label,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            concern.description,
                            style: const TextStyle(fontSize: 11),
                          ),
                          activeColor: AppTheme.primaryBlue,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedConcernIds.add(concern.id);
                              } else {
                                _selectedConcernIds.remove(concern.id);
                              }
                              if (_selectedConcernIds.isEmpty) {
                                _selectedConcernIds.add(HealthConcerns.none);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }),
                    if (!_usesPrivateDoctor)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'If no doctor with the right specialty exists yet, the school admin is notified and you will get an alert when one is added.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (childProvider.isLoading || !canEnroll)
                        ? null
                        : _submitChildForm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: childProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text("Enroll Child",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _genderLabel(Gender g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}
