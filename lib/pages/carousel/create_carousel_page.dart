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












import 'dart:io';
import 'package:cms_app/models/carousel.dart';
import 'package:cms_app/providers/carousel_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          duration: 0,
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

  /// FILE PICKER
 Future<void> uploadFile(String itemId) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true, // ✅ important for Android
    );

    if (result == null || result.files.isEmpty) {
      print("❌ No file selected");
      return;
    }

    final pickedFile = result.files.single;

    File file;

    if (pickedFile.path != null) {
      /// ✅ Normal case (path available)
      file = File(pickedFile.path!);
    } else {
      /// ✅ Android fix (no path → use bytes)
      final bytes = pickedFile.bytes;

      if (bytes == null) {
        print("❌ No bytes available");
        return;
      }

      final tempDir = Directory.systemTemp;
      final tempFile = File("${tempDir.path}/${pickedFile.name}");

      await tempFile.writeAsBytes(bytes);
      file = tempFile;
    }

    print("✅ File ready: ${file.path}");

    /// UPLOAD
    final provider = context.read<CarouselProvider>();
    final fileUrl = await provider.uploadAdFile(file);

    if (fileUrl == null || fileUrl.isEmpty) {
      print("❌ Upload failed");
      return;
    }

    print("✅ Uploaded: $fileUrl");

    updateItem(itemId, fileUrl: fileUrl);

  } catch (e) {
    print("❌ Upload error: $e");
  }
}

  int get totalDuration {
    return items.fold(0, (sum, e) => sum + (e.duration ?? 0));
  }

  /// CREATE CAROUSEL
  Future<void> create() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carousel name required")),
      );
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one ad")),
      );
      return;
    }

    /// ✅ VALIDATION FOR NEW ADS
    if (items.any((e) => e.isNew && (e.fileUrl == null || e.fileUrl!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload all new ads")),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Select Ad",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: availableAds.length,
                  itemBuilder: (context, index) {
                    final ad = availableAds[index];

                    return ListTile(
                      leading: const Icon(Icons.campaign),
                      title: Text(ad["name"]),
                      subtitle: Text("Duration: ${ad["duration"]}s"),
                      onTap: () {
                        addExistingAd(ad["ad_id"]);
                        Navigator.pop(context);
                      },
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Carousel"),
        actions: [
          IconButton(
            onPressed: loading ? null : create,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Carousel Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// ADD ITEM DROPDOWN
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "upload") {
                  addNewAd();
                } else if (value == "existing") {
                  showExistingAdsBottomSheet();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text("Add Item"),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "upload",
                  child: Row(
                    children: [
                      Icon(Icons.upload),
                      SizedBox(width: 10),
                      Text("Upload New Ad"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "existing",
                  child: Row(
                    children: [
                      Icon(Icons.list),
                      SizedBox(width: 10),
                      Text("Select Existing Ad"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

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

                  return Card(
                    key: ValueKey(item.id),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: item.isNew
                          ? buildNewAdItem(item)
                          : buildExistingAdItem(item),
                    ),
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
        const Icon(Icons.drag_handle),
        const SizedBox(width: 10),
        Expanded(child: Text(item.name ?? "")),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => removeItem(item.id),
        ),
      ],
    );
  }

  /// NEW AD
 Widget buildNewAdItem(CarouselItem item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.drag_handle),
          const SizedBox(width: 10),

          /// NAME INPUT
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Ad Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => updateItem(item.id, name: v),
            ),
          ),

          const SizedBox(width: 10),

          /// ✅ ONLY DELETE ICON
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => removeItem(item.id),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          /// UPLOAD BUTTON
          ElevatedButton.icon(
            onPressed: () => uploadFile(item.id),
            icon: const Icon(Icons.upload),
            label: const Text("Upload File"),
          ),

          const SizedBox(width: 10),

          /// STATUS
          if (item.fileUrl != null && item.fileUrl!.isNotEmpty)
            const Text(
              "Uploaded",
              style: TextStyle(color: Colors.green),
            )
          else
            const Text(
              "Not uploaded",
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    ],
  );
}
}