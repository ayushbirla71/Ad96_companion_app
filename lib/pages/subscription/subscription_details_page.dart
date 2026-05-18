// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../providers/subscription_provider.dart';

// class SubscriptionDetailsPage extends StatelessWidget {
//   const SubscriptionDetailsPage({super.key});

//   String formatKey(String value) {
//     return value
//         .replaceAll("_", " ")
//         .toLowerCase()
//         .split(" ")
//         .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : "")
//         .join(" ");
//   }

//   String formatStorage(dynamic bytes) {
//     if (bytes == null) return "0 GB";

//     final value = bytes is int ? bytes : int.tryParse(bytes.toString()) ?? 0;

//     final gb = value / (1024 * 1024 * 1024);

//     return "${gb.toStringAsFixed(0)} GB";
//   }

//   String formatDate(String value) {
//     if (value.isEmpty) return "-";

//     final date = DateTime.parse(value);

//     return "${date.day}/${date.month}/${date.year}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<SubscriptionProvider>();

//     final subscription = provider.subscription;

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Subscription")),

//       body: subscription == null
//           ? const Center(child: Text("No Subscription"))
//           : ListView(
//               padding: const EdgeInsets.all(16),

//               children: [
//                 /// CURRENT PLAN CARD
//                 Container(
//                   padding: const EdgeInsets.all(20),

//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//                     ),

//                     borderRadius: BorderRadius.circular(20),
//                   ),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,

//                     children: [
//                       Text(
//                         subscription.tier?.name ?? "Plan",

//                         style: const TextStyle(
//                           color: Colors.white,

//                           fontSize: 26,

//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       Text(
//                         "Status: ${subscription.status}",

//                         style: const TextStyle(color: Colors.white70),
//                       ),

//                       const SizedBox(height: 8),

//                       Text(
//                         "Price: ₹${subscription.tier?.price ?? 0}",

//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 12),

//                       Text(
//                         "Start Date: ${formatDate(subscription.startDate)}",
//                         style: const TextStyle(color: Colors.white),
//                       ),

//                       const SizedBox(height: 6),

//                       Text(
//                         "End Date: ${formatDate(subscription.endDate)}",
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 /// FEATURES
//                 const Text(
//                   "Features",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 15),

//                 ...subscription.featuresCache.entries.map((e) {
//                   return Card(
//                     child: ListTile(
//                       leading: Icon(
//                         e.value == true || (e.value is int && e.value > 0)
//                             ? Icons.check_circle
//                             : Icons.cancel,

//                         color:
//                             e.value == true || (e.value is int && e.value > 0)
//                             ? Colors.green
//                             : Colors.red,
//                       ),

//                       title: Text(formatKey(e.key)),

//                       // trailing: Text("${e.value}"),
//                       trailing: Text(
//                         e.key == "STORAGE_LIMIT"
//                             ? formatStorage(e.value)
//                             : "${e.value}",
//                       ),
//                     ),
//                   );
//                 }),

//                 const SizedBox(height: 30),

//                 /// HISTORY
//                 const Text(
//                   "Subscription History",

//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 15),

//                 ...provider.history.map((item) {
//                   final tier = item["Tier"];

//                   return Card(
//                     child: ListTile(
//                       leading: CircleAvatar(child: Text(tier["name"][0])),

//                       title: Text(tier["name"]),

//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,

//                         children: [
//                           Text("Status: ${item["status"]}"),

//                           Text("Months: ${item["no_of_months"]}"),

//                           Text("Billing: ${item["billing_cycle"]}"),
//                         ],
//                       ),

//                       trailing: Text("₹${tier["price"]}"),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subscription_provider.dart';
import 'package:cms_app/theme/app_colors.dart';

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
      backgroundColor: appColors.bg,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: appColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: appColors.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.textSecondary,
              size: 15,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Subscription',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: subscription == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: appColors.surfaceHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: appColors.textMuted,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Subscription',
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You do not have an active plan yet.',
                    style: TextStyle(color: appColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
              children: [
                // ── Current Plan card ──────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [appColors.accent, const Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.accent.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -24,
                        top: -24,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -14,
                        bottom: -36,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Plan badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Current Plan',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Plan name
                            Text(
                              subscription.tier?.name ?? 'Plan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Price
                            Text(
                              '₹${subscription.tier?.price ?? 0}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Divider(
                              color: Colors.white.withOpacity(0.15),
                              height: 1,
                            ),
                            const SizedBox(height: 14),
                            // Status + dates row
                            Row(
                              children: [
                                _HeroBadge(
                                  icon: Icons.circle,
                                  label: subscription.status,
                                ),
                                const SizedBox(width: 8),
                                _HeroBadge(
                                  icon: Icons.calendar_today_rounded,
                                  label:
                                      'Start: ${formatDate(subscription.startDate)}',
                                ),
                                const SizedBox(width: 8),
                                _HeroBadge(
                                  icon: Icons.event_rounded,
                                  label:
                                      'End: ${formatDate(subscription.endDate)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Features ──────────────────────────────────────────
                _sectionLabel(
                  'Features',
                  Icons.star_rounded,
                  appColors.yellow,
                  appColors.yellowLight,
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: appColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: appColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: () {
                      final entries = subscription.featuresCache.entries
                          .toList();
                      return entries.asMap().entries.map((mapEntry) {
                        final i = mapEntry.key;
                        final e = mapEntry.value;
                        final isEnabled =
                            e.value == true || (e.value is int && e.value > 0);
                        final isLast = i == entries.length - 1;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isEnabled
                                          ? appColors.greenLight
                                          : appColors.redLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isEnabled
                                          ? Icons.check_rounded
                                          : Icons.close_rounded,
                                      color: isEnabled
                                          ? appColors.green
                                          : appColors.red,
                                      size: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      formatKey(e.key),
                                      style: TextStyle(
                                        color: appColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    e.key == "STORAGE_LIMIT"
                                        ? formatStorage(e.value)
                                        : "${e.value}",
                                    style: TextStyle(
                                      color: isEnabled
                                          ? appColors.green
                                          : appColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: appColors.borderLight,
                                indent: 62,
                              ),
                          ],
                        );
                      }).toList();
                    }(),
                  ),
                ),
                const SizedBox(height: 24),

                // ── History ───────────────────────────────────────────
                _sectionLabel(
                  'Subscription History',
                  Icons.history_rounded,
                  appColors.purple,
                  appColors.purpleLight,
                ),
                const SizedBox(height: 12),

                ...() {
                  final history = provider.history;
                  return history.asMap().entries.map((mapEntry) {
                    final i = mapEntry.key;
                    final item = mapEntry.value;
                    final tier = item["Tier"];
                    final isLast = i == history.length - 1;

                    return Container(
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: appColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: appColors.shadow,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: appColors.purpleLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                tier["name"][0],
                                style: TextStyle(
                                  color: appColors.purple,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tier["name"],
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _historyDetail(
                                  Icons.circle_rounded,
                                  'Status',
                                  item["status"],
                                ),
                                _historyDetail(
                                  Icons.calendar_month_rounded,
                                  'Months',
                                  '${item["no_of_months"]}',
                                ),
                                _historyDetail(
                                  Icons.sync_rounded,
                                  'Billing',
                                  item["billing_cycle"],
                                ),
                              ],
                            ),
                          ),
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.greenLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: appColors.green.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              '₹${tier["price"]}',
                              style: TextStyle(
                                color: appColors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                }(),
              ],
            ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, IconData icon, Color color, Color bg) =>
      Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      );

  Widget _historyDetail(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(
      children: [
        Icon(icon, size: 10, color: appColors.textMuted),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(color: appColors.textMuted, fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: appColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ─── Hero Badge ───────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 9),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
