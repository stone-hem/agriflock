import 'package:agriflock360/core/utils/type_safe_utils.dart';

class SubscriptionPlansResponse {
  final List<SubscriptionPlanItem> data;
  final int total;

  const SubscriptionPlansResponse({
    required this.data,
    required this.total,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return SubscriptionPlansResponse(
      data: dataList
          .map((x) => SubscriptionPlanItem.fromJson(
          x is Map<String, dynamic> ? x : {}))
          .toList(),
      total: TypeUtils.toIntSafe(json['total']),
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
    final planMap = TypeUtils.toMapSafe(json['plan']);

    return SubscriptionPlanItem(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['userId']),
      plan: SubscriptionPlan.fromJson(planMap ?? {}),
      status: TypeUtils.toStringSafe(json['status']),
      startDate: TypeUtils.toStringSafe(json['startDate']),
      endDate: TypeUtils.toStringSafe(json['endDate']),
      trialStartDate: TypeUtils.toNullableStringSafe(json['trialStartDate']),
      trialEndDate: TypeUtils.toNullableStringSafe(json['trialEndDate']),
      currentTrialDay: TypeUtils.toIntSafe(json['currentTrialDay']),
      isTrialActive: TypeUtils.toBoolSafe(json['isTrialActive']),
      autoRenew: TypeUtils.toBoolSafe(json['autoRenew']),
      daysRemaining: TypeUtils.toIntSafe(json['daysRemaining']),
      cancellationReason: TypeUtils.toNullableStringSafe(json['cancellationReason']),
      createdAt: TypeUtils.toStringSafe(json['createdAt']),
      updatedAt: TypeUtils.toStringSafe(json['updatedAt']),
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
    final featuresMap = TypeUtils.toMapSafe(json['features']);

    return SubscriptionPlan(
      id: TypeUtils.toStringSafe(json['id']),
      planType: TypeUtils.toStringSafe(json['planType']),
      name: TypeUtils.toStringSafe(json['name']),
      priceAmount: TypeUtils.toDoubleSafe(json['priceAmount']),
      currency: TypeUtils.toStringSafe(json['currency']),
      includedModules: _parseStringList(json['includedModules']),
      features: PlanFeatures.fromJson(featuresMap ?? {}),
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

  // Helper method to safely parse string list
  static List<String> _parseStringList(dynamic value) {
    final list = TypeUtils.toListSafe<dynamic>(value);
    return list.map((item) => TypeUtils.toStringSafe(item)).toList();
  }
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
      maxChicks: TypeUtils.toNullableIntSafe(json['max_chicks']),
      minChicks: TypeUtils.toNullableIntSafe(json['min_chicks']),
      supportLevel: TypeUtils.toStringSafe(json['support_level']),
      trialPeriodDays: TypeUtils.toIntSafe(json['trial_period_days']),
      marketplaceAccess: TypeUtils.toStringSafe(json['marketplace_access']),
      quotationFreePeriodDays: TypeUtils.toIntSafe(json['quotation_free_period_days']),
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

/// Model for plans returned by /app-subscription-plans/active
class ActivePlan {
  final String id;
  final String planType;
  final String name;
  final String description;
  final String region;
  final double priceAmount;
  final String currency;
  final List<String> includedModules;
  final PlanFeatures features;
  final bool isActive;
  final int billingCycleDays;
  final int? durationInMonths;
  final int? trialPeriodDays;
  final String createdAt;
  final String updatedAt;

  const ActivePlan({
    required this.id,
    required this.planType,
    required this.name,
    required this.description,
    required this.region,
    required this.priceAmount,
    required this.currency,
    required this.includedModules,
    required this.features,
    required this.isActive,
    required this.billingCycleDays,
    this.durationInMonths,
    this.trialPeriodDays,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFreeTrial => planType.toUpperCase() == 'FREE_TRIAL';

  factory ActivePlan.fromJson(Map<String, dynamic> json) {
    final featuresMap = TypeUtils.toMapSafe(json['features']);

    return ActivePlan(
      id: TypeUtils.toStringSafe(json['id']),
      planType: TypeUtils.toStringSafe(json['planType']),
      name: TypeUtils.toStringSafe(json['name']),
      description: TypeUtils.toStringSafe(json['description']),
      region: TypeUtils.toStringSafe(json['region']),
      priceAmount: TypeUtils.toDoubleSafe(json['priceAmount']),
      currency: TypeUtils.toStringSafe(json['currency']),
      includedModules: _parseStringList(json['includedModules']),
      features: PlanFeatures.fromJson(featuresMap ?? {}),
      isActive: TypeUtils.toBoolSafe(json['isActive']),
      billingCycleDays: TypeUtils.toIntSafe(json['billingCycleDays'], defaultValue: 30),
      durationInMonths: TypeUtils.toNullableIntSafe(json['durationInMonths']),
      trialPeriodDays: TypeUtils.toNullableIntSafe(json['trialPeriodDays']),
      createdAt: TypeUtils.toStringSafe(json['createdAt']),
      updatedAt: TypeUtils.toStringSafe(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'planType': planType,
    'name': name,
    'description': description,
    'region': region,
    'priceAmount': priceAmount,
    'currency': currency,
    'includedModules': includedModules,
    'features': features.toJson(),
    'isActive': isActive,
    'billingCycleDays': billingCycleDays,
    if (durationInMonths != null) 'durationInMonths': durationInMonths,
    if (trialPeriodDays != null) 'trialPeriodDays': trialPeriodDays,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  // Helper method to safely parse string list
  static List<String> _parseStringList(dynamic value) {
    final list = TypeUtils.toListSafe<dynamic>(value);
    return list.map((item) => TypeUtils.toStringSafe(item)).toList();
  }

  /// Human-readable feature descriptions for display
  List<String> get readableFeatures {
    final list = <String>[];

    // Chick capacity
    if (features.maxChicks != null && features.minChicks != null) {
      list.add('Manage ${features.minChicks} to ${features.maxChicks} chicks per batch');
    } else if (features.maxChicks != null) {
      list.add('Manage up to ${features.maxChicks} chicks per batch');
    } else if (features.minChicks != null) {
      list.add('Manage ${features.minChicks}+ chicks — no upper limit');
    }

    // Included modules
    for (final module in includedModules) {
      switch (module) {
        case 'VACCINATIONS':
          list.add('Full vaccination tracking & reminders');
        case 'FEEDING':
          list.add('Smart feeding schedules & monitoring');
        case 'MARKETPLACE':
          list.add('Access to extension & vet marketplace');
        case 'QUOTATIONS':
          list.add('Quotation module — free for ${features.quotationFreePeriodDays} days');
        default:
          list.add(module[0] + module.substring(1).toLowerCase());
      }
    }

    // Support level
    switch (features.supportLevel) {
      case 'standard':
        list.add('Standard community support');
      case 'priority':
        list.add('Priority support — faster response times');
      case 'premium':
        list.add('Premium 24/7 dedicated support');
      default:
        if (features.supportLevel.isNotEmpty) {
          list.add('${features.supportLevel[0].toUpperCase()}${features.supportLevel.substring(1)} support');
        }
    }

    // Trial
    if (features.trialPeriodDays > 0) {
      list.add('${features.trialPeriodDays}-day free trial included');
    }

    // Marketplace access
    if (features.marketplaceAccess == 'pay_per_use') {
      list.add('Pay-per-use marketplace extensions');
    }

    return list;
  }

  /// Short chick-range label
  String get chicksLabel {
    if (features.maxChicks != null && features.minChicks != null) {
      return '${features.minChicks}–${features.maxChicks} chicks';
    } else if (features.maxChicks != null) {
      return 'Up to ${features.maxChicks} chicks';
    } else if (features.minChicks != null) {
      return '${features.minChicks}+ chicks';
    }
    return '';
  }
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