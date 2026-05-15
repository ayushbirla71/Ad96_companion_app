// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import '../../services/ad_upload_service.dart';
// import '../../services/api_service.dart';

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

//   bool get isImage => _fileType == "image";

//   void _showError(String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(message)),
//   );
// }

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

// Future<void> submit() async {
//   if (_file == null || _nameCtrl.text.isEmpty) return;

//   try {
//     // 1️⃣ Upload file
//     final uploadedFileName = await AdUploadService.uploadFile(
//       file: _file!,
//       onProgress: (p, s) {
//         setState(() {
//           progress = p;
//           status = s;
//         });
//       },
//     );

//     print("uploaded flle ... ${uploadedFileName}");

//     // 2️⃣ Call API
//     final response = await ApiService.post("/ads/add", {
//       "name": _nameCtrl.text,
//       "file_url": uploadedFileName,
//       "type": _fileType,
//       "duration": isImage ? int.parse(_durationCtrl.text) : 0,
//       "isMultipartUpload" : false
//     });

//     // 3️⃣ Handle response
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = jsonDecode(response.body);

//       print("response form api ..... ${data}");

//       if (data["success"] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Ad added successfully")),
//         );
//         // Navigator.pop(context, true); // return success
//       } else {
//         _showError(data["message"] ?? "Something went wrong");
//       }
//     } else {
//       print("error... ${response.body}");
//       _showError("Server error (${response.statusCode})");
//     }
//   } catch (e) {
//     _showError(e.toString());
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Ad")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             TextField(
//               controller: _nameCtrl,
//               decoration: const InputDecoration(labelText: "Ad Name"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton.icon(
//               icon: const Icon(Icons.upload),
//               label: const Text("Select File"),
//               onPressed: pickFile,
//             ),

//             if (_file != null) ...[
//               const SizedBox(height: 10),
//               Text("Selected: ${_file!.path.split('/').last}"),
//             ],

//             if (isImage)
//               TextField(
//                 controller: _durationCtrl,
//                 keyboardType: TextInputType.number,
//                 decoration:
//                     const InputDecoration(labelText: "Duration (seconds)"),
//               ),

//             const SizedBox(height: 20),

//             if (progress > 0) ...[
//               LinearProgressIndicator(value: progress / 100),
//               const SizedBox(height: 6),
//               Text("$progress% • $status"),
//             ],

//             const SizedBox(height: 30),

//             ElevatedButton(
//               onPressed: submit,
//               child: const Text("Upload Ad"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:cms_app/services/storage_service.dart';
import 'package:cms_app/utils/feature_access.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/ad_upload_service.dart';
import '../../services/api_service.dart';
import '../../utils/auth_utils.dart'; // 👈 JWT role decoder

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      await StorageService.incrementStorage(fileSize);

      // 2️⃣ Prepare request body
      final body = {
        "name": _nameCtrl.text,
        "file_url": uploadedFileName,
        "type": _fileType,
        // "duration": isImage ? int.parse(_durationCtrl.text) : 0,
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ad added successfully")),
          );
          try {
            await StorageService.incrementStorage(fileSize);
          } catch (e) {
            print("Storage update failed: $e");
          }
          Navigator.pop(context);
        } else {
          _showError(data["message"] ?? "Something went wrong");
        }
      } else {
        _showError("Server error (${response.statusCode})");
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Ad")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /* ===== ADMIN CLIENT SELECT ===== */
            if (isAdmin) ...[
              const Text(
                "Select Client",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              loadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedClientId,
                      hint: const Text("Choose client"),
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

              const SizedBox(height: 20),
            ],

            /* ===== AD NAME ===== */
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Ad Name"),
            ),
            const SizedBox(height: 12),

            /* ===== FILE PICK ===== */
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text("Select File"),
              onPressed: pickFile,
            ),

            if (_file != null) ...[
              const SizedBox(height: 10),
              Text("Selected: ${_file!.path.split('/').last}"),
            ],

            /* ===== IMAGE DURATION ===== */
            // if (isImage)
            //   TextField(
            //     controller: _durationCtrl,
            //     keyboardType: TextInputType.number,
            //     decoration:
            //         const InputDecoration(labelText: "Duration (seconds)"),
            //   ),

            /* ===== IMAGE / VIDEO DURATION ===== */
            if (isImage)
              DropdownButtonFormField<int>(
                value: selectedImageDuration,
                decoration: const InputDecoration(labelText: "Image Duration"),
                items: const [
                  DropdownMenuItem(value: 10, child: Text("10 seconds")),
                  DropdownMenuItem(value: 20, child: Text("20 seconds")),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedImageDuration = val;
                  });
                },
              )
            else if (_file != null)
              TextField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Duration (seconds)",
                ),
              ),
            const SizedBox(height: 20),

            /* ===== UPLOAD PROGRESS ===== */
            if (progress > 0) ...[
              LinearProgressIndicator(value: progress / 100),
              const SizedBox(height: 6),
              Text("$progress% • $status"),
            ],

            const SizedBox(height: 30),

            /* ===== SUBMIT ===== */
            ElevatedButton(onPressed: submit, child: const Text("Upload Ad")),
          ],
        ),
      ),
    );
  }
}
