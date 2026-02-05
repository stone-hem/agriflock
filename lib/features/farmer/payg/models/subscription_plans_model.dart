
class SubscriptionPlansResponse {
  final List<SubscriptionPlanItem> data;
  final int total;

  const SubscriptionPlansResponse({
    required this.data,
    required this.total,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlansResponse(
      data: json['data'] != null
          ? List<SubscriptionPlanItem>.from(
        (json['data'] as List).map(
              (x) => SubscriptionPlanItem.fromJson(x),
        ),
      )
          : [],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((x) => x.toJson()).toList(),
    'total': total,
  };

}

class SubscriptionPlanItem {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final String status;
  final String startDate;
  final String endDate;
  final String? trialStartDate;
  final String? trialEndDate;
  final int currentTrialDay;
  final bool isTrialActive;
  final bool autoRenew;
  final int daysRemaining;
  final String? cancellationReason;
  final String createdAt;
  final String updatedAt;

  const SubscriptionPlanItem({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.trialStartDate,
    this.trialEndDate,
    required this.currentTrialDay,
    required this.isTrialActive,
    required this.autoRenew,
    required this.daysRemaining,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      plan: SubscriptionPlan.fromJson(json['plan'] ?? {}),
      status: json['status'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      trialStartDate: json['trialStartDate'],
      trialEndDate: json['trialEndDate'],
      currentTrialDay: json['currentTrialDay'] ?? 0,
      isTrialActive: json['isTrialActive'] ?? false,
      autoRenew: json['autoRenew'] ?? false,
      daysRemaining: json['daysRemaining'] ?? 0,
      cancellationReason: json['cancellationReason'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'plan': plan.toJson(),
    'status': status,
    'startDate': startDate,
    'endDate': endDate,
    'trialStartDate': trialStartDate,
    'trialEndDate': trialEndDate,
    'currentTrialDay': currentTrialDay,
    'isTrialActive': isTrialActive,
    'autoRenew': autoRenew,
    'daysRemaining': daysRemaining,
    'cancellationReason': cancellationReason,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };


}

class SubscriptionPlan {
  final String id;
  final String planType;
  final String name;
  final double priceAmount;
  final String currency;
  final List<String> includedModules;
  final PlanFeatures features;

  const SubscriptionPlan({
    required this.id,
    required this.planType,
    required this.name,
    required this.priceAmount,
    required this.currency,
    required this.includedModules,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      planType: json['planType'] ?? '',
      name: json['name'] ?? '',
      priceAmount: (json['priceAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      includedModules: json['includedModules'] != null
          ? List<String>.from(json['includedModules'])
          : [],
      features: PlanFeatures.fromJson(json['features'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'planType': planType,
    'name': name,
    'priceAmount': priceAmount,
    'currency': currency,
    'includedModules': includedModules,
    'features': features.toJson(),
  };


}

class PlanFeatures {
  final int? maxChicks;
  final int? minChicks;
  final String supportLevel;
  final int trialPeriodDays;
  final String marketplaceAccess;
  final int quotationFreePeriodDays;

  const PlanFeatures({
    this.maxChicks,
    this.minChicks,
    required this.supportLevel,
    required this.trialPeriodDays,
    required this.marketplaceAccess,
    required this.quotationFreePeriodDays,
  });

  factory PlanFeatures.fromJson(Map<String, dynamic> json) {
    return PlanFeatures(
      maxChicks: json['max_chicks'],
      minChicks: json['min_chicks'],
      supportLevel: json['support_level'] ?? '',
      trialPeriodDays: json['trial_period_days'] ?? 0,
      marketplaceAccess: json['marketplace_access'] ?? '',
      quotationFreePeriodDays: json['quotation_free_period_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    if (maxChicks != null) 'max_chicks': maxChicks,
    if (minChicks != null) 'min_chicks': minChicks,
    'support_level': supportLevel,
    'trial_period_days': trialPeriodDays,
    'marketplace_access': marketplaceAccess,
    'quotation_free_period_days': quotationFreePeriodDays,
  };
  
}

// Enum for subscription status (optional but recommended)
enum SubscriptionPlanStatus {
  active,
  expired,
  cancelled,
  pending,
  trial,

  unknown;

  factory SubscriptionPlanStatus.fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return SubscriptionPlanStatus.active;
      case 'EXPIRED':
        return SubscriptionPlanStatus.expired;
      case 'CANCELLED':
        return SubscriptionPlanStatus.cancelled;
      case 'PENDING':
        return SubscriptionPlanStatus.pending;
      case 'TRIAL':
        return SubscriptionPlanStatus.trial;
      default:
        return SubscriptionPlanStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionPlanStatus.active:
        return 'Active';
      case SubscriptionPlanStatus.expired:
        return 'Expired';
      case SubscriptionPlanStatus.cancelled:
        return 'Cancelled';
      case SubscriptionPlanStatus.pending:
        return 'Pending';
      case SubscriptionPlanStatus.trial:
        return 'Trial';
      case SubscriptionPlanStatus.unknown:
        return 'Unknown';
    }
  }
}

// Enum for plan types (optional but recommended)
enum PlanType {
  silver,
  platinum,
  gold,
  bronze,
  free,

  unknown;

  factory PlanType.fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SILVER':
        return PlanType.silver;
      case 'PLATINUM':
        return PlanType.platinum;
      case 'GOLD':
        return PlanType.gold;
      case 'BRONZE':
        return PlanType.bronze;
      case 'FREE':
        return PlanType.free;
      default:
        return PlanType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case PlanType.silver:
        return 'Silver';
      case PlanType.platinum:
        return 'Platinum';
      case PlanType.gold:
        return 'Gold';
      case PlanType.bronze:
        return 'Bronze';
      case PlanType.free:
        return 'Free';
      case PlanType.unknown:
        return 'Unknown';
    }
  }
}