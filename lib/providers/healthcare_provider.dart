import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/child_model.dart';
import '../models/health_appointment_model.dart';
import '../services/database_service.dart';

class HealthcareProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<ChildModel> _patients = [];
  List<HealthAppointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<ChildModel>>? _patientsSubscription;
  StreamSubscription<List<HealthAppointment>>? _appointmentsSubscription;

  List<ChildModel> get patients => _patients;
  List<HealthAppointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get activePatientCount => _patients.length;

  int get totalVaccineRecords =>
      _patients.fold(0, (sum, child) => sum + child.vaccinations.length);

  List<HealthAppointment> get todayAppointments {
    final now = DateTime.now();
    final list = _appointments.where((appointment) {
      return appointment.scheduledAt.year == now.year &&
          appointment.scheduledAt.month == now.month &&
          appointment.scheduledAt.day == now.day;
    }).toList();
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  List<HealthAppointment> get upcomingAppointments {
    final list = List<HealthAppointment>.from(_appointments);
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  void startListening() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _patientsSubscription?.cancel();
    _appointmentsSubscription?.cancel();

    _patientsSubscription = _dbService.getAllChildren().listen(
      (data) {
        _patients = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    _appointmentsSubscription = _dbService.getHealthAppointments().listen(
      (data) {
        _appointments = data;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _patientsSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    _patientsSubscription = null;
    _appointmentsSubscription = null;
    _patients = [];
    _appointments = [];
    _errorMessage = null;
    notifyListeners();
  }

  List<ChildModel> searchPatients(String query) {
    if (query.trim().isEmpty) return _patients;
    final normalized = query.toLowerCase();
    return _patients
        .where((patient) => patient.name.toLowerCase().contains(normalized))
        .toList();
  }

  Future<bool> updateGrowthMetrics({
    required String childId,
    required double height,
    required double weight,
  }) async {
    try {
      await _dbService.updateChildFields(childId, {
        'latestHeight': height,
        'latestWeight': weight,
        'lastCheckup': DateFormat('MMMM dd, yyyy').format(DateTime.now()),
      });
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addVaccine({
    required String childId,
    required String vaccineName,
  }) async {
    try {
      final child = _patients.firstWhere((patient) => patient.id == childId);
      final updated = List<String>.from(child.vaccinations)..add(vaccineName);
      await _dbService.updateChildFields(childId, {'vaccinations': updated});
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> scheduleAppointment({
    required String childId,
    required String childName,
    required String title,
    required DateTime scheduledAt,
  }) async {
    try {
      final appointment = HealthAppointment(
        id: '',
        childId: childId,
        childName: childName,
        title: title,
        scheduledAt: scheduledAt,
      );
      await _dbService.addHealthAppointment(appointment);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _patientsSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    super.dispose();
  }
}
