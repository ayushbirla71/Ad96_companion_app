// // providers/carousel_provider.dart
// import 'package:cms_app/services/carousel_services.dart';
// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../models/carousel.dart';
// import 'dart:convert';

// class CarouselProvider extends ChangeNotifier {
//   List<Carousel> carousels = [];
//   bool loading = false;
//   String? error;

//   /// Fetch all carousels from API
//   Future<void> loadCarousels() async {
//     loading = true;
//     error = null;
//     notifyListeners();

//   try {
//       final data = await CarouselServices.fetchCarousel();
//       print("api ressss ..////////// ${data}");
//       carousels = data.map((json) => Carousel.fromJson(json)).toList();

//       print("after api../// ${carousels}");

//     } catch (e) {
//       error = e.toString();
//     }

//     loading = false;
//     notifyListeners();

//   }
// }import 'package:cms_app/services/carousel_services.dart';
import 'dart:io';

import 'package:cms_app/services/carousel_services.dart';
import 'package:flutter/material.dart';
import '../models/carousel.dart';

class CarouselProvider extends ChangeNotifier {

  List<Carousel> _carousels = [];

  bool loading = false;
  String search = "";
  String statusFilter = "all";

  List<Carousel> get carousels => _carousels;

  /// FILTERED LIST
  List<Carousel> get filteredCarousels {

    return _carousels.where((c) {

      final matchSearch =
          c.name.toLowerCase().contains(search.toLowerCase());

      final matchStatus =
          statusFilter == "all" || c.status == statusFilter;

      return matchSearch && matchStatus;

    }).toList();
  }

  /// GET SINGLE CAROUSEL
  Carousel? getCarouselById(String id) {

    try {

      return _carousels.firstWhere(
        (c) => c.carouselId == id,
      );

    } catch (_) {

      return null;

    }
  }

  /// LOAD CAROUSELS
  Future<void> loadCarousels() async {

    try {

      loading = true;
      notifyListeners();

      final data = await CarouselService.fetchCarousels();

      _carousels = data
          .map<Carousel>((e) => Carousel.fromJson(e))
          .toList();

    } catch (e) {

      debugPrint("Load carousel error: $e");

    } finally {

      loading = false;
      notifyListeners();

    }
  }

  /// SEARCH
  void setSearch(String value) {

    search = value;
    notifyListeners();

  }

  /// STATUS FILTER
  void setStatus(String value) {

    statusFilter = value;
    notifyListeners();

  }

  /// DELETE
  Future<void> deleteCarousel(String id) async {

    try {

      await CarouselService.deleteCarousel(id);

      _carousels.removeWhere(
        (c) => c.carouselId == id,
      );

      notifyListeners();

    } catch (e) {

      debugPrint("Delete carousel error: $e");

    }

  }

  /// TOGGLE STATUS
  Future<void> toggleStatus(Carousel c) async {

    try {

      final newStatus =
          c.status == "active" ? "inactive" : "active";

      await CarouselService.toggleStatus(
        c.carouselId,
        newStatus,
      );

      await loadCarousels();

    } catch (e) {

      debugPrint("Toggle status error: $e");

    }

  }

  /// CREATE
  Future<bool> createCarousel({
    required String name,
    required List<CarouselItem> items,
  }) async {

    try {

      loading = true;
      notifyListeners();

      final payload = {
        "name": name,
        "items": items.map((e) => e.toJson()).toList(),
      };

      await CarouselService.createCarousel(payload);

      await loadCarousels();

      return true;

    } catch (e) {

      debugPrint("Create carousel error: $e");

      return false;

    } finally {

      loading = false;
      notifyListeners();

    }

  }

  /// UPDATE
  Future<bool> updateCarousel({
    required String carouselId,
    required String name,
    required List<CarouselItem> items,
  }) async {

    try {

      loading = true;
      notifyListeners();

      final payload = {
        "name": name,
        "items": items.map((e) => e.toJson()).toList(),
      };

      await CarouselService.updateCarousel(
        carouselId,
        payload,
      );

      await loadCarousels();

      return true;

    } catch (e) {

      debugPrint("Update carousel error: $e");

      return false;

    } finally {

      loading = false;
      notifyListeners();

    }

  }



  /// FETCH ADS FOR DROPDOWN
Future<List<dynamic>> fetchAds() async {

  try {

    final data = await CarouselService.fetchAds();

    return data;

  } catch (e) {

    debugPrint("Fetch ads error: $e");

    return [];

  }

}

/// UPLOAD AD FILE
Future<String> uploadAdFile(File file) async {

  try {

    loading = true;
    notifyListeners();

    final url = await CarouselService.uploadAdFile(file);

    return url;

  } catch (e) {

    debugPrint("Upload file error: $e");

    rethrow;

  } finally {

    loading = false;
    notifyListeners();

  }

}

}