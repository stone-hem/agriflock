import 'dart:convert';


class VaccinationDashboardSummary {
  final int completed;
  final int upcoming;
  final int overdue;
  final String coveragePercentage;
  final int uniqueVaccinatedBirds;

  VaccinationDashboardSummary({
    required this.completed,
    required this.upcoming,
    required this.overdue,
    required this.coveragePercentage,
    required this.uniqueVaccinatedBirds,
  });

  factory VaccinationDashboardSummary.fromJson(Map<String, dynamic> json) {
    return VaccinationDashboardSummary(
      completed: json['completed'],
      upcoming: json['upcoming'],
      overdue: json['overdue'],
      coveragePercentage: json['coverage_percentage'],
      uniqueVaccinatedBirds: json['unique_vaccinated_birds'],
    );
  }
}

class VaccinationDashboard {
  final VaccinationDashboardSummary summary;
  final int totalBirds;
  final String batchName;

  VaccinationDashboard({
    required this.summary,
    required this.totalBirds,
    required this.batchName,
  });

  factory VaccinationDashboard.fromJson(Map<String, dynamic> json) {
    return VaccinationDashboard(
      summary: VaccinationDashboardSummary.fromJson(json['summary']),
      totalBirds: json['total_birds'],
      batchName: json['batch_name'],
    );
  }
}

class CreateVaccinationRequest {
  final String vaccineName;
  final String vaccineType;
  final String scheduledDate;
  final String dosage;
  final String administrationMethod;
  final double cost;
  final String? notes;
  final String source;

  CreateVaccinationRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.scheduledDate,
    required this.dosage,
    required this.administrationMethod,
    required this.cost,
    this.notes,
    this.source = 'manual',
  });

  Map<String, dynamic> toJson() {
    return {
      'vaccine_name': vaccineName,
      'vaccine_type': vaccineType,
      'scheduled_date': scheduledDate,
      'dosage': dosage,
      'administration_method': administrationMethod,
      'cost': cost,
      if (notes != null) 'notes': notes,
      'source': source,
    };
  }
}


class UpdateVaccinationStatusRequest {
  final String status;
  final String? actualDate;
  final String? actualTime;
  final int? birdsVaccinated;
  final String? administeredBy;
  final String? notes;
  final String? failureReason;
  final String? cancellationReason;
  final bool? rescheduleAfterFailure;
  final String? newScheduledDate;
  final String? newScheduledTime;
  final String? rescheduleReason;

  UpdateVaccinationStatusRequest({
    required this.status,
    this.actualDate,
    this.actualTime,
    this.birdsVaccinated,
    this.administeredBy,
    this.notes,
    this.failureReason,
    this.cancellationReason,
    this.rescheduleAfterFailure,
    this.newScheduledDate,
    this.newScheduledTime,
    this.rescheduleReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (actualDate != null) 'actual_date': actualDate,
      if (actualTime != null) 'actual_time': actualTime,
      if (birdsVaccinated != null) 'birds_vaccinated': birdsVaccinated,
      if (administeredBy != null) 'administered_by': administeredBy,
      if (notes != null) 'notes': notes,
      if (failureReason != null) 'failure_reason': failureReason,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      if (rescheduleAfterFailure != null)
        'reschedule_after_failure': rescheduleAfterFailure,
      if (newScheduledDate != null) 'new_scheduled_date': newScheduledDate,
      if (newScheduledTime != null) 'new_scheduled_time': newScheduledTime,
      if (rescheduleReason != null) 'reschedule_reason': rescheduleReason,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class VaccinationScheduleRequest {
  final String vaccineName;
  final String vaccineType;
  final String scheduledDate;
  final String scheduleTime;
  final String dosage;
  final String administrationMethod;
  final String? notes;
  final String source;

  VaccinationScheduleRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.scheduledDate,
    required this.dosage,
    required this.administrationMethod,
    this.notes,
    this.source = 'manual',
    required this.scheduleTime,
  });

  Map<String, dynamic> toJson() => {
    'vaccine_name': vaccineName,
    'vaccine_type': vaccineType,
    'scheduled_date': scheduledDate,
    'scheduled_time': scheduleTime,
    'dosage': dosage,
    'administration_method': administrationMethod,
    'notes': notes,
    'source': source,
  };
}

class QuickDoneVaccinationRequest {
  final String vaccineName;
  final String vaccineType;
  final String dosage;
  final String administrationMethod;
  final int birdsVaccinated;
  final String completedDate;
  final String completedTime;
  final String? notes;

  QuickDoneVaccinationRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.dosage,
    required this.administrationMethod,
    required this.birdsVaccinated,
    required this.completedDate,
    this.notes, required this.completedTime,
  });

  Map<String, dynamic> toJson() => {
    'vaccine_name': vaccineName,
    'vaccine_type': vaccineType,
    'completed_date': completedDate,
    'completed_time': completedTime,
    'dosage': dosage,
    'birds_vaccinated':birdsVaccinated,
    'administration_method': administrationMethod,
    'notes': notes,
    'source': 'manual'
  };
}