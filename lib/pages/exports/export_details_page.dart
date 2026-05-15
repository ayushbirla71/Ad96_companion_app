import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/export_job.dart';
import '../../providers/export_provider.dart';

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
        return Colors.red;

      case "QUEUED":
        return Colors.orange;

      case "COMPLETED":
        return Colors.green;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExportProvider>();

    if (provider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Exports")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITLE
              const Text(
                "Exports",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                "List of export jobs",
                style: TextStyle(color: Colors.grey.shade600),
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

                  return Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,

                      borderRadius: BorderRadius.circular(16),

                      border: status == "FAILED"
                          ? Border.all(color: Colors.red)
                          : null,
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

                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Icon(Icons.layers, size: 18),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// JOB ID
                        Text(
                          "Job ID: ${(job.jobId ?? "").toString().substring(0, 8)}...",

                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 6),

                        /// STATUS
                        Text(
                          "Status: $status",

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// DEVICE
                        Text(
                          "Device: ${job.deviceId ?? "All Devices"}",

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// PROGRESS BAR
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),

                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 8,
                            color: color,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// PROGRESS ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text(
                              "$progress%",
                              style: const TextStyle(fontSize: 12),
                            ),

                            Text(
                              "Completed",

                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// DOWNLOAD BUTTON
                        if (progress == 100 && job.downloadUrl != null)
                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton.icon(
                              onPressed: () {
                                handleDownload(job.downloadUrl ?? "");
                              },

                              icon: const Icon(Icons.download),

                              label: const Text("Download"),
                            ),
                          ),

                        /// ERROR MESSAGE
                        if (status == "FAILED" && job.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 18,
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    job.errorMessage ?? "",

                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
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
