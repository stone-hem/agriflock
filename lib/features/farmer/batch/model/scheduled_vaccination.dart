// vaccination_schedule_response.dart
class VaccinationScheduleResponse {
  final List<VaccinationSchedule> list;
  final ScheduleCounts counts;

  VaccinationScheduleResponse({
    required this.list,
    required this.counts,
  });

  factory VaccinationScheduleResponse.fromJson(Map<String, dynamic> json) {
    return VaccinationScheduleResponse(
      list: (json['list'] as List<dynamic>)
          .map((item) => VaccinationSchedule.fromJson(item))
          .toList(),
      counts: ScheduleCounts.fromJson(json['counts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((item) => item.toJson()).toList(),
      'counts': counts.toJson(),
    };
  }
}

class VaccinationSchedule {
  final String id;
  final String vaccineName;
  final String method;
  final String dosagePerBird;
  final String scheduledDate;
  final String scheduledTime;
  final String status;
  final bool isOverdue;
  final bool isToday;
  final String? administeredAt;

  VaccinationSchedule({
    required this.id,
    required this.vaccineName,
    required this.method,
    required this.dosagePerBird,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.isOverdue,
    required this.isToday,
    this.administeredAt,
  });

  factory VaccinationSchedule.fromJson(Map<String, dynamic> json) {
    return VaccinationSchedule(
      id: json['id'] as String,
      vaccineName: json['vaccine_name'] as String,
      method: json['method'] as String,
      dosagePerBird: json['dosage_per_bird'] as String,
      scheduledDate: json['scheduled_date'] as String,
      scheduledTime: json['scheduled_time'] as String,
      status: json['status'] as String,
      isOverdue: json['is_overdue'] as bool,
      isToday: json['is_today'] as bool,
      administeredAt: json['administered_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccine_name': vaccineName,
      'method': method,
      'dosage_per_bird': dosagePerBird,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'status': status,
      'is_overdue': isOverdue,
      'is_today': isToday,
      'administered_at': administeredAt,
    };
  }
}

class ScheduleCounts {
  final int today;
  final int overdue;
  final int upcoming;
  final int completed;

  ScheduleCounts({
    required this.today,
    required this.overdue,
    required this.upcoming,
    required this.completed,
  });

  factory ScheduleCounts.fromJson(Map<String, dynamic> json) {
    return ScheduleCounts(
      today: json['today'] as int,
      overdue: json['overdue'] as int,
      upcoming: json['upcoming'] as int,
      completed: json['completed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'overdue': overdue,
      'upcoming': upcoming,
      'completed': completed,
    };
  }
}