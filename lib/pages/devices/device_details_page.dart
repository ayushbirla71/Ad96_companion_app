import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms_app/services/api_service.dart';
import '../../models/device.dart';
import '../../providers/device_provider.dart';

class DeviceDetailsPage extends StatefulWidget {
  final Device device;

  const DeviceDetailsPage({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final isOnline =
        widget.device.status == "online" || widget.device.status == "active";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.deviceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Delete Device",
            onPressed: _deleting ? null : () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row("Device Name", widget.device.deviceName),
                _row("Device Type", widget.device.deviceType),
                _row("Group", widget.device.groupName),
                _row(
                  "Status",
                  widget.device.status,
                  valueColor: isOnline ? Colors.green : Colors.red,
                ),
                _row("Device ID", widget.device.deviceId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // CONFIRM DELETE
  // ===========================
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Device"),
        content: const Text(
          "Are you sure you want to delete this device? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDevice(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // DELETE DEVICE API CALL
  // ===========================
  Future<void> _deleteDevice(BuildContext context) async {
    final provider = context.read<DeviceProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _deleting = true);

    try {
      final response = await ApiService.post(
        "/device/delete/${widget.device.deviceId}",{}
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        // ✅ Remove locally AFTER API success
        provider.devices.removeWhere(
          (d) => d.deviceId == widget.device.deviceId,
        );
        provider.notifyListeners();

        messenger.showSnackBar(
          const SnackBar(content: Text("Device deleted successfully")),
        );

        Navigator.pop(context); // back to device list
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "Failed to delete device (${response.statusCode})",
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Error deleting device: $e")),
      );
    } finally {
      setState(() => _deleting = false);
    }
  }
}
