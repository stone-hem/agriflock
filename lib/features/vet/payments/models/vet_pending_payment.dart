import 'package:agriflock/core/utils/type_safe_utils.dart';

// ─── Summary (single endpoint for the whole payments page) ───────────────────

class VetPaymentsSummary {
  final VetAccountSummary account;
  final double pendingRemittance;
  final double overdueAmount;
  final int overdueCount;
  final bool canAcceptOrders;
  final List<VetPendingPayment> pendingPayments;
  final List<VetPendingPayment> completedPayments;
  final List<VetPendingPayment> overduePayments;

  VetPaymentsSummary({
    required this.account,
    required this.pendingRemittance,
    required this.overdueAmount,
    required this.overdueCount,
    required this.canAcceptOrders,
    required this.pendingPayments,
    required this.completedPayments,
    required this.overduePayments,
  });

  factory VetPaymentsSummary.fromJson(Map<String, dynamic> json) {
    List<VetPendingPayment> _parseList(dynamic raw) => raw is List
        ? raw
            .map((e) => VetPendingPayment.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];

    return VetPaymentsSummary(
      account: VetAccountSummary.fromJson(
          json['account'] as Map<String, dynamic>),
      pendingRemittance: TypeUtils.toDoubleSafe(json['pending_remittance']),
      overdueAmount: TypeUtils.toDoubleSafe(json['overdue_amount']),
      overdueCount: TypeUtils.toIntSafe(json['overdue_count']),
      canAcceptOrders: TypeUtils.toBoolSafe(json['can_accept_orders']),
      pendingPayments: _parseList(json['pending_payments']),
      completedPayments: _parseList(json['completed_payments']),
      overduePayments: _parseList(json['overdue_payments']),
    );
  }
}

class VetAccountSummary {
  final String vetName;
  final String currency;
  final String currencySymbol;
  final double totalEarnings;
  final double totalRemitted;
  final double totalEarningsThisMonth;
  final double totalEarningsLastMonth;
  final double pendingEarningsThisMonth;
  final DateTime? lastRemittanceDate;
  final String status;

  VetAccountSummary({
    required this.vetName,
    required this.currency,
    required this.currencySymbol,
    required this.totalEarnings,
    required this.totalRemitted,
    required this.totalEarningsThisMonth,
    required this.totalEarningsLastMonth,
    required this.pendingEarningsThisMonth,
    this.lastRemittanceDate,
    required this.status,
  });

  factory VetAccountSummary.fromJson(Map<String, dynamic> json) {
    final vet = json['veterinarian'] as Map<String, dynamic>? ?? {};
    final currencyInfo =
        vet['currency_info'] as Map<String, dynamic>? ?? {};

    return VetAccountSummary(
      vetName: TypeUtils.toStringSafe(vet['name']),
      currency: TypeUtils.toStringSafe(vet['currency']),
      currencySymbol: TypeUtils.toStringSafe(currencyInfo['symbol']),
      totalEarnings: TypeUtils.toDoubleSafe(json['total_earnings']),
      totalRemitted: TypeUtils.toDoubleSafe(json['total_remitted']),
      totalEarningsThisMonth:
          TypeUtils.toDoubleSafe(json['total_earnings_this_month']),
      totalEarningsLastMonth:
          TypeUtils.toDoubleSafe(json['total_earnings_last_month']),
      pendingEarningsThisMonth:
          TypeUtils.toDoubleSafe(json['pending_earnings_this_month']),
      lastRemittanceDate:
          TypeUtils.toDateTimeSafe(json['last_remittance_date']),
      status: TypeUtils.toStringSafe(json['status']),
    );
  }
}

// ─── Legacy response (used by /order-payments/vet/pending) ───────────────────

class VetPendingPaymentsResponse {
  final double pendingRemittance;
  final List<VetPendingPayment> payments;

  VetPendingPaymentsResponse({
    required this.pendingRemittance,
    required this.payments,
  });

  factory VetPendingPaymentsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['payments'];
    return VetPendingPaymentsResponse(
      pendingRemittance: TypeUtils.toDoubleSafe(json['pending_remittance']),
      payments: list is List
          ? list
              .map((e) => VetPendingPayment.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

// ─── Individual payment (shared by pending / completed / overdue lists) ───────

class VetPendingPayment {
  final String id;
  final String paymentNumber;
  final String orderId;
  final String farmerId;
  final String vetId;
  final double totalAmount;
  final double vetEarnings;
  final double platformCommission;
  final double amountRemitted;
  final String currency;
  final String status;
  final String? farmerPaymentMethod;
  final String? vetRemittanceMethod;
  final String? vetTransactionRef;
  final DateTime? farmerPaidAt;
  final DateTime? vetRemittedAt;
  final DateTime? remittanceDueDate;

  VetPendingPayment({
    required this.id,
    required this.paymentNumber,
    required this.orderId,
    required this.farmerId,
    required this.vetId,
    required this.totalAmount,
    required this.vetEarnings,
    required this.platformCommission,
    required this.amountRemitted,
    required this.currency,
    required this.status,
    this.farmerPaymentMethod,
    this.vetRemittanceMethod,
    this.vetTransactionRef,
    this.farmerPaidAt,
    this.vetRemittedAt,
    this.remittanceDueDate,
  });

  factory VetPendingPayment.fromJson(Map<String, dynamic> json) {
    return VetPendingPayment(
      id: TypeUtils.toStringSafe(json['id']),
      paymentNumber: TypeUtils.toStringSafe(json['payment_number']),
      orderId: TypeUtils.toStringSafe(json['order_id']),
      farmerId: TypeUtils.toStringSafe(json['farmer_id']),
      vetId: TypeUtils.toStringSafe(json['vet_id']),
      totalAmount: TypeUtils.toDoubleSafe(json['total_amount']),
      vetEarnings: TypeUtils.toDoubleSafe(json['vet_earnings']),
      platformCommission: TypeUtils.toDoubleSafe(json['platform_commission']),
      amountRemitted: TypeUtils.toDoubleSafe(json['amount_remitted']),
      currency: TypeUtils.toStringSafe(json['currency']),
      status: TypeUtils.toStringSafe(json['status']),
      farmerPaymentMethod:
          TypeUtils.toNullableStringSafe(json['farmer_payment_method']),
      vetRemittanceMethod:
          TypeUtils.toNullableStringSafe(json['vet_remittance_method']),
      vetTransactionRef:
          TypeUtils.toNullableStringSafe(json['vet_transaction_ref']),
      farmerPaidAt: TypeUtils.toDateTimeSafe(json['farmer_paid_at']),
      vetRemittedAt: TypeUtils.toDateTimeSafe(json['vet_remitted_at']),
      remittanceDueDate: TypeUtils.toDateTimeSafe(json['remittance_due_date']),
    );
  }

  double get remaining => platformCommission - amountRemitted;
}
