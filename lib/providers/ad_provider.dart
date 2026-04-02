import 'package:flutter/material.dart';
import '../models/ad.dart';
import '../services/ad_service.dart';

class AdProvider extends ChangeNotifier {
  List<Ad> ads = [];
  List<Ad> filteredAds = [];

  bool loading = false;
  String? error;

  String searchQuery = "";
  String statusFilter = "all";

  // 📡 Load Ads (Refresh works automatically)
  Future<void> loadAds() async {
    loading = true;
    error = null;
    notifyListeners(); // Tell UI to show loader

    try {
      final data = await AdService.fetchAds();
      ads = data.map((e) => Ad.fromJson(e)).toList();
      
      // 🔥 OPTIMIZATION: Filter the list directly here without calling 
      // applyFilters() to prevent firing an extra notifyListeners() prematurely.
      filteredAds = ads.where((ad) {
        final matchesSearch = ad.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        final matchesStatus =
            statusFilter == "all" || ad.status == statusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
      
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners(); // Tell UI to hide loader and show data
  }

  // 🔍 Search
  void setSearch(String query) {
    searchQuery = query;
    applyFilters();
  }

  // 🔽 Status Filter
  void setStatusFilter(String status) {
    statusFilter = status;
    applyFilters();
  }

  // 🧹 Clear Filters
  void clearFilters() {
    searchQuery = "";
    statusFilter = "all";
    applyFilters();
  }

  // 🧠 Apply all filters (Used for local UI updates)
  void applyFilters() {
    filteredAds = ads.where((ad) {
      final matchesSearch = ad.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesStatus =
          statusFilter == "all" || ad.status == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    notifyListeners();
  }
}