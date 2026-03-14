// class Carousel {
//   final String carouselId;
//   final String name;
//   final String status;
//   final int totalDuration;
//   final List<CarouselItem> items;

//   Carousel({
//     required this.carouselId,
//     required this.name,
//     required this.status,
//     required this.totalDuration,
//     required this.items,
//   });

//   /// optional universal id getter
//   String get id => carouselId;

//   factory Carousel.fromJson(Map<String, dynamic> json) {
//     return Carousel(
//       carouselId: json["carousel_id"] ?? "",
//       name: json["name"] ?? "",
//       status: json["status"] ?? "",
//       totalDuration: json["total_duration"] ?? 0,
//       items: (json["items"] as List? ?? [])
//           .map((e) => CarouselItem.fromJson(e))
//           .toList(),
//     );
//   }
// }

// class CarouselItem {
//   final String carouselItemId;
//   final int displayOrder;
//   final Ad ad;

//   CarouselItem({
//     required this.carouselItemId,
//     required this.displayOrder,
//     required this.ad,
//   });

//   factory CarouselItem.fromJson(Map<String, dynamic> json) {
//     return CarouselItem(
//       carouselItemId: json["carousel_item_id"] ?? "",
//       displayOrder: json["display_order"] ?? 0,
//       ad: Ad.fromJson(json["Ad"] ?? {}),
//     );
//   }
// }

// class Ad {
//   final String adId;
//   final String name;
//   final String url;
//   final int duration;

//   Ad({
//     required this.adId,
//     required this.name,
//     required this.url,
//     required this.duration,
//   });

//   factory Ad.fromJson(Map<String, dynamic> json) {
//     return Ad(
//       adId: json["ad_id"] ?? "",
//       name: json["name"] ?? "",
//       url: json["url"] ?? "",
//       duration: json["duration"] ?? 0,
//     );
//   }
// }





class Carousel {
  final String carouselId;
  final String name;
  final String status;
  final int totalDuration;
  final List<CarouselItem> items;
  final String? clientName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Carousel({
    required this.carouselId,
    required this.name,
    required this.status,
    required this.totalDuration,
    required this.items,
    this.clientName,
    this.createdAt,
    this.updatedAt,
  });

  String get id => carouselId;

  factory Carousel.fromJson(Map<String, dynamic> json) {
    return Carousel(
      carouselId: json["carousel_id"] ?? "",
      name: json["name"] ?? "",
      status: json["status"] ?? "",
      totalDuration: json["total_duration"] ?? 0,
      clientName: json["Client"]?["name"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
      items: (json["items"] as List? ?? [])
          .map((e) => CarouselItem.fromJson(e))
          .toList(),
    );
  }
}





class CarouselItem {
  final String id;
  final String? carouselItemId;
  final String? adId;
  final String? name;
  final int duration;
  final String? fileUrl;
  final int displayOrder;
  final bool isNew;
  final Ad? ad;

  CarouselItem({
    required this.id,
    this.carouselItemId,
    this.adId,
    this.name,
    required this.duration,
    this.fileUrl,
    required this.displayOrder,
    this.isNew = false,
    this.ad,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    return CarouselItem(
      id: json["carousel_item_id"] ?? "",
      carouselItemId: json["carousel_item_id"],
      adId: json["Ad"]?["ad_id"],
      name: json["Ad"]?["name"],
      duration: json["Ad"]?["duration"] ?? 0,
      displayOrder: json["display_order"] ?? 0,
      ad: json["Ad"] != null ? Ad.fromJson(json["Ad"]) : null,
    );
  }

  CarouselItem copyWith({
    String? name,
    int? duration,
    String? fileUrl,
    int? displayOrder,
  }) {
    return CarouselItem(
      id: id,
      carouselItemId: carouselItemId,
      adId: adId,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      fileUrl: fileUrl ?? this.fileUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isNew: isNew,
      ad: ad,
    );
  }

  Map<String, dynamic> toJson() {
    if (isNew) {
      return {
        "name": name,
        "duration": duration,
        "file_url": fileUrl,
        "display_order": displayOrder,
      };
    }

    return {
      "ad_id": adId,
      "display_order": displayOrder,
    };
  }
} 



class Ad {
  final String adId;
  final String name;
  final String url;
  final int duration;
  final String? status;

  Ad({
    required this.adId,
    required this.name,
    required this.url,
    required this.duration,
    this.status,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      adId: json["ad_id"] ?? "",
      name: json["name"] ?? "",
      url: json["url"] ?? "",
      duration: json["duration"] ?? 0,
      status: json["status"],
    );
  }
}