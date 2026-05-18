// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../models/export_job.dart';
// import '../../providers/export_provider.dart';

// class ExportDetailsPage extends StatefulWidget {
//   const ExportDetailsPage({super.key});

//   @override
//   State<ExportDetailsPage> createState() => _ExportDetailsPageState();
// }

// class _ExportDetailsPageState extends State<ExportDetailsPage> {
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() {
//       context.read<ExportProvider>().loadExports();
//     });

//     timer = Timer.periodic(const Duration(seconds: 10), (_) {
//       context.read<ExportProvider>().loadExports();
//     });
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   /// DOWNLOAD
//   Future<void> handleDownload(String url) async {
//     final uri = Uri.parse(url);

//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   Color getStatusColor(String status) {
//     switch (status) {
//       case "FAILED":
//         return Colors.red;

//       case "QUEUED":
//         return Colors.orange;

//       case "COMPLETED":
//         return Colors.green;

//       default:
//         return Colors.blue;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<ExportProvider>();

//     if (provider.loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Exports")),

//       body: Padding(
//         padding: const EdgeInsets.all(16),

//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,

//             children: [
//               /// TITLE
//               const Text(
//                 "Exports",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 4),

//               Text(
//                 "List of export jobs",
//                 style: TextStyle(color: Colors.grey.shade600),
//               ),

//               const SizedBox(height: 20),

//               /// GRID
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),

//                 itemCount: provider.exports.length,

//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,

//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,

//                   /// FIXED HEIGHT
//                   mainAxisExtent: 300,
//                 ),

//                 itemBuilder: (context, index) {
//                   final ExportJob job = provider.exports[index];

//                   final progress = job.progressPercent ?? 0;
//                   final status = job.status ?? "";
//                   final color = getStatusColor(status);

//                   return Container(
//                     padding: const EdgeInsets.all(14),

//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,

//                       borderRadius: BorderRadius.circular(16),

//                       border: status == "FAILED"
//                           ? Border.all(color: Colors.red)
//                           : null,
//                     ),

//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,

//                       children: [
//                         /// TOP
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,

//                           children: [
//                             Expanded(
//                               child: Text(
//                                 job.jobType ?? "",

//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,

//                                 style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(width: 8),

//                             const Icon(Icons.layers, size: 18),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         /// JOB ID
//                         Text(
//                           "Job ID: ${(job.jobId ?? "").toString().substring(0, 8)}...",

//                           style: const TextStyle(fontWeight: FontWeight.w600),
//                         ),

//                         const SizedBox(height: 6),

//                         /// STATUS
//                         Text(
//                           "Status: $status",

//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),

//                         const SizedBox(height: 4),

//                         /// DEVICE
//                         Text(
//                           "Device: ${job.deviceId ?? "All Devices"}",

//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,

//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         /// PROGRESS BAR
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),

//                           child: LinearProgressIndicator(
//                             value: progress / 100,
//                             minHeight: 8,
//                             color: color,
//                             backgroundColor: Colors.grey.shade300,
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         /// PROGRESS ROW
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                           children: [
//                             Text(
//                               "$progress%",
//                               style: const TextStyle(fontSize: 12),
//                             ),

//                             Text(
//                               "Completed",

//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         /// DOWNLOAD BUTTON
//                         if (progress == 100 && job.downloadUrl != null)
//                           SizedBox(
//                             width: double.infinity,

//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 handleDownload(job.downloadUrl ?? "");
//                               },

//                               icon: const Icon(Icons.download),

//                               label: const Text("Download"),
//                             ),
//                           ),

//                         /// ERROR MESSAGE
//                         if (status == "FAILED" && job.errorMessage != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 10),

//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,

//                               children: [
//                                 const Icon(
//                                   Icons.warning_amber_rounded,
//                                   color: Colors.red,
//                                   size: 18,
//                                 ),

//                                 const SizedBox(width: 6),

//                                 Expanded(
//                                   child: Text(
//                                     job.errorMessage ?? "",

//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,

//                                     style: const TextStyle(
//                                       color: Colors.red,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/export_job.dart';
import '../../providers/export_provider.dart';
import '../../theme/app_colors.dart'; // adjust import path as needed

class ExportDetailsPage extends StatefulWidget {
  const ExportDetailsPage({super.key});

  @override
  State<ExportDetailsPage> createState() => _ExportDetailsPageState();
}

class _ExportDetailsPageState extends State<ExportDetailsPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ExportProvider>().loadExports();
    });

    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      context.read<ExportProvider>().loadExports();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// DOWNLOAD
  Future<void> handleDownload(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "FAILED":
        return appColors.red;
      case "QUEUED":
        return appColors.orange;
      case "COMPLETED":
        return appColors.green;
      default:
        return appColors.accent;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case "FAILED":
        return appColors.redLight;
      case "QUEUED":
        return appColors.orangeLight;
      case "COMPLETED":
        return appColors.greenLight;
      default:
        return appColors.accentLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExportProvider>();

    if (provider.loading) {
      return Scaffold(
        backgroundColor: appColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: appColors.accent,
                  strokeWidth: 2.5,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading exports…',
                style: TextStyle(color: appColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

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
          'Exports',
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

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITLE
              Text(
                "Exports",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: appColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "List of export jobs",
                style: TextStyle(color: appColors.textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 20),

              /// GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                itemCount: provider.exports.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,

                  /// FIXED HEIGHT
                  mainAxisExtent: 300,
                ),

                itemBuilder: (context, index) {
                  final ExportJob job = provider.exports[index];

                  final progress = job.progressPercent ?? 0;
                  final status = job.status ?? "";
                  final color = getStatusColor(status);
                  final bgColor = getStatusBgColor(status);

                  return Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: appColors.surface,

                      borderRadius: BorderRadius.circular(20),

                      border: status == "FAILED"
                          ? Border.all(color: appColors.red, width: 1.5)
                          : Border.all(color: appColors.border),

                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// TOP
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Expanded(
                              child: Text(
                                job.jobType ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: appColors.textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: appColors.accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.layers_rounded,
                                size: 15,
                                color: appColors.accent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// JOB ID
                        Row(
                          children: [
                            Icon(
                              Icons.tag_rounded,
                              size: 12,
                              color: appColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${(job.jobId ?? "").toString().substring(0, 8)}...",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: appColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// STATUS PILL — same as _StatusPill in DeviceGroupDetailsPage
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// DEVICE
                        Row(
                          children: [
                            Icon(
                              Icons.devices_rounded,
                              size: 12,
                              color: appColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.deviceId ?? "All Devices",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: appColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// PROGRESS BAR
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 7,
                            color: color,
                            backgroundColor: appColors.borderLight,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// PROGRESS ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$progress%",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: appColors.textPrimary,
                              ),
                            ),
                            Text(
                              "Completed",
                              style: TextStyle(
                                fontSize: 11,
                                color: appColors.textMuted,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// DOWNLOAD BUTTON
                        if (progress == 100 && job.downloadUrl != null)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                handleDownload(job.downloadUrl ?? "");
                              },
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 15,
                              ),
                              label: const Text("Download"),
                              style: FilledButton.styleFrom(
                                backgroundColor: appColors.accent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: appColors.accent
                                    .withOpacity(0.6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                        /// ERROR MESSAGE
                        if (status == "FAILED" && job.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: appColors.redLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: appColors.red.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: appColors.red,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      job.errorMessage ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: appColors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
