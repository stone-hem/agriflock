import 'package:agriflock/core/utils/type_safe_utils.dart';

class VetReport {
  final String id;
  final String visitNumber;
  final String orderId;
  final VetReportOrder? order;
  final VetReportOfficer officer;
  final String officerId;
  final String farmerId;
  final String? houseId;
  final String? batchId;
  final String? farmId;
  final String visitDate;
  final String visitType;
  final String requestedBy;
  final List<String> farmerComplaints;
  final String? farmerComplaintOther;
  final Map<String, String> observations;
  final String? abnormalFindingsNotes;
  final List<String> suspectedIssues;
  final List<String> actionsTaken;
  final String? recommendation1;
  final String? recommendation2;
  final bool officerSigned;
  final bool farmerConfirmed;
  final String? followUpDate;
  final String? followUpNotes;
  final String status;
  final String createdAt;

  VetReport({
    required this.id,
    required this.visitNumber,
    required this.orderId,
    this.order,
    required this.officer,
    required this.officerId,
    required this.farmerId,
    this.houseId,
    this.batchId,
    this.farmId,
    required this.visitDate,
    required this.visitType,
    required this.requestedBy,
    required this.farmerComplaints,
    this.farmerComplaintOther,
    required this.observations,
    this.abnormalFindingsNotes,
    required this.suspectedIssues,
    required this.actionsTaken,
    this.recommendation1,
    this.recommendation2,
    required this.officerSigned,
    required this.farmerConfirmed,
    this.followUpDate,
    this.followUpNotes,
    required this.status,
    required this.createdAt,
  });

  factory VetReport.fromJson(Map<String, dynamic> json) {
    final officerJson = json['officer'];
    final orderJson = json['order'];

    // observations is Map<String, dynamic> in JSON
    final obsRaw = json['observations'];
    final observations = <String, String>{};
    if (obsRaw is Map) {
      obsRaw.forEach((k, v) => observations[k.toString()] = v.toString());
    }

    return VetReport(
      id: TypeUtils.toStringSafe(json['id']),
      visitNumber: TypeUtils.toStringSafe(json['visit_number']),
      orderId: TypeUtils.toStringSafe(json['order_id']),
      order: orderJson is Map<String, dynamic>
          ? VetReportOrder.fromJson(orderJson)
          : null,
      officer: officerJson is Map<String, dynamic>
          ? VetReportOfficer.fromJson(officerJson)
          : VetReportOfficer(id: '', name: 'Unknown', educationLevel: '', yearsOfExperience: 0),
      officerId: TypeUtils.toStringSafe(json['officer_id']),
      farmerId: TypeUtils.toStringSafe(json['farmer_id']),
      houseId: TypeUtils.toNullableStringSafe(json['house_id']),
      batchId: TypeUtils.toNullableStringSafe(json['batch_id']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      visitDate: TypeUtils.toStringSafe(json['visit_date']),
      visitType: TypeUtils.toStringSafe(json['visit_type']),
      requestedBy: TypeUtils.toStringSafe(json['requested_by']),
      farmerComplaints: TypeUtils.toListSafe<String>(json['farmer_complaints'])
          .map((e) => e.toString())
          .toList(),
      farmerComplaintOther: TypeUtils.toNullableStringSafe(json['farmer_complaint_other']),
      observations: observations,
      abnormalFindingsNotes: TypeUtils.toNullableStringSafe(json['abnormal_findings_notes']),
      suspectedIssues: TypeUtils.toListSafe<String>(json['suspected_issues'])
          .map((e) => e.toString())
          .toList(),
      actionsTaken: TypeUtils.toListSafe<String>(json['actions_taken'])
          .map((e) => e.toString())
          .toList(),
      recommendation1: TypeUtils.toNullableStringSafe(json['recommendation_1']),
      recommendation2: TypeUtils.toNullableStringSafe(json['recommendation_2']),
      officerSigned: json['officer_signed'] == true,
      farmerConfirmed: json['farmer_confirmed'] == true,
      followUpDate: TypeUtils.toNullableStringSafe(json['follow_up_date']),
      followUpNotes: TypeUtils.toNullableStringSafe(json['follow_up_notes']),
      status: TypeUtils.toStringSafe(json['status']),
      createdAt: TypeUtils.toStringSafe(json['created_at']),
    );
  }

  String get visitDateFormatted {
    try {
      final dt = DateTime.parse(visitDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return visitDate.split('T').first;
    }
  }

  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return 'Draft';
      case 'SUBMITTED':
        return 'Submitted';
      case 'REVIEWED':
        return 'Reviewed';
      default:
        return status;
    }
  }
}

class VetReportOrder {
  final String id;
  final String orderNumber;
  final List<VetReportBatchDetail> batchDetails;

  VetReportOrder({
    required this.id,
    required this.orderNumber,
    required this.batchDetails,
  });

  factory VetReportOrder.fromJson(Map<String, dynamic> json) {
    final rawBatches = TypeUtils.toListSafe<dynamic>(json['batch_details']);
    return VetReportOrder(
      id: TypeUtils.toStringSafe(json['id']),
      orderNumber: TypeUtils.toStringSafe(json['order_number']),
      batchDetails: rawBatches
          .whereType<Map<String, dynamic>>()
          .map(VetReportBatchDetail.fromJson)
          .toList(),
    );
  }
}

class VetReportBatchDetail {
  final String batchId;
  final String batchName;
  final String birdTypeName;
  final int birdsCount;

  VetReportBatchDetail({
    required this.batchId,
    required this.batchName,
    required this.birdTypeName,
    required this.birdsCount,
  });

  factory VetReportBatchDetail.fromJson(Map<String, dynamic> json) {
    return VetReportBatchDetail(
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      batchName: TypeUtils.toStringSafe(json['batch_name']),
      birdTypeName: TypeUtils.toStringSafe(json['bird_type_name']),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
    );
  }
}

class VetReportOfficer {
  final String id;
  final String name;
  final String educationLevel;
  final int yearsOfExperience;

  VetReportOfficer({
    required this.id,
    required this.name,
    required this.educationLevel,
    required this.yearsOfExperience,
  });

  factory VetReportOfficer.fromJson(Map<String, dynamic> json) {
    return VetReportOfficer(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      educationLevel: TypeUtils.toStringSafe(json['education_level']),
      yearsOfExperience: TypeUtils.toIntSafe(json['years_of_experience']),
    );
  }
}
