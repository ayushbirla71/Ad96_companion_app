// import 'dart:convert';

// import 'package:cms_app/services/api_service.dart';
// import 'package:flutter/material.dart';
// import 'add_device_step2.dart';
// import 'package:provider/provider.dart';
// import '../../providers/group_provider.dart';

// class AddDeviceStep1Page extends StatefulWidget {
//   const AddDeviceStep1Page({super.key});

//   @override
//   State<AddDeviceStep1Page> createState() => _AddDeviceStep1PageState();
// }

// class _AddDeviceStep1PageState extends State<AddDeviceStep1Page> {
//   final pairingController = TextEditingController();
//   final nameController = TextEditingController();
//   final tagsController = TextEditingController();

//   String? selectedGroup;
//   bool loading = false;
//   bool _isLoading = false;
//   Map<String, dynamic>? deviceInfo;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<GroupProvider>().loadGroups();
//     });
//   }

//   /// ✅ GROUP BOTTOM SHEET
//   void showGroupBottomSheet(GroupProvider groupProvider) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: groupProvider.groups.length,
//           itemBuilder: (context, index) {
//             final g = groupProvider.groups[index];

//             return ListTile(
//               leading: const Icon(Icons.group),
//               title: Text(g.name),
//               onTap: () {
//                 setState(() {
//                   selectedGroup = g.id;
//                 });
//                 Navigator.pop(context);
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   /// FETCH DEVICE
//   Future<void> fetchByPairingCode(String code) async {
//     setState(() => loading = true);

//     try {
//       final response = await ApiService.get("/device/new-register/$code");

//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body);

//         deviceInfo = {
//           "device_id": body['device_id'],
//           "deviceType": body['device_type'],
//           "androidId": body['android_id'],
//           "location": body['location'],
//           "status": body['status'],
//           "registrationStatus": body['registration_status'],
//         };

//         nameController.text = body['device_name'] ?? '';
//         tagsController.text = (body['tags'] as List?)?.join(', ') ?? '';
//       } else {
//         deviceInfo = null;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Invalid pairing code")),
//         );
//       }
//     } catch (e) {
//       deviceInfo = null;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }

//     setState(() => loading = false);
//   }

//   /// UPDATE + NEXT
//   Future<void> _updateDeviceAndContinue() async {
//     if (deviceInfo == null ||
//         nameController.text.isEmpty ||
//         selectedGroup == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Fill all required fields")),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final body = {
//         "device_name": nameController.text,
//         "group_id": selectedGroup,
//         "tags": tagsController.text
//             .split(',')
//             .map((e) => e.trim())
//             .where((e) => e.isNotEmpty)
//             .toList(),
//       };

//       final response = await ApiService.post(
//         "/device/update/${deviceInfo!['device_id']}",
//         body,
//       );

//       if (response.statusCode == 200) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => AddDeviceStep2Page(
//               deviceData: {
//                 "pairingCode": pairingController.text,
//                 "deviceName": nameController.text,
//                 "group_id": selectedGroup,
//                 "tags": body["tags"],
//                 ...deviceInfo!,
//               },
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Update failed")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final groupProvider = context.watch<GroupProvider>();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Device")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             /// PAIRING CODE
//             TextField(
//               controller: pairingController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: const InputDecoration(
//                 labelText: "Pairing Code",
//                 counterText: "",
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 if (value.length == 6) {
//                   fetchByPairingCode(value);
//                 } else {
//                   setState(() => deviceInfo = null);
//                 }
//               },
//             ),

//             if (loading)
//               const Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Center(child: CircularProgressIndicator()),
//               ),

//             if (deviceInfo != null) ...[
//               const SizedBox(height: 16),
//               Text("Device Type: ${deviceInfo!["deviceType"]}"),
//               Text("Android ID: ${deviceInfo!["androidId"]}"),
//             ],

//             const SizedBox(height: 20),

//             /// DEVICE NAME
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "Device Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// ✅ GROUP SELECT (BOTTOM SHEET)
//             groupProvider.loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : GestureDetector(
//                     onTap: () => showGroupBottomSheet(groupProvider),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14, horizontal: 12),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             selectedGroup == null
//                                 ? "Select Group"
//                                 : groupProvider.groups
//                                     .firstWhere(
//                                         (g) => g.id == selectedGroup)
//                                     .name,
//                             style: TextStyle(
//                               color: selectedGroup == null
//                                   ? Colors.grey
//                                   : Colors.black,
//                             ),
//                           ),
//                           const Icon(Icons.arrow_drop_down),
//                         ],
//                       ),
//                     ),
//                   ),

//             const SizedBox(height: 16),

//             /// TAGS
//             TextField(
//               controller: tagsController,
//               enabled: deviceInfo != null,
//               decoration: const InputDecoration(
//                 labelText: "Tags (comma separated)",
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 30),

//             /// BUTTON
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _updateDeviceAndContinue,
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text("Continue"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms_app/services/api_service.dart';
import 'package:cms_app/theme/app_colors.dart'; // Verified Theme Path
import '../../providers/group_provider.dart';
import 'add_device_step2.dart';

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
  
  // NEW: State for the orientation override checkbox
  bool overrideOrientation = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroups();
    });
  }

  @override
  void dispose() {
    pairingController.dispose();
    nameController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  /// ✅ Premium Bottom Sheet with Live Search & Orientation Filtering
  void showGroupBottomSheet(GroupProvider groupProvider) {
    String searchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            // 1. Get the device orientation
            final deviceOri = deviceInfo?['orientation']?.toString().toLowerCase();

            print("device oriantation ${deviceOri}");

            // 2. Filter groups by search query AND orientation
            final filteredGroups = groupProvider.groups.where((g) {
              
              // Check Search
              final matchesSearch = g.name.toLowerCase().contains(searchQuery.toLowerCase());
              
              // Check Orientation
              bool matchesOrientation = true;
              
              // If override is NOT checked, and we know the device orientation, enforce the rule
              if (!overrideOrientation && deviceOri != null && deviceOri.isNotEmpty) {
                try {
                  // 👉 NOTE: Change 'g.orientation' if your Group model uses a different property name
                  final groupOri = (g as dynamic).orientation?.toString().toLowerCase(); 
                  print("group Detaisl..... ${g}");
                  if (groupOri != null && groupOri.isNotEmpty) {
                    matchesOrientation = (groupOri == deviceOri);
                  }
                } catch (e) {
                  // Failsafe if the property doesn't exist on the group model
                  debugPrint("Group orientation property not found: $e");
                }
              }

              return matchesSearch && matchesOrientation;
            }).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: appColors.bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: appColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "Select Group",
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SEARCH INPUT
                    TextField(
                      style: TextStyle(color: appColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search groups...",
                        hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: appColors.textMuted, size: 18),
                        filled: true,
                        fillColor: appColors.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: appColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: appColors.accent, width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // GROUP LIST
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: appColors.border),
                      ),
                      child: filteredGroups.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  overrideOrientation 
                                    ? "No groups match your search." 
                                    : "No groups match this device's orientation.\nTry overriding the restriction.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: appColors.textMuted, fontSize: 13, height: 1.5),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredGroups.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1, 
                                thickness: 1, 
                                color: appColors.borderLight,
                                indent: 52,
                              ),
                              itemBuilder: (context, index) {
                                final g = filteredGroups[index];
                                final isCurrent = selectedGroup == g.id;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCurrent ? appColors.accentLight : appColors.surfaceHigh,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.group_rounded, 
                                      color: isCurrent ? appColors.accent : appColors.textSecondary,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    g.name,
                                    style: TextStyle(
                                      color: isCurrent ? appColors.accent : appColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                    ),
                                  ),
                                  trailing: isCurrent 
                                      ? Icon(Icons.check_circle_rounded, color: appColors.accent, size: 18) 
                                      : null,
                                  onTap: () {
                                    setState(() => selectedGroup = g.id);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
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
          // NEW: Capture orientation from API (checking standard keys)
          "orientation": body['orientation'] ?? body['device_orientation'] ?? "unknown",
        };

        nameController.text = body['device_name'] ?? '';
        tagsController.text = (body['tags'] as List?)?.join(', ') ?? '';
        
        // Reset override and selection when new device is fetched
        overrideOrientation = false;
        selectedGroup = null; 
      } else {
        deviceInfo = null;
        _showSnackBar("Invalid pairing code", isError: true);
      }
    } catch (e) {
      deviceInfo = null;
      _showSnackBar("Error: $e", isError: true);
    }

    setState(() => loading = false);
  }

  /// UPDATE + NEXT
  Future<void> _updateDeviceAndContinue() async {
    if (deviceInfo == null || nameController.text.trim().isEmpty || selectedGroup == null) {
      _showSnackBar("Fill all required fields", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = {
        "device_name": nameController.text.trim(),
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
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddDeviceStep2Page(
              deviceData: {
                "pairingCode": pairingController.text,
                "deviceName": nameController.text.trim(),
                "group_id": selectedGroup,
                "overrideOrientation":overrideOrientation,
                "tags": body["tags"],
                ...deviceInfo!,
              },
            ),
          ),
        );
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

  InputDecoration _inputDecoration({required String labelText, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: appColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: appColors.textMuted, size: 18),
      suffixIcon: suffix,
      counterText: "",
      filled: true,
      fillColor: appColors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: appColors.accent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

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
          "Add Device",
          style: TextStyle(color: appColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// ─── PAIRING CODE INPUT ───
            TextField(
              controller: pairingController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: _inputDecoration(
                labelText: "Pairing Code",
                icon: Icons.pin_rounded,
                suffix: loading
                    ? Transform.scale(
                        scale: 0.5,
                        child: CircularProgressIndicator(color: appColors.accent, strokeWidth: 2.5),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.trim().length == 6) {
                  fetchByPairingCode(value.trim());
                } else {
                  setState(() => deviceInfo = null);
                }
              },
            ),

            /// ─── DETECTED DEVICE SUMMARY INFO CARD ───
            if (deviceInfo != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: appColors.border),
                  boxShadow: [
                    BoxShadow(color: appColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: appColors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "Device Found Successfully",
                          style: TextStyle(color: appColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, thickness: 1, color: appColors.borderLight),
                    const SizedBox(height: 12),
                    _infoRow("Device Type", deviceInfo!["deviceType"] ?? "Unknown"),
                    const SizedBox(height: 8),
                    _infoRow("Hardware ID", deviceInfo!["androidId"] ?? "N/A"),
                    const SizedBox(height: 8),
                    // NEW: Display the detected orientation
                    _infoRow(
                      "Orientation", 
                      (deviceInfo!["orientation"] ?? "Unknown").toString().toUpperCase()
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            _sectionLabel("Configuration Details"),
            const SizedBox(height: 10),

            /// ─── DEVICE NAME INPUT ───
            TextField(
              controller: nameController,
              style: TextStyle(color: appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: _inputDecoration(labelText: "Device Name", icon: Icons.abc_rounded),
            ),

            const SizedBox(height: 16),

            /// ─── OVERRIDE CHECKBOX & GROUP PICKER ───
            if (deviceInfo != null) ...[
              // Checkbox row
              GestureDetector(
                onTap: () {
                  setState(() {
                    overrideOrientation = !overrideOrientation;
                    // Reset group selection if they toggle this, to force re-selection
                    selectedGroup = null; 
                  });
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: overrideOrientation,
                        onChanged: (val) {
                          setState(() {
                            overrideOrientation = val ?? false;
                            selectedGroup = null;
                          });
                        },
                        activeColor: appColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Show all groups (Override Orientation)",
                        style: TextStyle(color: appColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            groupProvider.loading
                ? Center(child: CircularProgressIndicator(color: appColors.accent))
                : GestureDetector(
                    onTap: () {
                      if (deviceInfo == null) {
                        _showSnackBar("Please enter a pairing code first.", isError: true);
                        return;
                      }
                      showGroupBottomSheet(groupProvider);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: deviceInfo == null ? appColors.surfaceHigh : appColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: appColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group_work_rounded, color: appColors.textMuted, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedGroup == null
                                  ? "Select Group Assignment"
                                  : groupProvider.groups
                                      .firstWhere((g) => g.id == selectedGroup, orElse: () => groupProvider.groups.first)
                                      .name,
                              style: TextStyle(
                                color: selectedGroup == null ? appColors.textMuted : appColors.textPrimary,
                                fontSize: 14,
                                fontWeight: selectedGroup == null ? FontWeight.w500 : FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: appColors.textMuted, size: 20),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 16),

            /// ─── TAGS INPUT ───
            TextField(
              controller: tagsController,
              enabled: deviceInfo != null,
              style: TextStyle(color: deviceInfo != null ? appColors.textPrimary : appColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: _inputDecoration(labelText: "Tags (comma separated)", icon: Icons.local_offer_rounded),
            ),

            const SizedBox(height: 36),

            /// ─── SUBMIT ACTION BUTTON ───
            GestureDetector(
              onTap: _isLoading ? null : _updateDeviceAndContinue,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: [appColors.accent, const Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
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
                      : const Text(
                          "Continue",
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(color: appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.2),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: appColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: appColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}