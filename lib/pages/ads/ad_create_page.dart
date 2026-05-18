// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:file_picker/file_picker.dart';
// // import '../../services/ad_upload_service.dart';
// // import '../../services/api_service.dart';

// // class AddAdPage extends StatefulWidget {
// //   const AddAdPage({super.key});

// //   @override
// //   State<AddAdPage> createState() => _AddAdPageState();
// // }

// // class _AddAdPageState extends State<AddAdPage> {
// //   final _nameCtrl = TextEditingController();
// //   final _durationCtrl = TextEditingController();

// //   File? _file;
// //   String? _fileType;
// //   int progress = 0;
// //   String status = "";

// //   bool get isImage => _fileType == "image";

// //   void _showError(String message) {
// //   ScaffoldMessenger.of(context).showSnackBar(
// //     SnackBar(content: Text(message)),
// //   );
// // }

// //   Future<void> pickFile() async {
// //     final res = await FilePicker.platform.pickFiles(
// //       type: FileType.custom,
// //       allowedExtensions: ['jpg', 'png', 'mp4'],
// //     );

// //     if (res != null) {
// //       final path = res.files.single.path!;
// //       _file = File(path);
// //       _fileType = path.endsWith("mp4") ? "video" : "image";
// //       setState(() {});
// //     }
// //   }

// // Future<void> submit() async {
// //   if (_file == null || _nameCtrl.text.isEmpty) return;

// //   try {
// //     // 1️⃣ Upload file
// //     final uploadedFileName = await AdUploadService.uploadFile(
// //       file: _file!,
// //       onProgress: (p, s) {
// //         setState(() {
// //           progress = p;
// //           status = s;
// //         });
// //       },
// //     );

// //     print("uploaded flle ... ${uploadedFileName}");

// //     // 2️⃣ Call API
// //     final response = await ApiService.post("/ads/add", {
// //       "name": _nameCtrl.text,
// //       "file_url": uploadedFileName,
// //       "type": _fileType,
// //       "duration": isImage ? int.parse(_durationCtrl.text) : 0,
// //       "isMultipartUpload" : false
// //     });

// //     // 3️⃣ Handle response
// //     if (response.statusCode == 200 || response.statusCode == 201) {
// //       final data = jsonDecode(response.body);

// //       print("response form api ..... ${data}");

// //       if (data["success"] == true) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Ad added successfully")),
// //         );
// //         // Navigator.pop(context, true); // return success
// //       } else {
// //         _showError(data["message"] ?? "Something went wrong");
// //       }
// //     } else {
// //       print("error... ${response.body}");
// //       _showError("Server error (${response.statusCode})");
// //     }
// //   } catch (e) {
// //     _showError(e.toString());
// //   }
// // }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Add Ad")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: ListView(
// //           children: [
// //             TextField(
// //               controller: _nameCtrl,
// //               decoration: const InputDecoration(labelText: "Ad Name"),
// //             ),
// //             const SizedBox(height: 12),

// //             ElevatedButton.icon(
// //               icon: const Icon(Icons.upload),
// //               label: const Text("Select File"),
// //               onPressed: pickFile,
// //             ),

// //             if (_file != null) ...[
// //               const SizedBox(height: 10),
// //               Text("Selected: ${_file!.path.split('/').last}"),
// //             ],

// //             if (isImage)
// //               TextField(
// //                 controller: _durationCtrl,
// //                 keyboardType: TextInputType.number,
// //                 decoration:
// //                     const InputDecoration(labelText: "Duration (seconds)"),
// //               ),

// //             const SizedBox(height: 20),

// //             if (progress > 0) ...[
// //               LinearProgressIndicator(value: progress / 100),
// //               const SizedBox(height: 6),
// //               Text("$progress% • $status"),
// //             ],

// //             const SizedBox(height: 30),

// //             ElevatedButton(
// //               onPressed: submit,
// //               child: const Text("Upload Ad"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:convert';
// import 'dart:io';
// import 'package:cms_app/services/storage_service.dart';
// import 'package:cms_app/utils/feature_access.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';

// import '../../services/ad_upload_service.dart';
// import '../../services/api_service.dart';
// import '../../utils/auth_utils.dart'; // 👈 JWT role decoder

// class AddAdPage extends StatefulWidget {
//   const AddAdPage({super.key});

//   @override
//   State<AddAdPage> createState() => _AddAdPageState();
// }

// class _AddAdPageState extends State<AddAdPage> {
//   final _nameCtrl = TextEditingController();
//   final _durationCtrl = TextEditingController();

//   File? _file;
//   String? _fileType;
//   int progress = 0;
//   String status = "";
//   int? selectedImageDuration;

//   bool isAdmin = false;
//   bool loadingClients = false;
//   List<dynamic> clients = [];
//   String? selectedClientId;

//   bool get isImage => _fileType == "image";

//   @override
//   void initState() {
//     super.initState();
//     _initRoleAndClients();
//   }

//   /* ================= ROLE + CLIENT FETCH ================= */

//   Future<void> _initRoleAndClients() async {
//     final role = await AuthUtils.getRole();

//     print("rolllleeee ${role}");

//     if (role == "Admin") {
//       setState(() {
//         isAdmin = true;
//         loadingClients = true;
//       });

//       try {
//         final response = await ApiService.get("/ads/clients");
//         final data = jsonDecode(response.body);

//         print("clients... ${data["clients"]}");
//         setState(() {
//           clients = data["clients"] ?? [];
//         });
//       } catch (e) {
//         _showError("Failed to load clients");
//       } finally {
//         setState(() {
//           loadingClients = false;
//         });
//       }
//     }
//   }

//   /* ================= HELPERS ================= */

//   void _showError(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   /* ================= FILE PICKER ================= */

//   Future<void> pickFile() async {
//     final res = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'png', 'mp4'],
//     );

//     if (res != null) {
//       final path = res.files.single.path!;
//       _file = File(path);
//       _fileType = path.endsWith("mp4") ? "video" : "image";
//       setState(() {});
//     }
//   }

//   /* ================= SUBMIT ================= */

//   Future<void> submit() async {
//     if (_file == null || _nameCtrl.text.isEmpty) return;

//     if (isAdmin && selectedClientId == null) {
//       _showError("Please select a client");
//       return;
//     }

//     try {
//       /// FILE SIZE
//       final fileSize = await _file!.length();

//       /// STORAGE CHECK
//       final allowed = await FeatureAccess.hasStorageForUpload(
//         context: context,
//         newFileSizeBytes: fileSize,
//       );

//       if (!allowed) {
//         return;
//       }
//       // 1️⃣ Upload file
//       final uploadedFileName = await AdUploadService.uploadFile(
//         file: _file!,
//         onProgress: (p, s) {
//           setState(() {
//             progress = p;
//             status = s;
//           });
//         },
//       );

//       /// INCREMENT STORAGE
//       //await StorageService.incrementStorage(fileSize);

//       // 2️⃣ Prepare request body
//       final body = {
//         "name": _nameCtrl.text,
//         "file_url": uploadedFileName,
//         "type": _fileType,
//         // "duration": isImage ? int.parse(_durationCtrl.text) : 0,
//         "duration": isImage
//             ? selectedImageDuration
//             : int.tryParse(_durationCtrl.text) ?? 0,
//         "isMultipartUpload": false,
//       };

//       if (isAdmin) {
//         body["client_id"] = selectedClientId;
//       }

//       // 3️⃣ API call
//       final response = await ApiService.post("/ads/add", body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);

//         if (data["success"] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Ad added successfully")),
//           );
//           try {
//             await StorageService.incrementStorage(fileSize);
//           } catch (e) {
//             print("Storage update failed: $e");
//           }
//           Navigator.pop(context);
//         } else {
//           _showError(data["message"] ?? "Something went wrong");
//         }
//       } else {
//         _showError("Server error (${response.statusCode})");
//       }
//     } catch (e) {
//       _showError(e.toString());
//     }
//   }

//   /* ================= UI ================= */

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Ad")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             /* ===== ADMIN CLIENT SELECT ===== */
//             if (isAdmin) ...[
//               const Text(
//                 "Select Client",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 6),

//               loadingClients
//                   ? const Center(child: CircularProgressIndicator())
//                   : DropdownButtonFormField<String>(
//                       value: selectedClientId,
//                       hint: const Text("Choose client"),
//                       items: clients.map<DropdownMenuItem<String>>((c) {
//                         return DropdownMenuItem(
//                           value: c["client_id"].toString(),
//                           child: Text(c["name"]),
//                         );
//                       }).toList(),
//                       onChanged: (val) {
//                         setState(() {
//                           selectedClientId = val;
//                         });
//                       },
//                     ),

//               const SizedBox(height: 20),
//             ],

//             /* ===== AD NAME ===== */
//             TextField(
//               controller: _nameCtrl,
//               decoration: const InputDecoration(labelText: "Ad Name"),
//             ),
//             const SizedBox(height: 12),

//             /* ===== FILE PICK ===== */
//             ElevatedButton.icon(
//               icon: const Icon(Icons.upload),
//               label: const Text("Select File"),
//               onPressed: pickFile,
//             ),

//             if (_file != null) ...[
//               const SizedBox(height: 10),
//               Text("Selected: ${_file!.path.split('/').last}"),
//             ],

//             /* ===== IMAGE DURATION ===== */
//             // if (isImage)
//             //   TextField(
//             //     controller: _durationCtrl,
//             //     keyboardType: TextInputType.number,
//             //     decoration:
//             //         const InputDecoration(labelText: "Duration (seconds)"),
//             //   ),

//             /* ===== IMAGE / VIDEO DURATION ===== */
//             if (isImage)
//               DropdownButtonFormField<int>(
//                 value: selectedImageDuration,
//                 decoration: const InputDecoration(labelText: "Image Duration"),
//                 items: const [
//                   DropdownMenuItem(value: 10, child: Text("10 seconds")),
//                   DropdownMenuItem(value: 20, child: Text("20 seconds")),
//                 ],
//                 onChanged: (val) {
//                   setState(() {
//                     selectedImageDuration = val;
//                   });
//                 },
//               )
//             else if (_file != null)
//               TextField(
//                 controller: _durationCtrl,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: "Duration (seconds)",
//                 ),
//               ),
//             const SizedBox(height: 20),

//             /* ===== UPLOAD PROGRESS ===== */
//             if (progress > 0) ...[
//               LinearProgressIndicator(value: progress / 100),
//               const SizedBox(height: 6),
//               Text("$progress% • $status"),
//             ],

//             const SizedBox(height: 30),

//             /* ===== SUBMIT ===== */
//             ElevatedButton(onPressed: submit, child: const Text("Upload Ad")),
//           ],
//         ),
//       ),
//     );
//   }
// }

// >>>>>>>>>>>>>>>>>>>>>>>>>>NEW CODE WITH UPDADTED UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

import 'dart:convert';
import 'dart:io';
import 'package:cms_app/services/storage_service.dart';
import 'package:cms_app/utils/feature_access.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/ad_upload_service.dart';
import '../../services/api_service.dart';
import '../../utils/auth_utils.dart';
import 'package:cms_app/theme/app_colors.dart';

class AddAdPage extends StatefulWidget {
  const AddAdPage({super.key});

  @override
  State<AddAdPage> createState() => _AddAdPageState();
}

class _AddAdPageState extends State<AddAdPage> {
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  File? _file;
  String? _fileType;
  int progress = 0;
  String status = "";
  int? selectedImageDuration;

  bool isAdmin = false;
  bool loadingClients = false;
  List<dynamic> clients = [];
  String? selectedClientId;

  bool get isImage => _fileType == "image";

  @override
  void initState() {
    super.initState();
    _initRoleAndClients();
  }

  /* ================= ROLE + CLIENT FETCH ================= */

  Future<void> _initRoleAndClients() async {
    final role = await AuthUtils.getRole();

    print("rolllleeee ${role}");

    if (role == "Admin") {
      setState(() {
        isAdmin = true;
        loadingClients = true;
      });

      try {
        final response = await ApiService.get("/ads/clients");
        final data = jsonDecode(response.body);

        print("clients... ${data["clients"]}");
        setState(() {
          clients = data["clients"] ?? [];
        });
      } catch (e) {
        _showError("Failed to load clients");
      } finally {
        setState(() {
          loadingClients = false;
        });
      }
    }
  }

  /* ================= HELPERS ================= */

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /* ================= FILE PICKER ================= */

  Future<void> pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );

    if (res != null) {
      final path = res.files.single.path!;
      _file = File(path);
      _fileType = path.endsWith("mp4") ? "video" : "image";
      setState(() {});
    }
  }

  /* ================= SUBMIT ================= */

  Future<void> submit() async {
    if (_file == null || _nameCtrl.text.isEmpty) return;

    if (isAdmin && selectedClientId == null) {
      _showError("Please select a client");
      return;
    }

    try {
      /// FILE SIZE
      final fileSize = await _file!.length();

      /// STORAGE CHECK
      final allowed = await FeatureAccess.hasStorageForUpload(
        context: context,
        newFileSizeBytes: fileSize,
      );

      if (!allowed) {
        return;
      }
      // 1️⃣ Upload file
      final uploadedFileName = await AdUploadService.uploadFile(
        file: _file!,
        onProgress: (p, s) {
          setState(() {
            progress = p;
            status = s;
          });
        },
      );

      /// INCREMENT STORAGE
      //await StorageService.incrementStorage(fileSize);

      // 2️⃣ Prepare request body
      final body = {
        "name": _nameCtrl.text,
        "file_url": uploadedFileName,
        "type": _fileType,
        "duration": isImage
            ? selectedImageDuration
            : int.tryParse(_durationCtrl.text) ?? 0,
        "isMultipartUpload": false,
      };

      if (isAdmin) {
        body["client_id"] = selectedClientId;
      }

      // 3️⃣ API call
      final response = await ApiService.post("/ads/add", body);

      print("response... ${response.body}");
      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   final data = jsonDecode(response.body);

      //   if (data["success"] == true) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: const Text("Ad added successfully"),
      //         backgroundColor: appColors.green,
      //         behavior: SnackBarBehavior.floating,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //       ),
      //     );

      //     print("data... ${data}");

      //     if (mounted) {
      //       Navigator.of(context).pop(true);
      //     }

      //     await StorageService.incrementStorage(fileSize);

      //     // Navigator.pop(context);
      //   } else {
      //     print("data... ${data["message"] ?? "Something went wrong"}");
      //     _showError(data["message"] ?? "Something went wrong");
      //   }
      // } else {
      //   _showError("Server error (${response.statusCode})");
      // }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data["ad"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Ad added successfully"),
              backgroundColor: appColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          await StorageService.incrementStorage(fileSize);
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        } else {
          _showError(data["message"] ?? "Something went wrong");
        }
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
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
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: appColors.textSecondary,
              size: 15,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Ad',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        children: [
          // ── Hero banner ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appColors.accent, const Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: appColors.accent.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Advertisement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Upload image or video ad content',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── ADMIN CLIENT SELECT ──────────────────────────────────────────
          if (isAdmin) ...[
            _sectionLabel(
              'Client',
              Icons.business_rounded,
              appColors.purple,
              appColors.purpleLight,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appColors.border),
                boxShadow: [
                  BoxShadow(
                    color: appColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: loadingClients
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: appColors.accent,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: selectedClientId,
                      hint: Text(
                        'Choose a client',
                        style: TextStyle(
                          color: appColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      dropdownColor: appColors.surface,
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: appColors.textMuted,
                          size: 17,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      items: clients.map<DropdownMenuItem<String>>((c) {
                        return DropdownMenuItem(
                          value: c["client_id"].toString(),
                          child: Text(c["name"]),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedClientId = val;
                        });
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],

          // ── AD NAME ─────────────────────────────────────────────────────
          _sectionLabel(
            'Ad Name',
            Icons.label_rounded,
            appColors.accent,
            appColors.accentLight,
          ),
          const SizedBox(height: 10),
          _styledTextField(
            controller: _nameCtrl,
            hint: 'Enter ad name',
            icon: Icons.edit_rounded,
          ),
          const SizedBox(height: 20),

          // ── FILE PICK ───────────────────────────────────────────────────
          _sectionLabel(
            'Media File',
            Icons.perm_media_rounded,
            appColors.teal,
            appColors.tealLight,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: pickFile,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _file != null
                      ? appColors.green.withOpacity(0.5)
                      : appColors.border,
                  width: _file != null ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: appColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _file == null
                  ? Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: appColors.tealLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.cloud_upload_rounded,
                            color: appColors.teal,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to select file',
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supports JPG, PNG, MP4',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: appColors.greenLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isImage
                                ? Icons.image_rounded
                                : Icons.videocam_rounded,
                            color: appColors.green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _file!.path.split('/').last,
                                style: TextStyle(
                                  color: appColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isImage ? 'Image file' : 'Video file',
                                style: TextStyle(
                                  color: appColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: pickFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.accentLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: appColors.accent.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'Change',
                              style: TextStyle(
                                color: appColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // ── DURATION ────────────────────────────────────────────────────
          if (isImage || (_file != null && !isImage)) ...[
            _sectionLabel(
              'Duration',
              Icons.timer_rounded,
              appColors.orange,
              appColors.orangeLight,
            ),
            const SizedBox(height: 10),
            if (isImage)
              Container(
                decoration: BoxDecoration(
                  color: appColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: appColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedImageDuration,
                  dropdownColor: appColors.surface,
                  style: TextStyle(color: appColors.textPrimary, fontSize: 13),
                  hint: Text(
                    'Select image duration',
                    style: TextStyle(color: appColors.textMuted, fontSize: 13),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.timer_rounded,
                      color: appColors.textMuted,
                      size: 17,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text("10 seconds")),
                    DropdownMenuItem(value: 20, child: Text("20 seconds")),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedImageDuration = val;
                    });
                  },
                ),
              )
            else
              _styledTextField(
                controller: _durationCtrl,
                hint: 'Enter duration in seconds',
                icon: Icons.timer_rounded,
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 20),
          ],

          // ── UPLOAD PROGRESS ─────────────────────────────────────────────
          if (progress > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appColors.border),
                boxShadow: [
                  BoxShadow(
                    color: appColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uploading…',
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          color: appColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 7,
                      backgroundColor: appColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        appColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status,
                    style: TextStyle(color: appColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── SUBMIT ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: submit,
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('Upload Ad'),
              style: FilledButton.styleFrom(
                backgroundColor: appColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared UI helpers ────────────────────────────────────────────────────

  Widget _sectionLabel(String text, IconData icon, Color color, Color bg) =>
      Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      );

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) => Container(
    decoration: BoxDecoration(
      color: appColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: appColors.border),
      boxShadow: [
        BoxShadow(
          color: appColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: appColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: appColors.textMuted, size: 17),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    ),
  );
}
