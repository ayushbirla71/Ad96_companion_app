import 'package:flutter/material.dart';
import '../../models/group.dart';
import '../../services/api_service.dart';

class GroupDetailsPage extends StatefulWidget {
  final Group group;

  const GroupDetailsPage({super.key, required this.group});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late bool rcsEnabled;
  late bool placeholderEnabled;
  late bool logoEnabled;

  late TextEditingController messageCtrl;

  bool editFeatures = false;
  bool editMessage = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    // ✅ Initial UI state comes ONLY from passed group
    rcsEnabled = widget.group.rcsEnabled;
    placeholderEnabled = widget.group.placeholderEnabled;
    logoEnabled = widget.group.logoEnabled;

   print("...........//////////  ${widget.group.toString()}");
    messageCtrl = TextEditingController(text: widget.group.message);
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            tooltip: "Refresh group devices",
            onPressed: loading ? null : _refreshGroup,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row("Client", widget.group.clientName),
                _row("Group ID", widget.group.id),
                _row("Reg Code", widget.group.regCode),
                _row("Devices", widget.group.deviceCount.toString()),

                const Divider(height: 32),

                // =========================
                // FEATURES SECTION
                // =========================
                _sectionHeader(
                  title: "Group Features",
                  editing: editFeatures,
                  onEdit: () =>
                      setState(() => editFeatures = !editFeatures),
                ),

                SwitchListTile(
                  title: const Text("RCS Enabled"),
                  value: rcsEnabled,
                  onChanged:
                      editFeatures ? (v) => setState(() => rcsEnabled = v) : null,
                ),
                SwitchListTile(
                  title: const Text("Placeholder Enabled"),
                  value: placeholderEnabled,
                  onChanged: editFeatures
                      ? (v) => setState(() => placeholderEnabled = v)
                      : null,
                ),
                SwitchListTile(
                  title: const Text("Logo Enabled"),
                  value: logoEnabled,
                  onChanged:
                      editFeatures ? (v) => setState(() => logoEnabled = v) : null,
                ),

                if (editFeatures)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Update Features"),
                        onPressed: loading ? null : _updateFeatures,
                      ),
                    ),
                  ),

                const Divider(height: 32),

                // =========================
                // MESSAGE SECTION
                // =========================
                _sectionHeader(
                  title: "RCS Message",
                  editing: editMessage,
                  onEdit: () =>
                      setState(() => editMessage = !editMessage),
                ),

                TextField(
                  controller: messageCtrl,
                  enabled: editMessage,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter RCS message",
                  ),
                ),

                if (editMessage)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.message),
                        label: const Text("Update Message"),
                        onPressed: loading ? null : _updateMessage,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // UI HELPERS
  // =========================

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required bool editing,
    required VoidCallback onEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          icon: Icon(editing ? Icons.close : Icons.edit),
          label: Text(editing ? "Cancel" : "Edit"),
          onPressed: onEdit,
        ),
      ],
    );
  }

  // =========================
  // API CALLS
  // =========================

  /// 🔧 Update enable / disable flags
  Future<void> _updateFeatures() async {
    setState(() => loading = true);

    try {
      final response = await ApiService.put(
        "/device/update-group/${widget.group.id}",
        {
          "name": widget.group.name,
          "rcs_enabled": rcsEnabled,
          "placeholder_enabled": placeholderEnabled,
          "logo_enabled": logoEnabled,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => editFeatures = false);
        _snack("Group features updated");
      } else {
        _snack("Failed to update group (${response.statusCode})");
      }
    } catch (e) {
      _snack("Error updating group: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  /// 💬 Update RCS message (separate API)
  Future<void> _updateMessage() async {
    setState(() => loading = true);

    try {
      await ApiService.post(
        "/scroll-text",
        {
          "group_id": widget.group.id,
          "message": messageCtrl.text,
        },
      );

      setState(() => editMessage = false);
      _snack("Message updated successfully");
    } catch (e) {
      _snack("Failed to update message: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  /// 🔄 Backend-only refresh (NO UI update)
  Future<void> _refreshGroup() async {
    try {
      setState(() => loading = true);

      await ApiService.post(
        "/device/update-schedule/${widget.group.id}",
        {},
      );

      _snack("Group refresh triggered. Devices will sync shortly.");
    } catch (e) {
      _snack("Failed to refresh group: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
