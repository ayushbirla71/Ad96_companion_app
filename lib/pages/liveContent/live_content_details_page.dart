import 'package:flutter/material.dart';
import '../../models/liveContent.dart';

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
    if (status == "active") return Colors.green;
    return Colors.grey;
  }

  IconData typeIcon(String type) {
    switch (type) {
      case "provider":
        return Icons.cloud;
      case "streaming":
        return Icons.live_tv;
      case "website":
        return Icons.language;
      default:
        return Icons.video_collection;
    }
  }

  Widget infoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Content Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Icon(
                    typeIcon(content.type),
                    size: 28,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        content.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor(content.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          content.status,
                          style: TextStyle(
                            color: statusColor(content.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// DETAILS
            infoTile(
              "Content Type",
              content.type,
              Icons.category,
            ),

            infoTile(
              "Duration",
              durationText(content.duration),
              Icons.timer,
            ),

            infoTile(
              "Created At",
              content.createdAt.toLocal().toString().split(".")[0],
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }
}