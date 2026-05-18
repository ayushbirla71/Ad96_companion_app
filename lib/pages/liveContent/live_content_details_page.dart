// import 'package:flutter/material.dart';
// import '../../models/liveContent.dart';

// class LiveContentDetailsPage extends StatelessWidget {
//   final LiveContent content;

//   const LiveContentDetailsPage({super.key, required this.content});

//   String durationText(int seconds) {
//     if (seconds == 0) return "Indefinite";
//     final m = seconds ~/ 60;
//     final s = seconds % 60;
//     return "${m}m ${s}s";
//   }

//   Color statusColor(String status) {
//     if (status == "active") return Colors.green;
//     return Colors.grey;
//   }

//   IconData typeIcon(String type) {
//     switch (type) {
//       case "provider":
//         return Icons.cloud;
//       case "streaming":
//         return Icons.live_tv;
//       case "website":
//         return Icons.language;
//       default:
//         return Icons.video_collection;
//     }
//   }

//   Widget infoTile(String label, String value, IconData icon) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey.shade100,
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 22, color: Colors.blue),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Live Content Details"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             /// HEADER
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: Colors.blue.withOpacity(0.1),
//                   child: Icon(
//                     typeIcon(content.type),
//                     size: 28,
//                     color: Colors.blue,
//                   ),
//                 ),

//                 const SizedBox(width: 14),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [

//                       Text(
//                         content.name,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: statusColor(content.status).withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           content.status,
//                           style: TextStyle(
//                             color: statusColor(content.status),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),

//             const SizedBox(height: 30),

//             const Text(
//               "Information",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// DETAILS
//             infoTile(
//               "Content Type",
//               content.type,
//               Icons.category,
//             ),

//             infoTile(
//               "Duration",
//               durationText(content.duration),
//               Icons.timer,
//             ),

//             infoTile(
//               "Created At",
//               content.createdAt.toLocal().toString().split(".")[0],
//               Icons.calendar_today,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import '../../models/liveContent.dart';
import 'package:cms_app/theme/app_colors.dart';

class LiveContentDetailsPage extends StatelessWidget {
  final LiveContent content;

  const LiveContentDetailsPage({super.key, required this.content});

  String durationText(int seconds) {
    if (seconds == 0) return "Indefinite";
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m}m ${s}s";
  }

  Color statusColor(String status) {
    if (status == "active") return appColors.green;
    return appColors.textMuted;
  }

  Color statusBg(String status) {
    if (status == "active") return appColors.greenLight;
    return appColors.surfaceHigh;
  }

  IconData typeIcon(String type) {
    switch (type) {
      case "provider":
        return Icons.cloud_rounded;
      case "streaming":
        return Icons.live_tv_rounded;
      case "website":
        return Icons.language_rounded;
      default:
        return Icons.video_collection_rounded;
    }
  }

  Color typeColor(String type) {
    switch (type) {
      case "provider":
        return appColors.teal;
      case "streaming":
        return appColors.accent;
      case "website":
        return appColors.purple;
      default:
        return appColors.orange;
    }
  }

  Color typeBg(String type) {
    switch (type) {
      case "provider":
        return appColors.tealLight;
      case "streaming":
        return appColors.accentLight;
      case "website":
        return appColors.purpleLight;
      default:
        return appColors.orangeLight;
    }
  }

  Widget infoTile(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: appColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Live Content Details',
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appColors.accent, const Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: appColors.accent.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Type badge
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
                                  Icon(
                                    typeIcon(content.type),
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    content.type[0].toUpperCase() +
                                        content.type.substring(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg(
                                  content.status,
                                ).withOpacity(0.92),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor(content.status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    content.status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor(content.status),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          content.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              durationText(content.duration),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
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

            // ── Information ───────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: appColors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: appColors.accent,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Information',
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
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
                children: [
                  infoTile(
                    'Content Type',
                    content.type[0].toUpperCase() + content.type.substring(1),
                    typeIcon(content.type),
                    typeColor(content.type),
                    typeBg(content.type),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: appColors.borderLight,
                    indent: 66,
                  ),
                  infoTile(
                    'Duration',
                    durationText(content.duration),
                    Icons.timer_rounded,
                    appColors.teal,
                    appColors.tealLight,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: appColors.borderLight,
                    indent: 66,
                  ),
                  infoTile(
                    'Created At',
                    content.createdAt.toLocal().toString().split(".")[0],
                    Icons.calendar_today_rounded,
                    appColors.purple,
                    appColors.purpleLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
