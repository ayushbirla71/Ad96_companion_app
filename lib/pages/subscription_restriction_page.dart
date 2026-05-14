import 'package:flutter/material.dart';

import 'sales_contact_page.dart';

enum RestrictionType { feature, limit, storage }

class SubscriptionRestrictionPage extends StatelessWidget {
  final RestrictionType type;

  final String featureKey;

  final int? currentCount;

  final int? maxLimit;

  const SubscriptionRestrictionPage({
    super.key,

    required this.type,

    required this.featureKey,

    this.currentCount,

    this.maxLimit,
  });

  String formatFeature(String value) {
    return value
        .replaceAll("MAX_", "")
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : "")
        .join(" ");
  }

  String getTitle() {
    final title = formatFeature(featureKey);

    switch (type) {
      case RestrictionType.feature:
        return "$title Not Available";

      case RestrictionType.limit:
        return "$title Limit Reached";

      case RestrictionType.storage:
        return "Storage Limit Reached";
    }
  }

  String getDescription() {
    final title = formatFeature(featureKey);

    switch (type) {
      case RestrictionType.feature:
        return "Your current subscription does not include access to $title.";

      case RestrictionType.limit:
        return "You have reached the maximum allowed limit for $title.";

      case RestrictionType.storage:
        return "Your storage limit has been reached.";
    }
  }

  IconData getIcon() {
    switch (type) {
      case RestrictionType.feature:
        return Icons.lock_outline;

      case RestrictionType.limit:
        return Icons.warning_amber_rounded;

      case RestrictionType.storage:
        return Icons.storage;
    }
  }

  Color getColor() {
    switch (type) {
      case RestrictionType.feature:
        return Colors.red;

      case RestrictionType.limit:
        return Colors.orange;

      case RestrictionType.storage:
        return Colors.blue;
    }
  }

  String formatBytes(int bytes) {
    final gb = bytes / (1024 * 1024 * 1024);

    return "${gb.toStringAsFixed(2)} GB";
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor();

    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade Required")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),

                  shape: BoxShape.circle,
                ),

                child: Icon(getIcon(), size: 80, color: color),
              ),

              const SizedBox(height: 30),

              Text(
                getTitle(),

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                getDescription(),

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),

              /// LIMIT INFO
              if (type == RestrictionType.limit)
                Column(
                  children: [
                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text("Current Usage"),

                              Text("$currentCount"),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text("Maximum Limit"),

                              Text("$maxLimit"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              /// STORAGE INFO
              if (type == RestrictionType.storage)
                Column(
                  children: [
                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text("Used Storage"),

                              Text(formatBytes(currentCount ?? 0)),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text("Storage Limit"),

                              Text(formatBytes(maxLimit ?? 0)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 35),

              Text(
                "Upgrade your subscription plan to continue.",

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.support_agent),

                  label: const Text("Contact Sales Team"),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SalesContactPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
