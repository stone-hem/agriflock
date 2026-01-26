import 'package:flutter/material.dart';

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
    return VetDashboardStats(
      todayVisits: json['today_visits'] as int? ?? 0,
      weekVisits: json['week_visits'] as int? ?? 0,
      pendingReports: json['pending_reports'] as int? ?? 0,
      totalEarningsThisMonth: (json['total_earnings_this_month'] as num?)?.toDouble() ?? 0.0,
      completedEarnings: (json['completed_earnings'] as num?)?.toDouble() ?? 0.0,
      pendingEarnings: (json['pending_earnings'] as num?)?.toDouble() ?? 0.0,
      activeAppointments: (json['active_appointments'] as List<dynamic>?)
          ?.map((item) => VisitDashboard.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
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
      id: json['id'] as String? ?? '',
      farmerName: json['farmer_name'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? '',
      birdCount: json['bird_count'] as int? ?? 0,
      preferredDate: json['preferred_date'] as String? ?? '',
      preferredTime: json['preferred_time'] as String? ?? '',
      scheduledTime: json['scheduled_time'] as String?,
      status: json['status'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
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