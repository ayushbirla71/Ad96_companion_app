// import 'package:flutter/material.dart';

// import 'sales_contact_page.dart';

// enum RestrictionType {
//   feature,
//   limit,
//   storage,
//   noSubscription,
//   expiredSubscription,
// }

// class SubscriptionRestrictionPage extends StatelessWidget {
//   final RestrictionType type;

//   final String featureKey;

//   final int? currentCount;

//   final int? maxLimit;

//   const SubscriptionRestrictionPage({
//     super.key,

//     required this.type,

//     required this.featureKey,

//     this.currentCount,

//     this.maxLimit,
//   });

//   String formatFeature(String value) {
//     return value
//         .replaceAll("MAX_", "")
//         .replaceAll("_", " ")
//         .toLowerCase()
//         .split(" ")
//         .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : "")
//         .join(" ");
//   }

//   String getTitle() {
//     final title = formatFeature(featureKey);

//     switch (type) {
//       case RestrictionType.feature:
//         return "$title Not Available";

//       case RestrictionType.limit:
//         return "$title Limit Reached";

//       case RestrictionType.storage:
//         return "Storage Limit Reached";

//       case RestrictionType.noSubscription:
//         return "No Active Subscription";

//       case RestrictionType.expiredSubscription:
//         return "Subscription Expired";
//     }
//   }

//   String getDescription() {
//     final title = formatFeature(featureKey);

//     switch (type) {
//       case RestrictionType.feature:
//         return "Your current subscription does not include access to $title.";

//       case RestrictionType.limit:
//         return "You have reached the maximum allowed limit for $title.";

//       case RestrictionType.storage:
//         return "Your storage limit has been reached.";

//       case RestrictionType.noSubscription:
//         return "You do not have an active subscription plan.";

//       case RestrictionType.expiredSubscription:
//         return "Your subscription has expired. Please renew your plan.";
//     }
//   }

//   IconData getIcon() {
//     switch (type) {
//       case RestrictionType.feature:
//         return Icons.lock_outline;

//       case RestrictionType.limit:
//         return Icons.warning_amber_rounded;

//       case RestrictionType.storage:
//         return Icons.storage;

//       case RestrictionType.noSubscription:
//         return Icons.credit_card_off;
//       case RestrictionType.expiredSubscription:
//         return Icons.event_busy;
//     }
//   }

//   Color getColor() {
//     switch (type) {
//       case RestrictionType.feature:
//         return Colors.red;

//       case RestrictionType.limit:
//         return Colors.orange;

//       case RestrictionType.storage:
//         return Colors.blue;

//       case RestrictionType.noSubscription:
//         return Colors.purple;
//       case RestrictionType.expiredSubscription:
//         return Colors.deepOrange;
//     }
//   }

//   String formatBytes(int bytes) {
//     final gb = bytes / (1024 * 1024 * 1024);

//     return "${gb.toStringAsFixed(2)} GB";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = getColor();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Upgrade Required")),

//       body: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,

//             children: [
//               Container(
//                 padding: const EdgeInsets.all(22),

//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),

//                   shape: BoxShape.circle,
//                 ),

//                 child: Icon(getIcon(), size: 80, color: color),
//               ),

//               const SizedBox(height: 30),

//               Text(
//                 getTitle(),

//                 textAlign: TextAlign.center,

//                 style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 18),

//               Text(
//                 getDescription(),

//                 textAlign: TextAlign.center,

//                 style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
//               ),

//               /// LIMIT INFO
//               if (type == RestrictionType.limit)
//                 Column(
//                   children: [
//                     const SizedBox(height: 25),

//                     Container(
//                       padding: const EdgeInsets.all(18),

//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,

//                         borderRadius: BorderRadius.circular(16),
//                       ),

//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                             children: [
//                               const Text("Current Usage"),

//                               Text("$currentCount"),
//                             ],
//                           ),

//                           const SizedBox(height: 12),

//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                             children: [
//                               const Text("Maximum Limit"),

//                               Text("$maxLimit"),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//               /// STORAGE INFO
//               if (type == RestrictionType.storage)
//                 Column(
//                   children: [
//                     const SizedBox(height: 25),

//                     Container(
//                       padding: const EdgeInsets.all(18),

//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,

//                         borderRadius: BorderRadius.circular(16),
//                       ),

//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                             children: [
//                               const Text("Used Storage"),

//                               Text(formatBytes(currentCount ?? 0)),
//                             ],
//                           ),

//                           const SizedBox(height: 12),

//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                             children: [
//                               const Text("Storage Limit"),

//                               Text(formatBytes(maxLimit ?? 0)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//               const SizedBox(height: 35),

//               Text(
//                 "Upgrade your subscription plan to continue.",

//                 textAlign: TextAlign.center,

//                 style: TextStyle(color: Colors.grey.shade600),
//               ),

//               const SizedBox(height: 35),

//               SizedBox(
//                 width: double.infinity,
//                 height: 55,

//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.support_agent),

//                   label: const Text("Contact Sales Team"),

//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const SalesContactPage(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<,,NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:cms_app/theme/app_colors.dart';
import 'sales_contact_page.dart';

enum RestrictionType {
  feature,
  limit,
  storage,
  noSubscription,
  expiredSubscription,
}

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
      case RestrictionType.noSubscription:
        return "No Active Subscription";
      case RestrictionType.expiredSubscription:
        return "Subscription Expired";
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
      case RestrictionType.noSubscription:
        return "You do not have an active subscription plan.";
      case RestrictionType.expiredSubscription:
        return "Your subscription has expired. Please renew your plan.";
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
      case RestrictionType.noSubscription:
        return Icons.credit_card_off;
      case RestrictionType.expiredSubscription:
        return Icons.event_busy;
    }
  }

  Color _iconColor() {
    switch (type) {
      case RestrictionType.feature:
        return appColors.red;
      case RestrictionType.limit:
        return appColors.orange;
      case RestrictionType.storage:
        return appColors.accent;
      case RestrictionType.noSubscription:
        return appColors.purple;
      case RestrictionType.expiredSubscription:
        return appColors.orange;
    }
  }

  Color _iconBg() {
    switch (type) {
      case RestrictionType.feature:
        return appColors.redLight;
      case RestrictionType.limit:
        return appColors.orangeLight;
      case RestrictionType.storage:
        return appColors.accentLight;
      case RestrictionType.noSubscription:
        return appColors.purpleLight;
      case RestrictionType.expiredSubscription:
        return appColors.orangeLight;
    }
  }

  String formatBytes(int bytes) {
    final gb = bytes / (1024 * 1024 * 1024);
    return "${gb.toStringAsFixed(2)} GB";
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColor();
    final iconBg = _iconBg();

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
          'Upgrade Required',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Icon ──
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(getIcon(), size: 38, color: iconColor),
            ),
            const SizedBox(height: 24),

            // ── Title ──
            Text(
              getTitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // ── Description ──
            Text(
              getDescription(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // ── Limit Info ──
            if (type == RestrictionType.limit) ...[
              _usageCard(
                rows: [
                  _UsageRow(label: 'Current Usage', value: '$currentCount'),
                  _UsageRow(label: 'Maximum Limit', value: '$maxLimit'),
                ],
                iconColor: iconColor,
                iconBg: iconBg,
              ),
              const SizedBox(height: 24),
            ],

            // ── Storage Info ──
            if (type == RestrictionType.storage) ...[
              _usageCard(
                rows: [
                  _UsageRow(
                    label: 'Used Storage',
                    value: formatBytes(currentCount ?? 0),
                  ),
                  _UsageRow(
                    label: 'Storage Limit',
                    value: formatBytes(maxLimit ?? 0),
                  ),
                ],
                iconColor: iconColor,
                iconBg: iconBg,
              ),
              const SizedBox(height: 24),
            ],

            // ── Upgrade hint ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: appColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: appColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upgrade your subscription plan to continue.',
                    style: TextStyle(color: appColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── CTA Button ──
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.support_agent_rounded, size: 18),
                label: const Text('Contact Sales Team'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesContactPage()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: appColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageCard({
    required List<_UsageRow> rows,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          final row = entry.value;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      row.value,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 10),
                Divider(height: 1, thickness: 1, color: appColors.borderLight),
                const SizedBox(height: 10),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _UsageRow {
  final String label;
  final String value;
  const _UsageRow({required this.label, required this.value});
}
