import 'dart:convert';
import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddDeviceStep2Page extends StatefulWidget {
  final Map<String, dynamic> deviceData;

  const AddDeviceStep2Page({super.key, required this.deviceData});

  @override
  State<AddDeviceStep2Page> createState() => _AddDeviceStep2PageState();
}

class _AddDeviceStep2PageState extends State<AddDeviceStep2Page> {
  LatLng? selectedLocation;
  bool _isLoading = false;

  Future<void> save() async {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select device location")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        "group_id": widget.deviceData["group_id"],
        "location": {
          "lat": selectedLocation!.latitude,
          "lng": selectedLocation!.longitude,
          "address": "Selected from map",
        },
      };

      print("📦 Payload: $payload");

      final response = await ApiService.post(
        "/device/update/location/${widget.deviceData["device_id"]}",
        payload,
      );

      final data = jsonDecode(response.body);
      print("✅ Response: $data");

      if (response.statusCode == 200) {
        Navigator.popUntil(context, (r) => r.isFirst);
      } else {
        _snack("Update failed");
      }
    } catch (e) {
      _snack("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final LatLng defaultPosition =
        selectedLocation ?? const LatLng(20.5937, 78.9629); // India

    return Scaffold(
      appBar: AppBar(title: const Text("Select Device Location")),
      body: Column(
        children: [
          /// 🗺️ MAP
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: defaultPosition,
                initialZoom: 5,
                onTap: (_, latlng) {
                  setState(() => selectedLocation = latlng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  // subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName:'com.demokrito.cms_app'
                  
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          /// 📍 LOCATION INFO
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  selectedLocation == null
                      ? "Tap on map to select location"
                      : "Lat: ${selectedLocation!.latitude}, Lng: ${selectedLocation!.longitude}",
                  style: const TextStyle(fontFamily: "monospace"),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : save,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Device"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}













// import 'dart:convert';
// import 'package:cms_app/services/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; // ✅ NEW
// import 'package:latlong2/latlong.dart';

// class AddDeviceStep2Page extends StatefulWidget {
//   final Map<String, dynamic> deviceData;

//   const AddDeviceStep2Page({super.key, required this.deviceData});

//   @override
//   State<AddDeviceStep2Page> createState() => _AddDeviceStep2PageState();
// }

// class _AddDeviceStep2PageState extends State<AddDeviceStep2Page> {
//   LatLng? selectedLocation;
//   bool _isLoading = false;

// final _tileProvider =
//     FMTCStore('mapStore').getTileProvider();

//   Future<void> save() async {
//     if (selectedLocation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select device location")),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final payload = {
//         "group_id": widget.deviceData["group_id"],
//         "location": {
//           "lat": selectedLocation!.latitude,
//           "lng": selectedLocation!.longitude,
//           "address": "Selected from map",
//         },
//       };

//       print("📦 Payload: $payload");

//       final response = await ApiService.post(
//         "/device/update/location/${widget.deviceData["device_id"]}",
//         payload,
//       );

//       print("🔐 Status Code: ${response.statusCode}");
//       print("🔐 Body: ${response.body}");

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         Navigator.popUntil(context, (r) => r.isFirst);
//       } else {
//         _snack(data.toString());
//       }
//     } catch (e) {
//       _snack("Error: $e");
//     }

//     setState(() => _isLoading = false);
//   }

//   void _snack(String msg) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final LatLng defaultPosition =
//         selectedLocation ?? const LatLng(20.5937, 78.9629); // India

//     return Scaffold(
//       appBar: AppBar(title: const Text("Select Device Location")),
//       body: Column(
//         children: [
//           /// 🗺️ MAP
//           Expanded(
//             child: FlutterMap(
//               options: MapOptions(
//                 initialCenter: defaultPosition,
//                 initialZoom: 5,
//                 onTap: (_, latlng) {
//                   setState(() => selectedLocation = latlng);
//                 },
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: const ['a', 'b', 'c'],

//                   // 🔥 IMPORTANT FIXES
//                   tileProvider: _tileProvider, // ✅ caching
//                   userAgentPackageName:
//                       'com.demokrito.cms_app', // ✅ required by OSM
//                 ),

//                 if (selectedLocation != null)
//                   MarkerLayer(
//                     markers: [
//                       Marker(
//                         point: selectedLocation!,
//                         width: 40,
//                         height: 40,
//                         child: const Icon(
//                           Icons.location_pin,
//                           color: Colors.red,
//                           size: 40,
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),

//           /// 📍 LOCATION INFO
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 Text(
//                   selectedLocation == null
//                       ? "Tap on map to select location"
//                       : "Lat: ${selectedLocation!.latitude}, Lng: ${selectedLocation!.longitude}",
//                   style: const TextStyle(fontFamily: "monospace"),
//                 ),

//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : save,
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text("Save Device"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }