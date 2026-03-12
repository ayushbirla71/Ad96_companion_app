// class ScheduleAd {
//   final String adId;
//   final String adName;
//   final int adDuration;
//   final List<ScheduleGroup> groups;

//   ScheduleAd({
//     required this.adId,
//     required this.adName,
//     required this.adDuration,
//     required this.groups,
//   });

//   factory ScheduleAd.fromJson(Map<String, dynamic> json) {
//     return ScheduleAd(
//       adId: json["adId"],
//       adName: json["adName"] ?? "",
//       adDuration: json["adDuration"] ?? 0,
//       groups: (json["groups"] as List)
//           .map((g) => ScheduleGroup.fromJson(g))
//           .toList(),
//     );
//   }
// }


class ScheduleAd {
  final String adId;
  final String contentId;
  final String carouselId;

  final String adName;
  final int adDuration;

  final String contentName;
  final int contentDuration;

  final String carouselName;
  final int carouselDuration;

  final List<ScheduleGroup> groups;

  ScheduleAd({
    required this.adId,
    required this.contentId,
    required this.carouselId,
    required this.adName,
    required this.adDuration,
    required this.contentName,
    required this.contentDuration,
    required this.carouselName,
    required this.carouselDuration,
    required this.groups,
  });

  factory ScheduleAd.fromJson(Map<String, dynamic> json) {
    return ScheduleAd(
      adId: json["adId"] ?? "",
      contentId: json["contentId"] ?? "",
      carouselId: json["carouselId"] ?? "",

      adName: json["adName"] ?? "",
      adDuration: json["adDuration"] ?? 0,

      contentName: json["contentName"] ?? "",
      contentDuration: json["contentDuration"] ?? 0,

      carouselName: json["carouselName"] ?? "",
      carouselDuration: json["carouselDuration"] ?? 0,

      groups: (json["groups"] as List? ?? [])
          .map((g) => ScheduleGroup.fromJson(g))
          .toList(),
    );
  }
}

class ScheduleGroup {
  final String groupId;
  final String groupName;
  final String fromDate;
  final String toDate;
  final String completedPercentage;
 final int totalDays;

  ScheduleGroup({
    required this.groupId,
    required this.groupName,
    required this.fromDate,
    required this.toDate,
    required this.completedPercentage,
    required this.totalDays,
  });

  factory ScheduleGroup.fromJson(Map<String, dynamic> json) {
    return ScheduleGroup(
      groupId: json["groupId"],
      groupName: json["groupName"] ?? "",
      fromDate: json["fromDate"] ?? "",
      toDate: json["toDate"] ?? "",
      completedPercentage: json["completedPercentage"] ?? "0%",
      totalDays: json['totalDays'] ?? 0,
    );
  }
}
