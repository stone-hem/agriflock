import 'package:agriflock/core/utils/type_safe_utils.dart';

class DisputeModel {
  final String id;
  final String orderId;
  final String reason;
  final String description;
  final String status;
  final String createdAt;
  final String? resolvedAt;
  final String? resolutionNote;

  const DisputeModel({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: TypeUtils.toStringSafe(json['id']),
      orderId: TypeUtils.toStringSafe(json['order_id']),
      reason: TypeUtils.toStringSafe(json['reason']),
      description: TypeUtils.toStringSafe(json['description']),
      status: TypeUtils.toStringSafe(json['status']),
      createdAt: TypeUtils.toStringSafe(json['created_at']),
      resolvedAt: TypeUtils.toNullableStringSafe(json['resolved_at']),
      resolutionNote: TypeUtils.toNullableStringSafe(json['resolution_note']),
    );
  }

  /// Maps API reason codes to human-readable labels.
  static String reasonLabel(String reason) {
    switch (reason) {
      case 'vet_no_show':
        return 'Vet did not show up';
      case 'poor_service_quality':
        return 'Poor service quality';
      case 'payment_not_received':
        return 'Payment not received';
      case 'incorrect_charges':
        return 'Incorrect charges';
      default:
        return reason.replaceAll('_', ' ');
    }
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Under Review';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      case 'open':
        return 'Open';
      default:
        return status;
    }
  }
}
