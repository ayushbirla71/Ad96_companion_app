class ExportJob {
  final String jobId;
  final String jobType;
  final String? deviceId;
  final String status;
  final int progressPercent;
  final String? errorMessage;
  final String? downloadUrl;
  final String createdAt;

  ExportJob({
    required this.jobId,
    required this.jobType,
    required this.deviceId,
    required this.status,
    required this.progressPercent,
    required this.createdAt,
    this.errorMessage,
    this.downloadUrl,
  });

  factory ExportJob.fromJson(Map<String, dynamic> json) {
    return ExportJob(
      jobId: json["job_id"] ?? "",
      jobType: json["job_type"] ?? "",
      deviceId: json["device_id"],
      status: json["status"] ?? "",
      progressPercent: json["progress_percent"] ?? 0,
      errorMessage: json["error_message"],
      downloadUrl: json["download_url"],
      createdAt: json["created_at"] ?? "",
    );
  }
}
