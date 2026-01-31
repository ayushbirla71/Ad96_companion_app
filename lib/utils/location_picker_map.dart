import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class LocationPickerMap extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(LatLng) onLocationSelect;

  const LocationPickerMap({
    super.key,
    this.initialPosition,
    required this.onLocationSelect,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  late LatLng position;
  final MapController mapController = MapController();
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition ?? const LatLng(20.5937, 78.9629); // India
  }

  void _updatePosition(LatLng p) {
    setState(() => position = p);
    widget.onLocationSelect(p);
    mapController.move(p, 14);
  }

  Future<List<Map<String, dynamic>>> _searchPlaces(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5";
    final res = await http.get(Uri.parse(url));

    final data = jsonDecode(res.body) as List;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🔍 SEARCH
        TypeAheadField<Map<String, dynamic>>(
          controller: searchCtrl,
          suggestionsCallback: _searchPlaces,
          itemBuilder: (context, item) {
            return ListTile(
              title: Text(item["display_name"]),
            );
          },
          onSelected: (item) {
            final lat = double.parse(item["lat"]);
            final lng = double.parse(item["lon"]);
            _updatePosition(LatLng(lat, lng));
          },
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: "Search location",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        /// 🗺️ MAP
        SizedBox(
          height: 400,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: position,
              initialZoom: 5,
              onTap: (_, latlng) => _updatePosition(latlng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: position,
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

        const SizedBox(height: 10),

        /// 📍 COORDS
        Text(
          "Location: ${position.latitude}, ${position.longitude}",
          style: const TextStyle(fontFamily: "monospace"),
        ),
      ],
    );
  }
}
