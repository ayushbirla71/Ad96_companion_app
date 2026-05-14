import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subscription_provider.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  const SubscriptionDetailsPage({super.key});

  String formatKey(String value) {
    return value
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : "")
        .join(" ");
  }

  String formatStorage(dynamic bytes) {
    if (bytes == null) return "0 GB";

    final value = bytes is int ? bytes : int.tryParse(bytes.toString()) ?? 0;

    final gb = value / (1024 * 1024 * 1024);

    return "${gb.toStringAsFixed(0)} GB";
  }

  String formatDate(String value) {
    if (value.isEmpty) return "-";

    final date = DateTime.parse(value);

    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();

    final subscription = provider.subscription;

    return Scaffold(
      appBar: AppBar(title: const Text("My Subscription")),

      body: subscription == null
          ? const Center(child: Text("No Subscription"))
          : ListView(
              padding: const EdgeInsets.all(16),

              children: [
                /// CURRENT PLAN CARD
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        subscription.tier?.name ?? "Plan",

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 26,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Status: ${subscription.status}",

                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Price: ₹${subscription.tier?.price ?? 0}",

                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        "Start Date: ${formatDate(subscription.startDate)}",
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "End Date: ${formatDate(subscription.endDate)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// FEATURES
                const Text(
                  "Features",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                ...subscription.featuresCache.entries.map((e) {
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        e.value == true || (e.value is int && e.value > 0)
                            ? Icons.check_circle
                            : Icons.cancel,

                        color:
                            e.value == true || (e.value is int && e.value > 0)
                            ? Colors.green
                            : Colors.red,
                      ),

                      title: Text(formatKey(e.key)),

                      // trailing: Text("${e.value}"),
                      trailing: Text(
                        e.key == "STORAGE_LIMIT"
                            ? formatStorage(e.value)
                            : "${e.value}",
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 30),

                /// HISTORY
                const Text(
                  "Subscription History",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                ...provider.history.map((item) {
                  final tier = item["Tier"];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(tier["name"][0])),

                      title: Text(tier["name"]),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text("Status: ${item["status"]}"),

                          Text("Months: ${item["no_of_months"]}"),

                          Text("Billing: ${item["billing_cycle"]}"),
                        ],
                      ),

                      trailing: Text("₹${tier["price"]}"),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
