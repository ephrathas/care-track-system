import 'package:flutter/material.dart';

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

/// In-memory gamification state for the child dashboard (Firebase-ready later).
class ChildGamificationProvider extends ChangeNotifier {
  static const int xpPerLevel = 500;

  int currentXp = 340;
  int currentLevel = 3;

  final List<ChildQuest> quests = [
    ChildQuest(
      id: 'T1',
      title: 'Solve Math Fractions Worksheet',
      subject: 'Mathematics',
      xp: 50,
      dueDate: 'Due tomorrow',
      color: const Color(0xFF4A90E2),
    ),
    ChildQuest(
      id: 'T2',
      title: 'Read Chapter 4 English Book',
      subject: 'English Language',
      xp: 40,
      dueDate: 'Due in 2 days',
      color: const Color(0xFF7ED321),
    ),
    ChildQuest(
      id: 'T3',
      title: 'Plant Experiment Journal',
      subject: 'Natural Sciences',
      xp: 80,
      dueDate: 'Due in 4 days',
      color: const Color(0xFF9013FE),
    ),
  ];

  final List<ChildBadge> badges = [
    ChildBadge(
      title: 'Math Whiz',
      description: 'Complete all fractions assignments',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF4A90E2),
      unlocked: true,
    ),
    ChildBadge(
      title: 'Perfect Attendance',
      description: 'Check in every day for 2 consecutive weeks',
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF7ED321),
      unlocked: true,
    ),
    ChildBadge(
      title: 'Star Student',
      description: 'Scored over 95% on Grade 3 English exam',
      icon: Icons.star_rounded,
      color: Colors.amber,
      unlocked: true,
    ),
    ChildBadge(
      title: 'Helper Bee',
      description: 'Marked helpful in classroom peer activities',
      icon: Icons.pest_control_rodent_rounded,
      color: Colors.pinkAccent,
      unlocked: true,
    ),
    ChildBadge(
      title: 'Science Explorer',
      description: 'Finish the Planet Earth Science project',
      icon: Icons.biotech_rounded,
      color: const Color(0xFF9013FE),
    ),
    ChildBadge(
      title: 'Fast Learner',
      description: 'Submit homework within 2 hours of assignment',
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

  /// Returns newly unlocked badge title, if any. Sets [didLevelUp] when level increases.
  String? completeQuest(String id, {required void Function() onLevelUp}) {
    final quest = quests.firstWhere((q) => q.id == id);
    if (quest.completed) return null;

    quest.completed = true;
    currentXp += quest.xp;

    String? unlockedBadge;
    if (id == 'T3') {
      final badge = badges.firstWhere((b) => b.title == 'Science Explorer');
      if (!badge.unlocked) {
        badge.unlocked = true;
        unlockedBadge = badge.title;
      }
    }
    if (quests.every((q) => q.completed)) {
      final badge = badges.firstWhere((b) => b.title == 'Fast Learner');
      if (!badge.unlocked) {
        badge.unlocked = true;
        unlockedBadge ??= badge.title;
      }
    }

    if (currentXp >= xpPerLevel) {
      currentLevel++;
      currentXp -= xpPerLevel;
      onLevelUp();
    }

    notifyListeners();
    return unlockedBadge;
  }
}
