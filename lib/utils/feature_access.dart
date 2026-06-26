import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/subscription_restriction_page.dart';
import '../providers/subscription_provider.dart';

class FeatureAccess {
  /// FEATURE CHECK
  static Future<void> openFeature({
    required BuildContext context,

    required String featureKey,

    required Widget page,
  }) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    // REFRESH SUBSCRIPTION
    await provider.loadSubscription();
    if (provider.subscription == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.noSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    if (isSubscriptionExpired(provider.subscription)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.expiredSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    final hasAccess = provider.hasFeature(featureKey);

    if (hasAccess) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionRestrictionPage(
            type: RestrictionType.feature,

            featureKey: featureKey,
          ),
        ),
      );
    }
  }

  /// LIMIT CHECK
  static Future<void> openLimitedFeature({
    required BuildContext context,

    required String limitKey,

    required int currentCount,

    required Widget page,
  }) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    // REFRESH SUBSCRIPTION
    await provider.loadSubscription();

    if (provider.subscription == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.noSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    if (isSubscriptionExpired(provider.subscription)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.expiredSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    final allowed = provider.hasLimitAvailable(limitKey, currentCount);

    final maxLimit = provider.getLimit(limitKey);

    if (allowed) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionRestrictionPage(
            type: RestrictionType.limit,

            featureKey: limitKey,

            currentCount: currentCount,

            maxLimit: maxLimit,
          ),
        ),
      );
    }
  }

  /// STORAGE CHECK
  static Future<void> openStorageLimitedFeature({
    required BuildContext context,

    required int newFileSizeBytes,

    required Widget page,
  }) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    // REFRESH SUBSCRIPTION
    await provider.loadSubscription();

    if (provider.subscription == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.noSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    if (isSubscriptionExpired(provider.subscription)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.expiredSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    final allowed = provider.hasStorageAvailable(newFileSizeBytes);

    final usedStorage = provider.getUsedStorage();

    final storageLimit = provider.getLimit("STORAGE_LIMIT");

    if (allowed) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionRestrictionPage(
            type: RestrictionType.storage,

            featureKey: "STORAGE_LIMIT",

            currentCount: usedStorage,

            maxLimit: storageLimit,
          ),
        ),
      );
    }
  }

  static Future<bool> hasStorageForUpload({
    required BuildContext context,
    required int newFileSizeBytes,
  }) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    /// REFRESH
    await provider.loadSubscription();

    /// NO SUBSCRIPTION
    if (provider.subscription == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.noSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return false;
    }

    /// EXPIRED SUBSCRIPTION
    if (isSubscriptionExpired(provider.subscription)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.expiredSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return false;
    }

    final allowed = provider.hasStorageAvailable(newFileSizeBytes);

    if (!allowed) {
      final usedStorage = provider.getUsedStorage();

      final storageLimit = provider.getLimit("STORAGE_LIMIT");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionRestrictionPage(
            type: RestrictionType.storage,
            featureKey: "STORAGE_LIMIT",
            currentCount: usedStorage,
            maxLimit: storageLimit,
          ),
        ),
      );

      return false;
    }

    return true;
  }

  /// LIMIT + STORAGE CHECK
  static Future<void> openLimitedAndStorageFeature({
    required BuildContext context,

    required String limitKey,

    required int currentCount,

    required int newFileSizeBytes,

    required Widget page,
  }) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    // REFRESH SUBSCRIPTION
    await provider.loadSubscription();
    if (provider.subscription == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.noSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    if (isSubscriptionExpired(provider.subscription)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.expiredSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return;
    }

    /// LIMIT CHECK
    final limitAllowed = provider.hasLimitAvailable(limitKey, currentCount);

    final maxLimit = provider.getLimit(limitKey);

    if (!limitAllowed) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionRestrictionPage(
            type: RestrictionType.limit,

            featureKey: limitKey,

            currentCount: currentCount,

            maxLimit: maxLimit,
          ),
        ),
      );

      return;
    }

    /// STORAGE CHECK
    final storageAllowed = provider.hasStorageAvailable(newFileSizeBytes);

    final usedStorage = provider.getUsedStorage();

    final storageLimit = provider.getLimit("STORAGE_LIMIT");

    if (!storageAllowed) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionRestrictionPage(
            type: RestrictionType.storage,

            featureKey: "STORAGE_LIMIT",

            currentCount: usedStorage,

            maxLimit: storageLimit,
          ),
        ),
      );

      return;
    }

    /// OPEN PAGE
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static Future<bool> checkSubscription({required BuildContext context}) async {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    await provider.loadSubscription();

    final hasSubscription = provider.subscription != null;

    if (!hasSubscription) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionRestrictionPage(
            type: RestrictionType.noSubscription,
            featureKey: "SUBSCRIPTION",
          ),
        ),
      );

      return false;
    }

    return true;
  }

  static bool isSubscriptionExpired(dynamic subscription) {
    if (subscription == null) {
      return true;
    }

    /// STATUS CHECK
    final status = subscription.status.toString().toLowerCase();

    if (status == "expired") {
      return true;
    }

    /// DATE CHECK
    final expiryDateString = subscription.endDate;

    if (expiryDateString == null || expiryDateString.toString().isEmpty) {
      return false;
    }

    final expiryDate = DateTime.tryParse(expiryDateString);

    if (expiryDate == null) {
      return false;
    }

    return expiryDate.isBefore(DateTime.now());
  }

  static SubscriptionProvider _provider(BuildContext context) {
    return context.watch<SubscriptionProvider>();
  }

  /// Tier visibility
  static bool showPremiumFeatures(BuildContext context) {
    final provider = _provider(context);
    return provider.subscription?.tier?.featuresVisibleToClient ?? true;
  }

  static bool showProofOfPlay(BuildContext context) {
    final provider = _provider(context);

    return (provider.subscription?.tier?.featuresVisibleToClient ?? true) &&
        provider.hasFeature("PROOF_OF_PLAY");
  }

  static bool showLiveStreaming(BuildContext context) {
    final provider = _provider(context);

    return (provider.subscription?.tier?.featuresVisibleToClient ?? true) &&
        provider.hasFeature("LIVE_STREAMING");
  }

  static bool showCarousels(BuildContext context) {
    final provider = _provider(context);

    return (provider.subscription?.tier?.featuresVisibleToClient ?? true) &&
        provider.hasFeature("CAROUSELS");
  }
}
