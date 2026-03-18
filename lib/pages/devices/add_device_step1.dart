import 'dart:convert';

import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'add_device_step2.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';

class AddDeviceStep1Page extends StatefulWidget {
  const AddDeviceStep1Page({super.key});

  @override
  State<AddDeviceStep1Page> createState() => _AddDeviceStep1PageState();
}

class _AddDeviceStep1PageState extends State<AddDeviceStep1Page> {
  final pairingController = TextEditingController();
  final nameController = TextEditingController();
  final tagsController = TextEditingController();

  String? selectedGroup;
  bool loading = false;
  bool _isLoading = false;
  Map<String, dynamic>? deviceInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroups();
    });
  }

  /// ✅ GROUP BOTTOM SHEET
  void showGroupBottomSheet(GroupProvider groupProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupProvider.groups.length,
          itemBuilder: (context, index) {
            final g = groupProvider.groups[index];

            return ListTile(
              leading: const Icon(Icons.group),
              title: Text(g.name),
              onTap: () {
                setState(() {
                  selectedGroup = g.id;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  /// FETCH DEVICE
  Future<void> fetchByPairingCode(String code) async {
    setState(() => loading = true);

    try {
      final response = await ApiService.get("/device/new-register/$code");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        deviceInfo = {
          "device_id": body['device_id'],
          "deviceType": body['device_type'],
          "androidId": body['android_id'],
          "location": body['location'],
          "status": body['status'],
          "registrationStatus": body['registration_status'],
        };

        nameController.text = body['device_name'] ?? '';
        tagsController.text = (body['tags'] as List?)?.join(', ') ?? '';
      } else {
        deviceInfo = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid pairing code")),
        );
      }
    } catch (e) {
      deviceInfo = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  /// UPDATE + NEXT
  Future<void> _updateDeviceAndContinue() async {
    if (deviceInfo == null ||
        nameController.text.isEmpty ||
        selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = {
        "device_name": nameController.text,
        "group_id": selectedGroup,
        "tags": tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      };

      final response = await ApiService.post(
        "/device/update/${deviceInfo!['device_id']}",
        body,
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddDeviceStep2Page(
              deviceData: {
                "pairingCode": pairingController.text,
                "deviceName": nameController.text,
                "group_id": selectedGroup,
                "tags": body["tags"],
                ...deviceInfo!,
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Add Device")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// PAIRING CODE
            TextField(
              controller: pairingController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "Pairing Code",
                counterText: "",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.length == 6) {
                  fetchByPairingCode(value);
                } else {
                  setState(() => deviceInfo = null);
                }
              },
            ),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (deviceInfo != null) ...[
              const SizedBox(height: 16),
              Text("Device Type: ${deviceInfo!["deviceType"]}"),
              Text("Android ID: ${deviceInfo!["androidId"]}"),
            ],

            const SizedBox(height: 20),

            /// DEVICE NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Device Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// ✅ GROUP SELECT (BOTTOM SHEET)
            groupProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () => showGroupBottomSheet(groupProvider),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedGroup == null
                                ? "Select Group"
                                : groupProvider.groups
                                    .firstWhere(
                                        (g) => g.id == selectedGroup)
                                    .name,
                            style: TextStyle(
                              color: selectedGroup == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 16),

            /// TAGS
            TextField(
              controller: tagsController,
              enabled: deviceInfo != null,
              decoration: const InputDecoration(
                labelText: "Tags (comma separated)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateDeviceAndContinue,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}