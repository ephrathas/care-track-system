import 'dart:async';

import 'package:flutter/material.dart';

import '../data/firestore/firestore_academic_repository.dart';
import '../models/academic_models.dart';

class ChildQuest {
  final String id;
  final String title;
  final String subject;
  final int xp;
  final String dueDate;
  final Color color;
  bool completed;

  ChildQuest({
    required this.id,
    required this.title,
    required this.subject,
    required this.xp,
    required this.dueDate,
    required this.color,
    this.completed = false,
  });
}

class ChildBadge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool unlocked;

  ChildBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
  });
}

class ScheduleItem {
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int hour;
  final int minute;

  const ScheduleItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.hour,
    required this.minute,
  });
}

/// Gamification shell for the child dashboard. Homework quests load from Firestore
/// when the student account is linked and enrolled in a class.
class ChildGamificationProvider extends ChangeNotifier {
  static const int xpPerLevel = 500;

  static const _questColors = [
    Color(0xFF4A90E2),
    Color(0xFF7ED321),
    Color(0xFF9013FE),
    Color(0xFFE2894A),
    Color(0xFF50E3C2),
  ];

  final FirestoreAcademicRepository _academic = FirestoreAcademicRepository();

  int currentXp = 120;
  int currentLevel = 2;

  final List<ChildQuest> quests = [];
  final Set<String> _completedQuestIds = {};

  bool isLiveHomework = false;
  bool isHomeworkLoading = false;
  String? homeworkStatusMessage;

  StreamSubscription<List<AssignmentModel>>? _homeworkSub;

  final List<ChildBadge> badges = [
    ChildBadge(
      title: 'Math Whiz',
      description: 'Complete 3 homework quests',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF4A90E2),
    ),
    ChildBadge(
      title: 'Perfect Attendance',
      description: 'Check in every day for 2 consecutive weeks',
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF7ED321),
    ),
    ChildBadge(
      title: 'Star Student',
      description: 'Score 90%+ on a published grade',
      icon: Icons.star_rounded,
      color: Colors.amber,
    ),
    ChildBadge(
      title: 'Helper Bee',
      description: 'Marked helpful in classroom peer activities',
      icon: Icons.pest_control_rodent_rounded,
      color: Colors.pinkAccent,
    ),
    ChildBadge(
      title: 'Science Explorer',
      description: 'Finish a science homework quest',
      icon: Icons.biotech_rounded,
      color: const Color(0xFF9013FE),
    ),
    ChildBadge(
      title: 'Fast Learner',
      description: 'Complete all homework quests for your class',
      icon: Icons.bolt_rounded,
      color: Colors.cyan,
    ),
  ];

  static const schedule = [
    ScheduleItem(
      time: '08:30 AM',
      title: 'Mathematics Class',
      subtitle: 'Learn divisions',
      icon: Icons.calculate_rounded,
      color: Color(0xFF4A90E2),
      hour: 8,
      minute: 30,
    ),
    ScheduleItem(
      time: '10:00 AM',
      title: 'Recess & Playtime',
      subtitle: 'Outdoor games',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF7ED321),
      hour: 10,
      minute: 0,
    ),
    ScheduleItem(
      time: '11:00 AM',
      title: 'Reading Session',
      subtitle: 'Storytelling module',
      icon: Icons.auto_stories_rounded,
      color: Color(0xFF9013FE),
      hour: 11,
      minute: 0,
    ),
    ScheduleItem(
      time: '01:30 PM',
      title: 'Creative Arts',
      subtitle: 'Watercolor painting',
      icon: Icons.palette_rounded,
      color: Color(0xFFE2894A),
      hour: 13,
      minute: 30,
    ),
  ];

  int get unlockedBadgeCount => badges.where((b) => b.unlocked).length;

  int get pendingQuestCount => quests.where((q) => !q.completed).length;

  double get xpProgress => (currentXp / xpPerLevel).clamp(0.0, 1.0);

  String get rankTitle {
    if (currentLevel >= 5) return 'Legend';
    if (currentLevel >= 4) return 'Elite IV';
    if (currentLevel >= 3) return 'Elite III';
    if (currentLevel >= 2) return 'Rising Star';
    return 'New Explorer';
  }

  ScheduleItem? get currentScheduleItem {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    ScheduleItem? active;
    for (final item in schedule) {
      final itemMinutes = item.hour * 60 + item.minute;
      if (itemMinutes <= nowMinutes) active = item;
    }
    return active;
  }

  ScheduleItem? get nextScheduleItem {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (final item in schedule) {
      final itemMinutes = item.hour * 60 + item.minute;
      if (itemMinutes > nowMinutes) return item;
    }
    return null;
  }

  void bindHomework({
    required bool isAccountLinked,
    required String? studentId,
    required String? classRoomId,
    required String? Function(String subjectId) subjectNameFor,
  }) {
    _homeworkSub?.cancel();
    _homeworkSub = null;
    quests.clear();
    isLiveHomework = false;
    isHomeworkLoading = false;
    homeworkStatusMessage = null;

    if (!isAccountLinked || studentId == null || studentId.isEmpty) {
      homeworkStatusMessage =
          'Link your school profile with the code from your parent to see real homework.';
      notifyListeners();
      return;
    }

    if (classRoomId == null || classRoomId.isEmpty) {
      isLiveHomework = true;
      homeworkStatusMessage =
          'Your parent needs to enroll you in a class before homework appears here.';
      notifyListeners();
      return;
    }

    isLiveHomework = true;
    isHomeworkLoading = true;
    notifyListeners();

    _homeworkSub = _academic.watchAssignmentsForStudent(studentId).listen(
      (assignments) {
        _syncQuestsFromAssignments(assignments, subjectNameFor);
        isHomeworkLoading = false;
        homeworkStatusMessage = assignments.isEmpty
            ? 'No homework from your teachers yet — check back soon!'
            : null;
        notifyListeners();
      },
      onError: (_) {
        isHomeworkLoading = false;
        homeworkStatusMessage = 'Could not load homework. Pull to refresh later.';
        notifyListeners();
      },
    );
  }

  void unbindHomework() {
    _homeworkSub?.cancel();
    _homeworkSub = null;
    quests.clear();
    isLiveHomework = false;
    isHomeworkLoading = false;
    homeworkStatusMessage = null;
    notifyListeners();
  }

  void _syncQuestsFromAssignments(
    List<AssignmentModel> assignments,
    String? Function(String subjectId) subjectNameFor,
  ) {
    final previousCompleted = Set<String>.from(_completedQuestIds);
    quests.clear();

    for (var i = 0; i < assignments.length; i++) {
      final a = assignments[i];
      final subject = subjectNameFor(a.subjectId) ?? 'Subject';
      quests.add(
        ChildQuest(
          id: a.id,
          title: a.title,
          subject: subject,
          xp: 40 + (i % 4) * 10,
          dueDate: _dueLabel(a.dueAt),
          color: _questColors[i % _questColors.length],
          completed: previousCompleted.contains(a.id),
        ),
      );
    }
  }

  static String _dueLabel(DateTime? due) {
    if (due == null) return 'No due date';
    final diff = due.difference(DateTime.now());
    if (diff.inDays < 0) return 'Overdue';
    if (diff.inHours < 24 && diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due in ${diff.inDays} days';
  }

  String? completeQuest(String id, {required void Function() onLevelUp}) {
    ChildQuest? quest;
    for (final q in quests) {
      if (q.id == id) {
        quest = q;
        break;
      }
    }
    if (quest == null || quest.completed) return null;

    quest.completed = true;
    _completedQuestIds.add(id);
    currentXp += quest.xp;

    String? unlockedBadge;
    final completedCount = quests.where((q) => q.completed).length;

    if (quest.subject.toLowerCase().contains('science')) {
      unlockedBadge = _unlockBadge('Science Explorer') ?? unlockedBadge;
    }
    if (completedCount >= 3) {
      unlockedBadge = _unlockBadge('Math Whiz') ?? unlockedBadge;
    }
    if (quests.isNotEmpty && quests.every((q) => q.completed)) {
      unlockedBadge = _unlockBadge('Fast Learner') ?? unlockedBadge;
    }

    if (currentXp >= xpPerLevel) {
      currentLevel++;
      currentXp -= xpPerLevel;
      onLevelUp();
    }

    notifyListeners();
    return unlockedBadge;
  }

  String? _unlockBadge(String title) {
    final badge = badges.firstWhere((b) => b.title == title);
    if (badge.unlocked) return null;
    badge.unlocked = true;
    return badge.title;
  }

  @override
  void dispose() {
    _homeworkSub?.cancel();
    super.dispose();
  }
}
