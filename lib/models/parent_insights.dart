import 'package:flutter/material.dart';

enum TimelineEventType { academic, health, billing, general }

class TimelineEvent {
  final String title;
  final String description;
  final DateTime date;
  final TimelineEventType type;
  final IconData icon;

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.icon,
  });
}

class SubjectGrade {
  final String subject;
  final double score;
  final double previousScore;

  const SubjectGrade({
    required this.subject,
    required this.score,
    required this.previousScore,
  });

  double get change => score - previousScore;
}

class InvoiceItem {
  final String id;
  final String title;
  final String childName;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;

  const InvoiceItem({
    required this.id,
    required this.title,
    required this.childName,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
  });

  String get amountDisplay => '\$${amount.toStringAsFixed(2)}';
}
