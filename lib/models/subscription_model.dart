class SubscriptionModel {
  final String status;
  final Map<String, dynamic> featuresCache;
  final String startDate;
  final String endDate;
  final TierModel? tier;
  final ClientModel? client;

  SubscriptionModel({
    required this.status,
    required this.featuresCache,
    required this.startDate,
    required this.endDate,
    this.tier,
    this.client,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      status: json['status'] ?? '',

      featuresCache: Map<String, dynamic>.from(json['features_cache'] ?? {}),

      startDate: json['start_date'] ?? '',

      endDate: json['end_date'] ?? '',

      tier: json['Tier'] != null ? TierModel.fromJson(json['Tier']) : null,
      client: json['Client'] != null
          ? ClientModel.fromJson(json['Client'])
          : null,
    );
  }

  /// BOOLEAN FEATURE CHECK
  bool hasFeature(String key) {
    final value = featuresCache[key];

    if (value is bool) return value;

    if (value is int) return value > 0;

    return false;
  }

  bool isUnlimited(String key) {
    return featuresCache[key] == "unlimited";
  }

  int getLimit(String key) {
    final value = featuresCache[key];

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  /// LIMIT CHECK
  bool hasLimitAvailable(String key, int currentCount) {
    // final value = featuresCache[key];

    // if (value is int) {
    //   return currentCount < value;
    // }

    // return false;
    if (isUnlimited(key)) {
      return true;
    }

    final limit = getLimit(key);

    return currentCount < limit;
  }

  /// GET LIMIT VALUE
  // int getLimit(String key) {
  //   final value = featuresCache[key];

  //   if (value is int) {
  //     return value;
  //   }

  //   return 0;
  // }

  bool hasStorageAvailable(int newFileSizeBytes) {
    if (isUnlimited("STORAGE_LIMIT")) {
      return true;
    }

    final storageLimit = getLimit("STORAGE_LIMIT");

    final usedStorage = client?.usedStorageBytes ?? 0;

    // UNLIMITED
    // if (storageLimit == 0) {
    //   return true;
    // }

    return (usedStorage + newFileSizeBytes) <= storageLimit;
  }
}

class TierModel {
  final String name;
  final int price;
  final bool featuresVisibleToClient;

  TierModel({
    required this.name,
    required this.price,
    required this.featuresVisibleToClient,
  });

  factory TierModel.fromJson(Map<String, dynamic> json) {
    return TierModel(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      featuresVisibleToClient: json['features_visible_to_client'] ?? true,
    );
  }
}

class ClientModel {
  final int usedStorageBytes;

  ClientModel({required this.usedStorageBytes});

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      usedStorageBytes:
          int.tryParse(json['used_storage_bytes'].toString()) ?? 0,
    );
  }
}
