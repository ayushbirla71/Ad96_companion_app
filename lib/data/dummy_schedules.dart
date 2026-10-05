import '../models/schedule.dart';

final List<ScheduleAd> schedulesList = [
  ScheduleAd(
    adId: "ad_1",
    contentId: "",
    carouselId: "",
    adName: "Blood Donation Schedule",
    adDuration: 15,
    contentName: "",
    contentDuration: 0,
    carouselName: "",
    carouselDuration: 0,
    contentType: "ad",
    groups: [
      ScheduleGroup(
        groupId: "group_1",
        groupName: "CLUB HOUSE",
        fromDate: "23-01-2026",
        toDate: "23-01-2026",
        completedPercentage: "100%",
        totalDays: 1,
      ),
    ],
  ),
];

