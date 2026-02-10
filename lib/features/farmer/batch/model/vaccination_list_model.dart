import 'package:agriflock360/core/utils/date_util.dart';

class VaccinationListResponse {
  final List<VaccinationListItem> list;
  final VaccinationListCounts counts;

  VaccinationListResponse({
    required this.list,
    required this.counts,
  });

  factory VaccinationListResponse.fromJson(Map<String, dynamic> json) {
    return VaccinationListResponse(
      list: (json['list'] as List)
          .map((item) => VaccinationListItem.fromJson(item))
          .toList(),
      counts: VaccinationListCounts.fromJson(json['counts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((item) => item.toJson()).toList(),
      'counts': counts.toJson(),
    };
  }
}

class VaccinationListItem {
  final String id;
  final String vaccineName;
  final String method;
  final String dosagePerBird;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String status;
  final bool isOverdue;
  final bool isToday;
  final DateTime? administeredAt;

  VaccinationListItem({
    required this.id,
    required this.vaccineName,
    required this.method,
    required this.dosagePerBird,
    this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.isOverdue,
    required this.isToday,
    this.administeredAt,
  });

  factory VaccinationListItem.fromJson(Map<String, dynamic> json) {
    return VaccinationListItem(
      id: json['id'] as String,
      vaccineName: json['vaccine_name'] as String,
      method: json['method'] as String,
      dosagePerBird: json['dosage_per_bird'] as String,
      scheduledDate: DateUtil.parseISODate(json['scheduled_date']),
      scheduledTime: json['scheduled_time'] as String,
      status: json['status'],
      isOverdue: json['is_overdue'] as bool,
      isToday: json['is_today'] as bool,
      administeredAt: json['administered_at'] != null
          ? DateUtil.parseISODate(json['administered_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccine_name': vaccineName,
      'method': method,
      'dosage_per_bird': dosagePerBird,
      'scheduled_date': DateUtil.toISO8601(scheduledDate!),
      'scheduled_time': scheduledTime,
      'status': status,
      'is_overdue': isOverdue,
      'is_today': isToday,
      'administered_at':
      administeredAt != null ? DateUtil.toISO8601(administeredAt!) : null,
    };
  }
}

class VaccinationListCounts {
  final int today;
  final int overdue;
  final int upcoming;
  final int completed;

  VaccinationListCounts({
    required this.today,
    required this.overdue,
    required this.upcoming,
    required this.completed,
  });

  factory VaccinationListCounts.fromJson(Map<String, dynamic> json) {
    return VaccinationListCounts(
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

enum VaccinationListFilter {
  upcoming('upcoming'),
  history('history');

  final String value;
  const VaccinationListFilter(this.value);

  static VaccinationListFilter fromString(String value) {
    switch (value) {
      case 'upcoming':
        return VaccinationListFilter.upcoming;
      case 'history':
        return VaccinationListFilter.history;
      default:
        throw ArgumentError('Invalid filter value: $value');
    }
  }
}

