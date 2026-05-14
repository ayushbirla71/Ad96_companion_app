// import 'dart:convert';

// import '../models/subscription_model.dart';
// import '../services/api_service.dart';

// class SubscriptionService {
//   static Future<SubscriptionModel?> fetchMySubscription() async {
//     try {
//       final response = await ApiService.get("/subscription/my_active");

//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body);

//         if (body["data"] != null) {
//           return SubscriptionModel.fromJson(body["data"]);
//         }
//       }

//       return null;
//     } catch (e) {
//       print("Subscription Error: $e");
//       return null;
//     }
//   }
// }

import 'dart:convert';

import '../models/subscription_model.dart';
import '../services/api_service.dart';

class SubscriptionService {
  static Future<SubscriptionModel?> fetchMySubscription() async {
    final response = await ApiService.get("/subscription/my_active");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("body of subscription >>>>>>>>>>>> $body");

      return SubscriptionModel.fromJson(body["data"]);
    }

    throw Exception("Failed to load subscription");
  }

  static Future<List<dynamic>> fetchSubscriptionHistory() async {
    final response = await ApiService.get("/subscription/history");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return body["data"] ?? [];
    }

    throw Exception("Failed to load subscription history");
  }
}
