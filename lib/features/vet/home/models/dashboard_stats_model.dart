import 'package:flutter/material.dart';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

class VetDashboardStats {
  final int todayVisits;
  final int weekVisits;
  final int pendingReports;
  final double totalEarningsThisMonth;
  final double completedEarnings;
  final double pendingEarnings;
  final List<VisitDashboard> activeAppointments;

  VetDashboardStats({
    required this.todayVisits,
    required this.weekVisits,
    required this.pendingReports,
    required this.totalEarningsThisMonth,
    required this.completedEarnings,
    required this.pendingEarnings,
    required this.activeAppointments,
  });

  factory VetDashboardStats.fromJson(Map<String, dynamic> json) {
    final appointmentsList = TypeUtils.toListSafe<dynamic>(json['active_appointments']);

    return VetDashboardStats(
      todayVisits: TypeUtils.toIntSafe(json['today_visits']),
      weekVisits: TypeUtils.toIntSafe(json['week_visits']),
      pendingReports: TypeUtils.toIntSafe(json['pending_reports']),
      totalEarningsThisMonth: TypeUtils.toDoubleSafe(json['total_earnings_this_month']),
      completedEarnings: TypeUtils.toDoubleSafe(json['completed_earnings']),
      pendingEarnings: TypeUtils.toDoubleSafe(json['pending_earnings']),
      activeAppointments: appointmentsList
          .map((item) => VisitDashboard.fromJson(
          item is Map<String, dynamic> ? item : {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_visits': todayVisits,
      'week_visits': weekVisits,
      'pending_reports': pendingReports,
      'total_earnings_this_month': totalEarningsThisMonth,
      'completed_earnings': completedEarnings,
      'pending_earnings': pendingEarnings,
      'active_appointments': activeAppointments.map((v) => v.toJson()).toList(),
    };
  }

  // Since API only gives PENDING and IN_PROGRESS for today
  bool get hasActiveAppointments => activeAppointments.isNotEmpty;

  int get pendingAppointmentsCount => activeAppointments
      .where((appointment) => appointment.isPending)
      .length;

  int get inProgressAppointmentsCount => activeAppointments
      .where((appointment) => appointment.isInProgress)
      .length;

  List<VisitDashboard> get pendingAppointments => activeAppointments
      .where((appointment) => appointment.isPending)
      .toList();

  List<VisitDashboard> get inProgressAppointments => activeAppointments
      .where((appointment) => appointment.isInProgress)
      .toList();

  List<VisitDashboard> get todayAppointments => activeAppointments;

  // Get appointments for specific status
  List<VisitDashboard> getAppointmentsByStatus(String status) {
    return activeAppointments.where((appointment) =>
    appointment.status.toUpperCase() == status.toUpperCase()
    ).toList();
  }

  // Utility method to check if a specific appointment has a specific status
  bool isAppointmentInStatus(String appointmentId, String status) {
    return activeAppointments.any(
          (appointment) =>
      appointment.id == appointmentId &&
          appointment.status.toUpperCase() == status.toUpperCase(),
    );
  }

  // Utility to get appointment by ID
  VisitDashboard? getAppointmentById(String appointmentId) {
    try {
      return activeAppointments.firstWhere(
            (appointment) => appointment.id == appointmentId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get appointments by service type
  List<VisitDashboard> getAppointmentsByServiceType(String serviceType) {
    return activeAppointments.where(
          (appointment) => appointment.serviceType.toUpperCase() == serviceType.toUpperCase(),
    ).toList();
  }
}

class VisitDashboard {
  final String id;
  final String farmerName;
  final String farmName;
  final int birdCount;
  final String preferredDate;
  final String preferredTime;
  final String? scheduledTime;
  final String status;
  final String serviceType;

  VisitDashboard({
    required this.id,
    required this.farmerName,
    required this.farmName,
    required this.birdCount,
    required this.preferredDate,
    required this.preferredTime,
    this.scheduledTime,
    required this.status,
    required this.serviceType,
  });

  factory VisitDashboard.fromJson(Map<String, dynamic> json) {
    return VisitDashboard(
      id: TypeUtils.toStringSafe(json['id']),
      farmerName: TypeUtils.toStringSafe(json['farmer_name']),
      farmName: TypeUtils.toStringSafe(json['farm_name']),
      birdCount: TypeUtils.toIntSafe(json['bird_count']),
      preferredDate: TypeUtils.toStringSafe(json['preferred_date']),
      preferredTime: TypeUtils.toStringSafe(json['preferred_time']),
      scheduledTime: TypeUtils.toNullableStringSafe(json['scheduled_time']),
      status: TypeUtils.toStringSafe(json['status']),
      serviceType: TypeUtils.toStringSafe(json['service_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_name': farmerName,
      'farm_name': farmName,
      'bird_count': birdCount,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'scheduled_time': scheduledTime,
      'status': status,
      'service_type': serviceType,
    };
  }

  // Status checking utilities - only for statuses we actually get
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';

  // Simplified utilities since API only gives PENDING and IN_PROGRESS
  bool get isActive => isInProgress;
  bool get needsAction => isPending;

  // Time utilities
  bool get hasScheduledTime => scheduledTime != null;

  DateTime? get preferredDateTime {
    if (preferredDate.isEmpty || preferredTime.isEmpty) return null;
    try {
      return DateTime.parse('$preferredDate $preferredTime');
    } catch (e) {
      return null;
    }
  }

  DateTime? get scheduledDateTime {
    if (preferredDate.isEmpty || scheduledTime == null) return null;
    try {
      return DateTime.parse('$preferredDate $scheduledTime');
    } catch (e) {
      return null;
    }
  }

  // Get display time (scheduled if available, otherwise preferred)
  String get displayTime {
    if (hasScheduledTime && scheduledTime != null) {
      return scheduledTime!;
    }
    return preferredTime;
  }

  // Get status display text
  String get statusDisplayText {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      default:
        return status;
    }
  }

  // Get status color
  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}