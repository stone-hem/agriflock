import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

class VaccinationListResponse {
  final List<VaccinationListItem> list;
  final List<dynamic> upcomingFromPlan; // Added missing field
  final VaccinationListCounts counts;

  VaccinationListResponse({
    required this.list,
    required this.upcomingFromPlan, // Added
    required this.counts,
  });

  factory VaccinationListResponse.fromJson(Map<String, dynamic> json) {
    return VaccinationListResponse(
      list: TypeUtils.toListSafe<Map<String, dynamic>>(json['list'])
          .map((item) => VaccinationListItem.fromJson(item))
          .toList(),
      upcomingFromPlan: TypeUtils.toListSafe(json['upcoming_from_plan']),
      counts: VaccinationListCounts.fromJson(TypeUtils.toMapSafe(json['counts']) ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((item) => item.toJson()).toList(),
      'upcoming_from_plan': upcomingFromPlan, // Added
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
  final DateTime? completedDate; // Added missing field
  final String? completedTime; // Added missing field
  final bool isOverdue;
  final bool isToday;
  final DateTime? administeredAt;

  VaccinationListItem({
    required this.id,
    required this.vaccineName,
    required this.method,
    required this.dosagePerBird,
    this.scheduledDate,
    this.scheduledTime,
    required this.status,
    this.completedDate, // Added
    this.completedTime, // Added
    required this.isOverdue,
    required this.isToday,
    this.administeredAt,
  });

  factory VaccinationListItem.fromJson(Map<String, dynamic> json) {
    return VaccinationListItem(
      id: TypeUtils.toStringSafe(json['id']),
      vaccineName: TypeUtils.toStringSafe(json['vaccine_name']),
      method: TypeUtils.toStringSafe(json['method']),
      dosagePerBird: TypeUtils.toStringSafe(json['dosage_per_bird']),
      scheduledDate: TypeUtils.toDateTimeSafe(json['scheduled_date']),
      scheduledTime: TypeUtils.toNullableStringSafe(json['scheduled_time']),
      status: TypeUtils.toStringSafe(json['status']),
      completedDate: TypeUtils.toDateTimeSafe(json['completed_date']),
      completedTime: TypeUtils.toNullableStringSafe(json['completed_time']),
      isOverdue: TypeUtils.toBoolSafe(json['is_overdue']),
      isToday: TypeUtils.toBoolSafe(json['is_today']),
      administeredAt: TypeUtils.toDateTimeSafe(json['administered_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccine_name': vaccineName,
      'method': method,
      'dosage_per_bird': dosagePerBird,
      'scheduled_date': scheduledDate != null ? DateUtil.toISO8601(scheduledDate!) : null,
      'scheduled_time': scheduledTime,
      'status': status,
      'completed_date': completedDate != null // Added
          ? DateUtil.toISO8601(completedDate!) : null,
      'completed_time': completedTime, // Added
      'is_overdue': isOverdue,
      'is_today': isToday,
      'administered_at': administeredAt != null ? DateUtil.toISO8601(administeredAt!) : null,
    };
  }
}

class VaccinationListCounts {
  final int today;
  final int overdue;
  final int upcoming;
  final int completed;
  final int upcomingFromPlan; // Added missing field

  VaccinationListCounts({
    required this.today,
    required this.overdue,
    required this.upcoming,
    required this.completed,
    required this.upcomingFromPlan, // Added
  });

  factory VaccinationListCounts.fromJson(Map<String, dynamic> json) {
    return VaccinationListCounts(
      today: TypeUtils.toIntSafe(json['today']),
      overdue: TypeUtils.toIntSafe(json['overdue']),
      upcoming: TypeUtils.toIntSafe(json['upcoming']),
      completed: TypeUtils.toIntSafe(json['completed']),
      upcomingFromPlan: TypeUtils.toIntSafe(json['upcoming_from_plan']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'overdue': overdue,
      'upcoming': upcoming,
      'completed': completed,
      'upcoming_from_plan': upcomingFromPlan, // Added
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