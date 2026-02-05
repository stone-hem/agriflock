
import 'dart:convert';

class CompletedOrdersResponse  {
  final List<CompletedOrder> orders;
  final PaginationMeta? meta;

  const CompletedOrdersResponse({
    required this.orders,
    this.meta,
  });

  factory CompletedOrdersResponse.fromJson(Map<String, dynamic> json) {
    return CompletedOrdersResponse(
      orders: json['data'] != null
          ? List<CompletedOrder>.from(
        (json['data'] as List).map(
              (x) => CompletedOrder.fromJson(x),
        ),
      )
          : [],
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': orders.map((x) => x.toJson()).toList(),
    'meta': meta?.toJson(),
  };


}

class CompletedOrder  {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final FarmerLocation farmerLocation;
  final String vetId;
  final String vetName;
  final List<String> vetSpecialization;
  final VetLocation vetLocation;
  final List<House> houses;
  final List<Batch> batches;
  final int birdsCount;
  final String birdTypeId;
  final String birdTypeName;
  final List<Service> services;
  final List<ServiceCost> serviceCosts;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final String reasonForVisit;
  final String? additionalNotes;
  final double serviceFee;
  final double mileageFee;
  final double distanceKm;
  final double prioritySurcharge;
  final double totalEstimatedCost;
  final double officerEarnings;
  final double platformCommission;
  final double actualCost;
  final String currency;
  final String status;
  final String submittedAt;
  final String reviewedAt;
  final String scheduledAt;
  final String completedAt;
  final String? cancelledAt;
  final String vetNotes;
  final String? cancellationReason;
  final bool termsAgreed;
  final bool isPaid;

  const CompletedOrder({
    required this.id,
    required this.orderNumber,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerLocation,
    required this.vetId,
    required this.vetName,
    required this.vetSpecialization,
    required this.vetLocation,
    required this.houses,
    required this.batches,
    required this.birdsCount,
    required this.birdTypeId,
    required this.birdTypeName,
    required this.services,
    required this.serviceCosts,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.reasonForVisit,
    this.additionalNotes,
    required this.serviceFee,
    required this.mileageFee,
    required this.distanceKm,
    required this.prioritySurcharge,
    required this.totalEstimatedCost,
    required this.officerEarnings,
    required this.platformCommission,
    required this.actualCost,
    required this.currency,
    required this.status,
    required this.submittedAt,
    required this.reviewedAt,
    required this.scheduledAt,
    required this.completedAt,
    this.cancelledAt,
    required this.vetNotes,
    this.cancellationReason,
    required this.termsAgreed,
    required this.isPaid,
  });

  factory CompletedOrder.fromJson(Map<String, dynamic> json) {
    return CompletedOrder(
      id: json['id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      farmerId: json['farmer_id'] ?? '',
      farmerName: json['farmer_name'] ?? '',
      farmerPhone: json['farmer_phone'] ?? '',
      farmerLocation: FarmerLocation.fromJson(
        json['farmer_location'] is String
            ? jsonDecode(json['farmer_location'])
            : json['farmer_location'] ?? {},
      ),
      vetId: json['vet_id'] ?? '',
      vetName: json['vet_name'] ?? '',
      vetSpecialization: json['vet_specialization'] != null
          ? List<String>.from(json['vet_specialization'])
          : [],
      vetLocation: VetLocation.fromJson(json['vet_location'] ?? {}),
      houses: json['houses'] != null
          ? List<House>.from(
        (json['houses'] as List).map((x) => House.fromJson(x)),
      )
          : [],
      batches: json['batches'] != null
          ? List<Batch>.from(
        (json['batches'] as List).map((x) => Batch.fromJson(x)),
      )
          : [],
      birdsCount: json['birds_count'] ?? 0,
      birdTypeId: json['bird_type_id'] ?? '',
      birdTypeName: json['bird_type_name'] ?? '',
      services: json['services'] != null
          ? List<Service>.from(
        (json['services'] as List).map((x) => Service.fromJson(x)),
      )
          : [],
      serviceCosts: json['service_costs'] != null
          ? List<ServiceCost>.from(
        (json['service_costs'] as List).map((x) => ServiceCost.fromJson(x)),
      )
          : [],
      priorityLevel: json['priority_level'] ?? '',
      preferredDate: json['preferred_date'] ?? '',
      preferredTime: json['preferred_time'] ?? '',
      reasonForVisit: json['reason_for_visit'] ?? '',
      additionalNotes: json['additional_notes'],
      serviceFee: (json['serviceFee'] ?? 0).toDouble(),
      mileageFee: (json['mileageFee'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      prioritySurcharge: (json['prioritySurcharge'] ?? 0).toDouble(),
      totalEstimatedCost: (json['totalEstimatedCost'] ?? 0).toDouble(),
      officerEarnings: (json['officerEarnings'] ?? 0).toDouble(),
      platformCommission: (json['platformCommission'] ?? 0).toDouble(),
      actualCost: (json['actualCost'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      reviewedAt: json['reviewed_at'] ?? '',
      scheduledAt: json['scheduled_at'] ?? '',
      completedAt: json['completed_at'] ?? '',
      cancelledAt: json['cancelled_at'],
      vetNotes: json['vet_notes'] ?? '',
      cancellationReason: json['cancellation_reason'],
      termsAgreed: json['terms_agreed'] ?? false,
      isPaid: json['is_paid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'farmer_id': farmerId,
    'farmer_name': farmerName,
    'farmer_phone': farmerPhone,
    'farmer_location': farmerLocation.toJson(),
    'vet_id': vetId,
    'vet_name': vetName,
    'vet_specialization': vetSpecialization,
    'vet_location': vetLocation.toJson(),
    'houses': houses.map((x) => x.toJson()).toList(),
    'batches': batches.map((x) => x.toJson()).toList(),
    'birds_count': birdsCount,
    'bird_type_id': birdTypeId,
    'bird_type_name': birdTypeName,
    'services': services.map((x) => x.toJson()).toList(),
    'service_costs': serviceCosts.map((x) => x.toJson()).toList(),
    'priority_level': priorityLevel,
    'preferred_date': preferredDate,
    'preferred_time': preferredTime,
    'reason_for_visit': reasonForVisit,
    'additional_notes': additionalNotes,
    'serviceFee': serviceFee,
    'mileageFee': mileageFee,
    'distanceKm': distanceKm,
    'prioritySurcharge': prioritySurcharge,
    'totalEstimatedCost': totalEstimatedCost,
    'officerEarnings': officerEarnings,
    'platformCommission': platformCommission,
    'actualCost': actualCost,
    'currency': currency,
    'status': status,
    'submitted_at': submittedAt,
    'reviewed_at': reviewedAt,
    'scheduled_at': scheduledAt,
    'completed_at': completedAt,
    'cancelled_at': cancelledAt,
    'vet_notes': vetNotes,
    'cancellation_reason': cancellationReason,
    'terms_agreed': termsAgreed,
    'is_paid': isPaid,
  };

}

class FarmerLocation {
  final String address;
  final double latitude;
  final double longitude;

  const FarmerLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory FarmerLocation.fromJson(Map<String, dynamic> json) {
    return FarmerLocation(
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };

}

class VetLocation  {
  final Address address;
  final double latitude;
  final double longitude;

  const VetLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory VetLocation.fromJson(Map<String, dynamic> json) {
    return VetLocation(
      address: Address.fromJson(json['address'] ?? {}),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address.toJson(),
    'latitude': latitude,
    'longitude': longitude,
  };

}

class Address {
  final String city;
  final String county;
  final String subCounty;
  final String formattedAddress;

  const Address({
    required this.city,
    required this.county,
    required this.subCounty,
    required this.formattedAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] ?? '',
      county: json['county'] ?? '',
      subCounty: json['sub_county'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'city': city,
    'county': county,
    'sub_county': subCounty,
    'formatted_address': formattedAddress,
  };

}

class House {
  final String id;
  final String name;
  final int birdsCount;

  const House({
    required this.id,
    required this.name,
    required this.birdsCount,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      birdsCount: json['birds_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birds_count': birdsCount,
  };

}

class Batch{
  final String id;
  final String name;
  final String houseId;
  final String houseName;
  final int birdsCount;
  final String birdTypeId;
  final String birdTypeName;

  const Batch({
    required this.id,
    required this.name,
    required this.houseId,
    required this.houseName,
    required this.birdsCount,
    required this.birdTypeId,
    required this.birdTypeName,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      houseId: json['house_id'] ?? '',
      houseName: json['house_name'] ?? '',
      birdsCount: json['birds_count'] ?? 0,
      birdTypeId: json['bird_type_id'] ?? '',
      birdTypeName: json['bird_type_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'house_id': houseId,
    'house_name': houseName,
    'birds_count': birdsCount,
    'bird_type_id': birdTypeId,
    'bird_type_name': birdTypeName,
  };

}

class Service{
  final String id;
  final String name;
  final String code;
  final double cost;

  const Service({
    required this.id,
    required this.name,
    required this.code,
    required this.cost,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'cost': cost,
  };

}

class ServiceCost {
  final double cost;
  final String serviceId;
  final String serviceCode;
  final String serviceName;

  const ServiceCost({
    required this.cost,
    required this.serviceId,
    required this.serviceCode,
    required this.serviceName,
  });

  factory ServiceCost.fromJson(Map<String, dynamic> json) {
    return ServiceCost(
      cost: (json['cost'] ?? 0).toDouble(),
      serviceId: json['service_id'] ?? '',
      serviceCode: json['service_code'] ?? '',
      serviceName: json['service_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'cost': cost,
    'service_id': serviceId,
    'service_code': serviceCode,
    'service_name': serviceName,
  };

}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'totalPages': totalPages,
  };

}