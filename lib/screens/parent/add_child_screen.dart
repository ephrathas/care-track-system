import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/academic/academic_resolver.dart';
import '../../core/config/school_config.dart';
import '../../core/domain/domain_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../models/grade_level_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/school_admin_provider.dart';
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
  String? _selectedGradeId;
  String? _resolvedClassId;
  final _ageController = TextEditingController();
  final _resolver = AcademicResolver();
  GradeEnrollmentPreview? _gradePreview;
  bool _loadingPreview = false;
  bool _vaccinesExpanded = false;

  // Image Selector States
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;

  // Optional health info (not required in onboarding)
  final List<Map<String, dynamic>> _vaccinesList = [
    {'name': 'BCG (Tuberculosis)', 'checked': false},
    {'name': 'HepB (Hepatitis B)', 'checked': false},
    {'name': 'DTaP (Diphtheria, Tetanus, Pertussis)', 'checked': false},
    {'name': 'MMR (Measles, Mumps, Rubella)', 'checked': false},
    {'name': 'Polio (IPV)', 'checked': false},
  ];

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
      _resolvedClassId = null;
      _gradePreview = null;
    });
    if (gradeId == null) return;

    final schoolAdmin = Provider.of<SchoolAdminProvider>(context, listen: false);
    final classRoom = _resolver.defaultClassForGrade(gradeId, schoolAdmin);
    setState(() => _resolvedClassId = classRoom?.id);

    setState(() => _loadingPreview = true);
    final preview = await _resolver.previewForGrade(
      gradeLevelId: gradeId,
      admin: schoolAdmin,
    );
    if (!mounted) return;
    setState(() {
      _gradePreview = preview;
      _resolvedClassId = preview?.classRoom?.id ?? _resolvedClassId;
      _loadingPreview = false;
    });
  }

  // Pick Image Action
  Future<void> _selectPhoto() async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (selected != null) {
        final bytes = await selected.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to pick image: $e"),
            backgroundColor: Colors.redAccent),
      );
    }
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

    // Gather selected vaccines
    final List<String> selectedVaccines = _vaccinesList
        .where((element) => element['checked'] == true)
        .map((element) => element['name'] as String)
        .toList();

    // Call provider
    if (_selectedGradeId != null && (_resolvedClassId == null || _resolvedClassId!.isEmpty)) {
      _showErrorSnackbar('No class section for this grade. Ask admin to seed the catalog.');
      return;
    }

    final success = await childProvider.addChild(
      name: name,
      age: age,
      parentId: parentId,
      schoolId: SchoolConfig.defaultSchoolId,
      gradeLevelId: _selectedGradeId,
      classRoomId: _resolvedClassId,
      dateOfBirth: _dob,
      gender: _gender,
      imageBytes: _imageBytes,
      vaccinations: selectedVaccines,
    );

    if (success) {
      final photoNote = _imageBytes != null
          ? ' Photo will appear shortly after upload.'
          : '';
      _showSuccessSnackbar("Enrolled $name successfully!$photoNote");
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      _showErrorSnackbar(
          childProvider.errorMessage ?? "Failed to save profile. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final childProvider = Provider.of<ChildProvider>(context);
    final schoolAdmin = Provider.of<SchoolAdminProvider>(context);
    final List<GradeLevelModel> grades = schoolAdmin.grades;

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
                // 📸 Profile picture — tap anywhere on avatar or label to pick
                Center(
                  child: Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _selectPhoto,
                          customBorder: const CircleBorder(),
                          child: Stack(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          AppTheme.primaryBlue.withOpacity(0.3),
                                      width: 3),
                                  color: isDark
                                      ? AppTheme.darkSurface
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(55),
                                  child: _imageBytes != null
                                      ? Image.memory(_imageBytes!,
                                          fit: BoxFit.cover,
                                          width: 110,
                                          height: 110)
                                      : Icon(
                                          Icons.child_care_rounded,
                                          size: 56,
                                          color: isDark
                                              ? Colors.white24
                                              : Colors.grey[300],
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectPhoto,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(
                            _imageBytes != null
                                ? 'Change Photo'
                                : 'Upload Child Photo',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

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
                    labelText: "Grade Level",
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
                    'School setup not ready. Ask admin to load the Grades 1–5 catalog.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    ),
                  ),
                ],

                if (_selectedGradeId != null) ...[
                  const SizedBox(height: 28),
                  GradeTeacherPreviewPanel(
                    preview: _gradePreview,
                    isLoading: _loadingPreview,
                  ),
                ],

                const SizedBox(height: 24),

                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  initiallyExpanded: _vaccinesExpanded,
                  onExpansionChanged: (v) => setState(() => _vaccinesExpanded = v),
                  title: Text(
                    'Immunizations (optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: const Text(
                    'Tap to record vaccinations',
                    style: TextStyle(fontSize: 12),
                  ),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark ? Colors.transparent : Colors.grey[200]!),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _vaccinesList.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.grey[100],
                        ),
                        itemBuilder: (context, index) {
                          final item = _vaccinesList[index];
                          return CheckboxListTile(
                            value: item['checked'],
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w500),
                            ),
                            activeColor: AppTheme.primaryBlue,
                            checkColor: Colors.white,
                            onChanged: (val) {
                              setState(() {
                                _vaccinesList[index]['checked'] = val;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
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
                    onPressed:
                        childProvider.isLoading ? null : _submitChildForm,
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
