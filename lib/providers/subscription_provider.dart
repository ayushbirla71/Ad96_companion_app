import 'package:flutter/material.dart';

import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionModel? subscription;

  bool isLoading = false;

  String? error;

  List<dynamic> history = [];

  /// LOAD ACTIVE SUBSCRIPTION
  Future<void> loadSubscription() async {
    try {
      isLoading = true;

      error = null;

      notifyListeners();

      subscription = await SubscriptionService.fetchMySubscription();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  /// LOAD HISTORY
  Future<void> loadHistory() async {
    try {
      history = await SubscriptionService.fetchSubscriptionHistory();

      notifyListeners();
    } catch (e) {
      error = e.toString();

      notifyListeners();
    }
  }

  /// FEATURE ACCESS
  bool hasFeature(String key) {
    return subscription?.hasFeature(key) ?? false;
  }

  /// LIMIT CHECK
  bool hasLimitAvailable(String key, int currentCount) {
    return subscription?.hasLimitAvailable(key, currentCount) ?? false;
  }

  /// STORAGE CHECK
  bool hasStorageAvailable(int newFileSizeBytes) {
    return subscription?.hasStorageAvailable(newFileSizeBytes) ?? false;
  }

  /// GET LIMIT VALUE
  int getLimit(String key) {
    return subscription?.getLimit(key) ?? 0;
  }

  /// USED STORAGE
  int getUsedStorage() {
    return subscription?.client?.usedStorageBytes ?? 0;
  }
}
