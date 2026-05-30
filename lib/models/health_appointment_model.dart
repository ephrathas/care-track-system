import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthAppointment {
  final String id;
  final String childId;
  final String childName;
  final String title;
  final DateTime scheduledAt;
  final String status;
 HealthAppointment({
    required this.id,
    required this.childId,
    required this.childName,
    required this.title,
    required this.scheduledAt,
    this.status = 'Active',
  }); 
}
