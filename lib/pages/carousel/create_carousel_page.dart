// import 'dart:io';
// import 'package:cms_app/models/carousel.dart';
// import 'package:cms_app/providers/carousel_provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CreateCarouselPage extends StatefulWidget {
//   const CreateCarouselPage({super.key});

//   @override
//   State<CreateCarouselPage> createState() => _CreateCarouselPageState();
// }

// class _CreateCarouselPageState extends State<CreateCarouselPage> {
//   final nameController = TextEditingController();

//   List<CarouselItem> items = [];
//   List<dynamic> availableAds = [];

//   bool loading = false;
//   bool loadingAds = true;

//   @override
//   void initState() {
//     super.initState();
//     loadAds();
//   }

//   /// LOAD ADS
//   Future<void> loadAds() async {
//     try {
//       final provider = context.read<CarouselProvider>();
//       final ads = await provider.fetchAds();

//       setState(() {
//         availableAds = ads;
//         loadingAds = false;
//       });
//     } catch (e) {
//       setState(() {
//         loadingAds = false;
//       });
//     }
//   }

//   /// ADD EXISTING AD
//   void addExistingAd(String adId) {
//     final ad = availableAds.firstWhere((a) => a["ad_id"] == adId);

//     setState(() {
//       items.add(
//         CarouselItem(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           adId: ad["ad_id"],
//           name: ad["name"],
//           duration: ad["duration"],
//           displayOrder: items.length + 1,
//           isNew: false,
//         ),
//       );
//     });
//   }

//   /// ADD NEW AD
//   void addNewAd() {
//     setState(() {
//       items.add(
//         CarouselItem(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           name: "",
//           duration: 0,
//           fileUrl: "",
//           displayOrder: items.length + 1,
//           isNew: true,
//         ),
//       );
//     });
//   }

//   void removeItem(String id) {
//     setState(() {
//       items.removeWhere((e) => e.id == id);
//     });
//   }

//   void updateItem(String id, {String? name, int? duration, String? fileUrl}) {
//     final index = items.indexWhere((e) => e.id == id);

//     setState(() {
//       items[index] = items[index].copyWith(
//         name: name ?? items[index].name,
//         duration: duration ?? items[index].duration,
//         fileUrl: fileUrl ?? items[index].fileUrl,
//       );
//     });
//   }

//   /// FILE PICKER
//   Future<void> uploadFile(String itemId) async {
//     final result = await FilePicker.platform.pickFiles();

//     if (result == null) return;

//     final file = File(result.files.single.path!);

//     final provider = context.read<CarouselProvider>();
//     final fileUrl = await provider.uploadAdFile(file);

//     updateItem(itemId, fileUrl: fileUrl);
//   }

//   int get totalDuration {
//     return items.fold(0, (sum, e) => sum + (e.duration ?? 0));
//   }

//   /// CREATE CAROUSEL
//   Future<void> create() async {
//     if (nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Carousel name required")),
//       );
//       return;
//     }

//     if (items.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Add at least one ad")),
//       );
//       return;
//     }

//     setState(() => loading = true);

//     final provider = context.read<CarouselProvider>();

//     final success = await provider.createCarousel(
//       name: nameController.text,
//       items: items,
//     );

//     setState(() => loading = false);

//     if (!mounted) return;

//     if (success) Navigator.pop(context);
//   }

//   /// 🔥 BOTTOM SHEET FOR EXISTING ADS
//   void showExistingAdsBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const Text(
//                 "Select Ad",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),

//               Expanded(
//                 child: ListView.builder(
//                   itemCount: availableAds.length,
//                   itemBuilder: (context, index) {
//                     final ad = availableAds[index];

//                     return ListTile(
//                       leading: const Icon(Icons.campaign),
//                       title: Text(ad["name"]),
//                       subtitle: Text("Duration: ${ad["duration"]}s"),
//                       onTap: () {
//                         addExistingAd(ad["ad_id"]);
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loadingAds) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create Carousel"),
//         actions: [
//           IconButton(
//             onPressed: loading ? null : create,
//             icon: loading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Icons.save),
//           ),
//         ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// NAME
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "Carousel Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// ✅ ADD ITEM BUTTON WITH DROPDOWN
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == "upload") {
//                   addNewAd();
//                 } else if (value == "existing") {
//                   showExistingAdsBottomSheet();
//                 }
//               },
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.add),
//                     SizedBox(width: 8),
//                     Text("Add Item"),
//                   ],
//                 ),
//               ),

//               /// 🔥 UPLOAD FIRST
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: "upload",
//                   child: Row(
//                     children: [
//                       Icon(Icons.upload),
//                       SizedBox(width: 10),
//                       Text("Upload New Ad"),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: "existing",
//                   child: Row(
//                     children: [
//                       Icon(Icons.list),
//                       SizedBox(width: 10),
//                       Text("Select Existing Ad"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             /// ITEMS
//             Expanded(
//               child: ReorderableListView.builder(
//                 itemCount: items.length,
//                 onReorder: (oldIndex, newIndex) {
//                   if (newIndex > oldIndex) newIndex--;

//                   final item = items.removeAt(oldIndex);
//                   items.insert(newIndex, item);

//                   setState(() {});
//                 },
//                 itemBuilder: (context, index) {
//                   final item = items[index];

//                   return Card(
//                     key: ValueKey(item.id),
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: item.isNew
//                           ? buildNewAdItem(item)
//                           : buildExistingAdItem(item),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildExistingAdItem(CarouselItem item) {
//     return Row(
//       children: [
//         const Icon(Icons.drag_handle),
//         const SizedBox(width: 10),
//         Expanded(child: Text(item.name ?? "")),
//         IconButton(
//           icon: const Icon(Icons.delete),
//           onPressed: () => removeItem(item.id),
//         ),
//       ],
//     );
//   }

//   Widget buildNewAdItem(CarouselItem item) {
//     return Column(
//       children: [
//         TextField(
//           decoration: const InputDecoration(labelText: "Ad Name"),
//           onChanged: (v) => updateItem(item.id, name: v),
//         ),
//         const SizedBox(height: 10),
//         ElevatedButton(
//           onPressed: () => uploadFile(item.id),
//           child: const Text("Upload File"),
//         ),
//       ],
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< OLD CODE WORKING FUNCTIONALITY>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// import 'dart:io';
// import 'package:cms_app/models/carousel.dart';
// import 'package:cms_app/providers/carousel_provider.dart';
// import 'package:cms_app/utils/feature_access.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/storage_service.dart';

// class CreateCarouselPage extends StatefulWidget {
//   const CreateCarouselPage({super.key});

//   @override
//   State<CreateCarouselPage> createState() => _CreateCarouselPageState();
// }

// class _CreateCarouselPageState extends State<CreateCarouselPage> {
//   final nameController = TextEditingController();

//   List<CarouselItem> items = [];
//   List<dynamic> availableAds = [];

//   bool loading = false;
//   bool loadingAds = true;

//   @override
//   void initState() {
//     super.initState();
//     loadAds();
//   }

//   /// LOAD ADS
//   Future<void> loadAds() async {
//     try {
//       final provider = context.read<CarouselProvider>();
//       final ads = await provider.fetchAds();

//       setState(() {
//         availableAds = ads;
//         loadingAds = false;
//       });
//     } catch (e) {
//       setState(() {
//         loadingAds = false;
//       });
//     }
//   }

//   /// ADD EXISTING AD
//   void addExistingAd(String adId) {
//     final ad = availableAds.firstWhere((a) => a["ad_id"] == adId);

//     setState(() {
//       items.add(
//         CarouselItem(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           adId: ad["ad_id"],
//           name: ad["name"],
//           duration: ad["duration"],
//           displayOrder: items.length + 1,
//           isNew: false,
//         ),
//       );
//     });
//   }

//   /// ADD NEW AD
//   void addNewAd() {
//     setState(() {
//       items.add(
//         CarouselItem(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           name: "",
//           duration: 10,
//           fileUrl: "",
//           displayOrder: items.length + 1,
//           isNew: true,
//         ),
//       );
//     });
//   }

//   void removeItem(String id) {
//     setState(() {
//       items.removeWhere((e) => e.id == id);
//     });
//   }

//   void updateItem(String id, {String? name, int? duration, String? fileUrl}) {
//     final index = items.indexWhere((e) => e.id == id);

//     setState(() {
//       items[index] = items[index].copyWith(
//         name: name ?? items[index].name,
//         duration: duration ?? items[index].duration,
//         fileUrl: fileUrl ?? items[index].fileUrl,
//       );
//     });
//   }

//   /// FILE PICKER
//   //  Future<void> uploadFile(String itemId) async {
//   //   try {
//   //     final result = await FilePicker.platform.pickFiles(
//   //       type: FileType.any,
//   //       withData: true, // ✅ important for Android
//   //     );

//   //     if (result == null || result.files.isEmpty) {
//   //       print("❌ No file selected");
//   //       return;
//   //     }

//   //     final pickedFile = result.files.single;

//   //     File file;

//   //     if (pickedFile.path != null) {
//   //       /// ✅ Normal case (path available)
//   //       file = File(pickedFile.path!);
//   //     } else {
//   //       /// ✅ Android fix (no path → use bytes)
//   //       final bytes = pickedFile.bytes;

//   //       if (bytes == null) {
//   //         print("❌ No bytes available");
//   //         return;
//   //       }

//   //       final tempDir = Directory.systemTemp;
//   //       final tempFile = File("${tempDir.path}/${pickedFile.name}");

//   //       await tempFile.writeAsBytes(bytes);
//   //       file = tempFile;
//   //     }

//   //     print("✅ File ready: ${file.path}");

//   //     /// UPLOAD
//   //     final provider = context.read<CarouselProvider>();
//   //     final fileUrl = await provider.uploadAdFile(file);

//   //     if (fileUrl == null || fileUrl.isEmpty) {
//   //       print("❌ Upload failed");
//   //       return;
//   //     }

//   //     print("✅ Uploaded: $fileUrl");

//   //     updateItem(itemId, fileUrl: fileUrl);

//   //   } catch (e) {
//   //     print("❌ Upload error: $e");
//   //   }
//   // }

//   Future<void> uploadFile(String itemId) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.any,
//         withData: true,
//       );

//       if (result == null || result.files.isEmpty) {
//         return;
//       }

//       final pickedFile = result.files.single;

//       File file;

//       if (pickedFile.path != null) {
//         file = File(pickedFile.path!);
//       } else {
//         final bytes = pickedFile.bytes;

//         if (bytes == null) {
//           return;
//         }

//         final tempDir = Directory.systemTemp;

//         final tempFile = File("${tempDir.path}/${pickedFile.name}");

//         await tempFile.writeAsBytes(bytes);

//         file = tempFile;
//       }

//       /// FILE SIZE
//       final fileSize = await file.length();

//       /// STORAGE CHECK
//       final allowed = await FeatureAccess.hasStorageForUpload(
//         context: context,
//         newFileSizeBytes: fileSize,
//       );

//       if (!allowed) {
//         return;
//       }

//       final provider = context.read<CarouselProvider>();

//       final fileUrl = await provider.uploadAdFile(
//         file,

//         onProgress: (progress, status, speed, timeLeft) {
//           print(progress);
//           print(status);
//           print(speed);
//           print(timeLeft);

//           /// OPTIONAL UI UPDATE
//           setState(() {});
//         },
//       );

//       try {
//         await StorageService.incrementStorage(fileSize);
//       } catch (e) {
//         print("Storage update failed: $e");
//       }

//       /// ✅ UPDATE ITEM HERE
//       updateItem(itemId, fileUrl: fileUrl);

//       print("Uploaded URL: $fileUrl");
//     } catch (e) {
//       print("Upload error: $e");
//     }
//   }

//   int get totalDuration {
//     return items.fold(0, (sum, e) => sum + (e.duration ?? 0));
//   }

//   /// CREATE CAROUSEL
//   Future<void> create() async {
//     if (nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Carousel name required")));
//       return;
//     }

//     if (items.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Add at least one ad")));
//       return;
//     }

//     /// ✅ VALIDATION FOR NEW ADS
//     if (items.any(
//       (e) => e.isNew && (e.fileUrl == null || e.fileUrl!.isEmpty),
//     )) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please upload all new ads")),
//       );
//       return;
//     }

//     setState(() => loading = true);

//     final provider = context.read<CarouselProvider>();

//     final success = await provider.createCarousel(
//       name: nameController.text,
//       items: items,
//     );

//     setState(() => loading = false);

//     if (!mounted) return;

//     if (success) Navigator.pop(context);
//   }

//   /// BOTTOM SHEET FOR EXISTING ADS
//   void showExistingAdsBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const Text(
//                 "Select Ad",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: availableAds.length,
//                   itemBuilder: (context, index) {
//                     final ad = availableAds[index];

//                     return ListTile(
//                       leading: const Icon(Icons.campaign),
//                       title: Text(ad["name"]),
//                       subtitle: Text("Duration: ${ad["duration"]}s"),
//                       onTap: () {
//                         addExistingAd(ad["ad_id"]);
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loadingAds) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create Carousel"),
//         actions: [
//           IconButton(
//             onPressed: loading ? null : create,
//             icon: loading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Icons.save),
//           ),
//         ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// NAME
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "Carousel Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// ADD ITEM DROPDOWN
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == "upload") {
//                   addNewAd();
//                 } else if (value == "existing") {
//                   showExistingAdsBottomSheet();
//                 }
//               },
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.add),
//                     SizedBox(width: 8),
//                     Text("Add Item"),
//                   ],
//                 ),
//               ),
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: "upload",
//                   child: Row(
//                     children: [
//                       Icon(Icons.upload),
//                       SizedBox(width: 10),
//                       Text("Upload New Ad"),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: "existing",
//                   child: Row(
//                     children: [
//                       Icon(Icons.list),
//                       SizedBox(width: 10),
//                       Text("Select Existing Ad"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             /// ITEMS LIST
//             Expanded(
//               child: ReorderableListView.builder(
//                 itemCount: items.length,
//                 onReorder: (oldIndex, newIndex) {
//                   if (newIndex > oldIndex) newIndex--;

//                   final item = items.removeAt(oldIndex);
//                   items.insert(newIndex, item);

//                   setState(() {});
//                 },
//                 itemBuilder: (context, index) {
//                   final item = items[index];

//                   return Card(
//                     key: ValueKey(item.id),
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: item.isNew
//                           ? buildNewAdItem(item)
//                           : buildExistingAdItem(item),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// EXISTING AD
//   Widget buildExistingAdItem(CarouselItem item) {
//     return Row(
//       children: [
//         const Icon(Icons.drag_handle),
//         const SizedBox(width: 10),
//         Expanded(child: Text(item.name ?? "")),
//         IconButton(
//           icon: const Icon(Icons.delete),
//           onPressed: () => removeItem(item.id),
//         ),
//       ],
//     );
//   }

//   /// NEW AD
//   // Widget buildNewAdItem(CarouselItem item) {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Row(
//   //         children: [
//   //           const Icon(Icons.drag_handle),
//   //           const SizedBox(width: 10),

//   //           /// NAME INPUT
//   //           Expanded(
//   //             child: TextField(
//   //               decoration: const InputDecoration(
//   //                 labelText: "Ad Name",
//   //                 border: OutlineInputBorder(),
//   //               ),
//   //               onChanged: (v) => updateItem(item.id, name: v),
//   //             ),
//   //           ),

//   //           const SizedBox(width: 10),

//   //           /// ✅ ONLY DELETE ICON
//   //           IconButton(
//   //             icon: const Icon(Icons.delete, color: Colors.red),
//   //             onPressed: () => removeItem(item.id),
//   //           ),
//   //         ],
//   //       ),

//   //       const SizedBox(height: 12),

//   //       Row(
//   //         children: [
//   //           /// UPLOAD BUTTON
//   //           ElevatedButton.icon(
//   //             onPressed: () => uploadFile(item.id),
//   //             icon: const Icon(Icons.upload),
//   //             label: const Text("Upload File"),
//   //           ),

//   //           const SizedBox(width: 10),

//   //           /// STATUS
//   //           if (item.fileUrl != null && item.fileUrl!.isNotEmpty)
//   //             const Text("Uploaded", style: TextStyle(color: Colors.green))
//   //           else
//   //             const Text("Not uploaded", style: TextStyle(color: Colors.red)),
//   //         ],
//   //       ),
//   //     ],
//   //   );
//   // }
//   Widget buildNewAdItem(CarouselItem item) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,

//       children: [
//         /// NAME
//         TextField(
//           decoration: const InputDecoration(
//             labelText: "Ad Name",
//             border: OutlineInputBorder(),
//           ),

//           onChanged: (v) {
//             updateItem(item.id, name: v);
//           },
//         ),

//         const SizedBox(height: 12),

//         /// DURATION DROPDOWN
//         DropdownButtonFormField<int>(
//           value: item.duration == 0 ? null : item.duration,

//           decoration: const InputDecoration(
//             labelText: "Duration",
//             border: OutlineInputBorder(),
//           ),

//           items: const [
//             DropdownMenuItem(value: 10, child: Text("10 Seconds")),

//             DropdownMenuItem(value: 15, child: Text("15 Seconds")),

//             DropdownMenuItem(value: 20, child: Text("20 Seconds")),

//             DropdownMenuItem(value: 25, child: Text("25 Seconds")),

//             DropdownMenuItem(value: 30, child: Text("30 Seconds")),
//           ],

//           onChanged: (value) {
//             updateItem(item.id, duration: value ?? 0);
//           },
//         ),

//         const SizedBox(height: 12),

//         /// UPLOAD BUTTON
//         ElevatedButton.icon(
//           onPressed: () {
//             uploadFile(item.id);
//           },

//           icon: const Icon(Icons.upload),

//           label: const Text("Upload File"),
//         ),

//         const SizedBox(height: 10),

//         /// STATUS
//         if (item.fileUrl != null && item.fileUrl!.isNotEmpty)
//           const Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.green, size: 18),

//               SizedBox(width: 6),

//               Text(
//                 "Uploaded",
//                 style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           )
//         else
//           const Row(
//             children: [
//               Icon(Icons.error, color: Colors.red, size: 18),

//               SizedBox(width: 6),

//               Text(
//                 "Not uploaded",
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'dart:io';
import 'package:cms_app/models/carousel.dart';
import 'package:cms_app/providers/carousel_provider.dart';
import 'package:cms_app/utils/feature_access.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart'; // adjust import path as needed

class CreateCarouselPage extends StatefulWidget {
  const CreateCarouselPage({super.key});

  @override
  State<CreateCarouselPage> createState() => _CreateCarouselPageState();
}

class _CreateCarouselPageState extends State<CreateCarouselPage> {
  final nameController = TextEditingController();

  List<CarouselItem> items = [];
  List<dynamic> availableAds = [];

  bool loading = false;
  bool loadingAds = true;

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  /// LOAD ADS
  Future<void> loadAds() async {
    try {
      final provider = context.read<CarouselProvider>();
      final ads = await provider.fetchAds();

      setState(() {
        availableAds = ads;
        loadingAds = false;
      });
    } catch (e) {
      setState(() {
        loadingAds = false;
      });
    }
  }

  /// ADD EXISTING AD
  void addExistingAd(String adId) {
    final ad = availableAds.firstWhere((a) => a["ad_id"] == adId);

    setState(() {
      items.add(
        CarouselItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          adId: ad["ad_id"],
          name: ad["name"],
          duration: ad["duration"],
          displayOrder: items.length + 1,
          isNew: false,
        ),
      );
    });
  }

  /// ADD NEW AD
  void addNewAd() {
    setState(() {
      items.add(
        CarouselItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "",
          duration: 10,
          fileUrl: "",
          displayOrder: items.length + 1,
          isNew: true,
        ),
      );
    });
  }

  void removeItem(String id) {
    setState(() {
      items.removeWhere((e) => e.id == id);
    });
  }

  void updateItem(String id, {String? name, int? duration, String? fileUrl}) {
    final index = items.indexWhere((e) => e.id == id);

    setState(() {
      items[index] = items[index].copyWith(
        name: name ?? items[index].name,
        duration: duration ?? items[index].duration,
        fileUrl: fileUrl ?? items[index].fileUrl,
      );
    });
  }

  Future<void> uploadFile(String itemId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.single;

      File file;

      if (pickedFile.path != null) {
        file = File(pickedFile.path!);
      } else {
        final bytes = pickedFile.bytes;

        if (bytes == null) {
          return;
        }

        final tempDir = Directory.systemTemp;

        final tempFile = File("${tempDir.path}/${pickedFile.name}");

        await tempFile.writeAsBytes(bytes);

        file = tempFile;
      }

      /// FILE SIZE
      final fileSize = await file.length();

      /// STORAGE CHECK
      final allowed = await FeatureAccess.hasStorageForUpload(
        context: context,
        newFileSizeBytes: fileSize,
      );

      if (!allowed) {
        return;
      }

      final provider = context.read<CarouselProvider>();

      final fileUrl = await provider.uploadAdFile(
        file,

        onProgress: (progress, status, speed, timeLeft) {
          print(progress);
          print(status);
          print(speed);
          print(timeLeft);

          /// OPTIONAL UI UPDATE
          setState(() {});
        },
      );

      try {
        await StorageService.incrementStorage(fileSize);
      } catch (e) {
        print("Storage update failed: $e");
      }

      /// UPDATE ITEM HERE
      updateItem(itemId, fileUrl: fileUrl);

      print("Uploaded URL: $fileUrl");
    } catch (e) {
      print("Upload error: $e");
    }
  }

  int get totalDuration {
    return items.fold(0, (sum, e) => sum + (e.duration ?? 0));
  }

  /// CREATE CAROUSEL
  Future<void> create() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Carousel name required"),
          backgroundColor: appColors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Add at least one ad"),
          backgroundColor: appColors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    /// VALIDATION FOR NEW ADS
    if (items.any(
      (e) => e.isNew && (e.fileUrl == null || e.fileUrl!.isEmpty),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please upload all new ads"),
          backgroundColor: appColors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => loading = true);

    final provider = context.read<CarouselProvider>();

    final success = await provider.createCarousel(
      name: nameController.text,
      items: items,
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (success) Navigator.pop(context);
  }

  /// BOTTOM SHEET FOR EXISTING ADS
  void showExistingAdsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: appColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: appColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.campaign_rounded,
                      color: appColors.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Select Ad",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: appColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Divider(height: 1, color: appColors.border),

              const SizedBox(height: 8),

              Expanded(
                child: ListView.separated(
                  itemCount: availableAds.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: appColors.borderLight),
                  itemBuilder: (context, index) {
                    final ad = availableAds[index];

                    return InkWell(
                      onTap: () {
                        addExistingAd(ad["ad_id"]);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: appColors.accentLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.campaign_rounded,
                                color: appColors.accent,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ad["name"],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: appColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Duration: ${ad["duration"]}s",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: appColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: appColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingAds) {
      return Scaffold(
        backgroundColor: appColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: appColors.accent,
                  strokeWidth: 2.5,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading ads…',
                style: TextStyle(color: appColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

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

        titleSpacing: 16,

        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appColors.accent, const Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.view_carousel_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Create Carousel',
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: loading
                ? SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      color: appColors.accent,
                      strokeWidth: 2.5,
                      strokeCap: StrokeCap.round,
                    ),
                  )
                : GestureDetector(
                    onTap: create,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: appColors.accentLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.accent.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.save_rounded,
                        color: appColors.accent,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// NAME
            Container(
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appColors.border),
                boxShadow: [
                  BoxShadow(
                    color: appColors.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: nameController,
                style: TextStyle(color: appColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  labelText: "Carousel Name",
                  labelStyle: TextStyle(
                    color: appColors.textMuted,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.drive_file_rename_outline_rounded,
                    color: appColors.textMuted,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ADD ITEM BUTTON
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "upload") {
                  addNewAd();
                } else if (value == "existing") {
                  showExistingAdsBottomSheet();
                }
              },
              color: appColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: appColors.border),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "upload",
                  height: 44,
                  child: Row(
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        size: 16,
                        color: appColors.accent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Upload New Ad",
                        style: TextStyle(
                          fontSize: 13,
                          color: appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "existing",
                  height: 44,
                  child: Row(
                    children: [
                      Icon(Icons.list_rounded, size: 16, color: appColors.teal),
                      const SizedBox(width: 10),
                      Text(
                        "Select Existing Ad",
                        style: TextStyle(
                          fontSize: 13,
                          color: appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: appColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: appColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Add Item",
                      style: TextStyle(
                        color: appColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ITEMS LIST
            Expanded(
              child: ReorderableListView.builder(
                itemCount: items.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;

                  final item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);

                  setState(() {});
                },
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Container(
                    key: ValueKey(item.id),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: appColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: appColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: item.isNew
                        ? buildNewAdItem(item)
                        : buildExistingAdItem(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EXISTING AD
  Widget buildExistingAdItem(CarouselItem item) {
    return Row(
      children: [
        Icon(Icons.drag_handle_rounded, color: appColors.textMuted, size: 20),
        const SizedBox(width: 10),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: appColors.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.campaign_rounded,
            color: appColors.accent,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name ?? "",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: appColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => removeItem(item.id),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: appColors.redLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: appColors.red.withOpacity(0.2)),
            ),
            child: Icon(Icons.delete_rounded, color: appColors.red, size: 15),
          ),
        ),
      ],
    );
  }

  /// NEW AD
  Widget buildNewAdItem(CarouselItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// DRAG + DELETE ROW
        Row(
          children: [
            Icon(
              Icons.drag_handle_rounded,
              color: appColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: appColors.accentLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'NEW',
                style: TextStyle(
                  color: appColors.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => removeItem(item.id),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: appColors.redLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: appColors.red.withOpacity(0.2)),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: appColors.red,
                  size: 15,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// NAME
        Container(
          decoration: BoxDecoration(
            color: appColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: appColors.border),
          ),
          child: TextField(
            style: TextStyle(color: appColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: "Ad Name",
              labelStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
              prefixIcon: Icon(
                Icons.drive_file_rename_outline_rounded,
                color: appColors.textMuted,
                size: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            onChanged: (v) {
              updateItem(item.id, name: v);
            },
          ),
        ),

        const SizedBox(height: 10),

        /// DURATION DROPDOWN
        Container(
          decoration: BoxDecoration(
            color: appColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: appColors.border),
          ),
          child: DropdownButtonFormField<int>(
            value: item.duration == 0 ? null : item.duration,
            dropdownColor: appColors.surface,
            style: TextStyle(color: appColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: "Duration",
              labelStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
              prefixIcon: Icon(
                Icons.timer_rounded,
                color: appColors.textMuted,
                size: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            items: const [
              DropdownMenuItem(value: 10, child: Text("10 Seconds")),
              DropdownMenuItem(value: 15, child: Text("15 Seconds")),
              DropdownMenuItem(value: 20, child: Text("20 Seconds")),
              DropdownMenuItem(value: 25, child: Text("25 Seconds")),
              DropdownMenuItem(value: 30, child: Text("30 Seconds")),
            ],
            onChanged: (value) {
              updateItem(item.id, duration: value ?? 0);
            },
          ),
        ),

        const SizedBox(height: 12),

        /// UPLOAD BUTTON
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              uploadFile(item.id);
            },
            icon: const Icon(Icons.upload_rounded, size: 16),
            label: const Text("Upload File"),
            style: FilledButton.styleFrom(
              backgroundColor: appColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// UPLOAD STATUS
        if (item.fileUrl != null && item.fileUrl!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: appColors.greenLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: appColors.green.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: appColors.green,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  "Uploaded",
                  style: TextStyle(
                    color: appColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: appColors.redLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: appColors.red.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_rounded, color: appColors.red, size: 14),
                const SizedBox(width: 6),
                Text(
                  "Not uploaded",
                  style: TextStyle(
                    color: appColors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
