import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cms_app/services/api_service.dart';
import 'package:cms_app/theme/app_colors.dart'; // Make sure this path is correct

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
      _showSnackBar("Please tap on the map to select a location", isError: true);
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

      debugPrint("📦 Payload: $payload");
       debugPrint("📦 Device Id: ${widget.deviceData["device_id"]}");

      final response = await ApiService.post(
        "/device/update/location/${widget.deviceData["device_id"]}",
        payload,
      );

      final data = jsonDecode(response.body);
      debugPrint("✅ Response: $data");

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showSnackBar("Device added successfully!");
        Navigator.popUntil(context, (r) => r.isFirst);
      } else {
        _showSnackBar("Update failed", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error: $e", isError: true);
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? appColors.red : appColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default to the center of India if no location is selected
    final LatLng defaultPosition = selectedLocation ?? const LatLng(20.5937, 78.9629);

    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: appColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: appColors.border),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: appColors.textSecondary, size: 15),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pin Location",
          style: TextStyle(color: appColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: Stack(
        children: [
          /// ─── 🗺️ FULL SCREEN MAP ───
          Positioned.fill(
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
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.demokrito.cms_app',
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 60,
                        height: 60,
                        alignment: Alignment.topCenter, // Ensures the bottom tip points to the exact coordinate
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: appColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: appColors.accent.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Icon(Icons.tv_rounded, color: Colors.white, size: 16),
                            ),
                            // Map Pin Tail
                            Container(
                              width: 3,
                              height: 12,
                              decoration: BoxDecoration(
                                color: appColors.textPrimary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          /// ─── 📍 FLOATING ACTION CARD ───
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: appColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: appColors.shadow,
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location Info Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selectedLocation == null ? appColors.surfaceHigh : appColors.accentLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded, 
                          color: selectedLocation == null ? appColors.textMuted : appColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedLocation == null ? "No Location Set" : "Coordinates Saved",
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedLocation == null
                                  ? "Tap anywhere on the map to drop a pin."
                                  : "${selectedLocation!.latitude.toStringAsFixed(4)}°, ${selectedLocation!.longitude.toStringAsFixed(4)}°",
                              style: TextStyle(
                                color: appColors.textSecondary,
                                fontSize: 12,
                                fontWeight: selectedLocation == null ? FontWeight.w500 : FontWeight.w600,
                                fontFamily: selectedLocation == null ? null : "monospace",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  GestureDetector(
                    onTap: _isLoading ? null : save,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: LinearGradient(
                          colors: selectedLocation == null 
                              ? [appColors.surfaceHigh, appColors.border] 
                              : [appColors.accent, const Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: selectedLocation == null ? [] : [
                          BoxShadow(
                            color: appColors.accent.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                "Save Device",
                                style: TextStyle(
                                  color: selectedLocation == null ? appColors.textMuted : Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
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