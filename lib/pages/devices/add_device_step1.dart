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

    print("device idddd ${deviceInfo!['device_id']}");

    final response = await ApiService.post(
      "/device/update/${deviceInfo!['device_id']}",
      body,
    );

    final data = jsonDecode(response.body);

    print("responcesss..... ${data}");

    if (response.statusCode == 200) {
      // ✅ Navigate to step 2 after successful update
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
        SnackBar(content: Text("Update failed")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  setState(() => _isLoading = false);
}



  Future<void> fetchByPairingCode(String code) async {
    setState(() => loading = true);

    try {
      final response = await ApiService.get("/device/new-register/$code");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("bodya pairing >>>>>>>>>>>> $body");

        deviceInfo = {
          "device_id": body['device_id'],
          "deviceType": body['device_type'],
          "androidId": body['android_id'],
          "location": body['location'],
          "status": body['status'],
          "registrationStatus": body['registration_status'],
        };

        // ✅ PREFILL INPUT FIELDS (EDITABLE)
        nameController.text = body['device_name'] ?? '';
        tagsController.text = (body['tags'] as List?)?.join(', ') ?? '';

        // ✅ Optional: preselect group if exists
        // selectedGroup = body['group_id'];
      } else {
        deviceInfo = null;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid pairing code")));
      }
    } catch (e) {
      deviceInfo = null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => loading = false);
  }
  void next() {
    if (deviceInfo == null ||
        nameController.text.isEmpty ||
        selectedGroup == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all required fields")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDeviceStep2Page(
          deviceData: {
            "pairingCode": pairingController.text,
            "deviceName": nameController.text,
            "group": selectedGroup,
            "tags": tagsController.text,
            ...deviceInfo!,
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load groups from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroups();
    });
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
            TextField(
              controller: pairingController,
              keyboardType: TextInputType.number,
              maxLength: 6, // only allow 6 digits
              decoration: const InputDecoration(
                labelText: "Pairing Code",
                counterText: "", // hides the counter
              ),
              onChanged: (value) {
                if (value.length == 6) {
                  fetchByPairingCode(value); // call API automatically
                } else {
                  setState(() => deviceInfo = null); // reset if incomplete
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

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Device Name"),
            ),

            const SizedBox(height: 12),

            groupProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: selectedGroup,
                    hint: const Text("Select Group"),
                    items: groupProvider.groups
                        .map(
                          (g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedGroup = v),
                  ),

            const SizedBox(height: 12),

            TextField(
              controller: tagsController,
              enabled: deviceInfo != null,
              decoration: const InputDecoration(
                labelText: "Tags (comma separated)",
              ),
            ),

            const SizedBox(height: 30),

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
