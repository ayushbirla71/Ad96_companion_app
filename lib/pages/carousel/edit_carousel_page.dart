// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:provider/provider.dart';

// import '../../models/carousel.dart';
// import '../../providers/carousel_provider.dart';

// class EditCarouselPage extends StatefulWidget {
//   final String id;

//   const EditCarouselPage({super.key, required this.id});

//   @override
//   State<EditCarouselPage> createState() => _EditCarouselPageState();
// }

// class _EditCarouselPageState extends State<EditCarouselPage> {
//   final nameController = TextEditingController();

//   List<CarouselItem> items = [];
//   List<dynamic> availableAds = [];

//   bool loading = false;
//   bool loadingAds = true;

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   Future<void> loadData() async {
//     final provider = context.read<CarouselProvider>();

//     final carousel =
//         provider.carousels.firstWhere((c) => c.carouselId == widget.id);

//     nameController.text = carousel.name;

//     final ads = await provider.fetchAds();

//     setState(() {
//       items = List.from(carousel.items);
//       availableAds = ads;
//       loadingAds = false;
//     });
//   }

//   /// ADD EXISTING
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

//   /// ADD NEW
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

//   void updateItem(String id,
//       {String? name, int? duration, String? fileUrl}) {
//     final index = items.indexWhere((e) => e.id == id);

//     setState(() {
//       items[index] = items[index].copyWith(
//         name: name ?? items[index].name,
//         duration: duration ?? items[index].duration,
//         fileUrl: fileUrl ?? items[index].fileUrl,
//       );
//     });
//   }

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

//   Future<void> save() async {
//     if (nameController.text.trim().isEmpty) return;

//     setState(() => loading = true);

//     final provider = context.read<CarouselProvider>();

//     await provider.updateCarousel(
//       carouselId: widget.id,
//       name: nameController.text,
//       items: items,
//     );

//     setState(() => loading = false);

//     if (!mounted) return;
//     Navigator.pop(context);
//   }

//   /// BOTTOM SHEET
//   void showExistingAdsBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: availableAds.length,
//           itemBuilder: (context, index) {
//             final ad = availableAds[index];

//             return ListTile(
//               leading: const Icon(Icons.campaign),
//               title: Text(ad["name"]),
//               subtitle: Text("Duration: ${ad["duration"]}s"),
//               onTap: () {
//                 addExistingAd(ad["ad_id"]);
//                 Navigator.pop(context);
//               },
//             );
//           },
//         );
//       },
//     );
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
//         title: const Text("Edit Carousel"),
//         actions: [
//           IconButton(
//             onPressed: loading ? null : save,
//             icon: loading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Icons.save),
//           )
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

//             /// ADD ITEM DROPDOWN (CLEAN)
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == "upload") {
//                   addNewAd();
//                 } else {
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
//               itemBuilder: (context) => const [
//                 PopupMenuItem(
//                   value: "upload",
//                   child: Row(
//                     children: [
//                       Icon(Icons.upload),
//                       SizedBox(width: 10),
//                       Text("Upload New Ad"),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
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

//             /// LIST
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

//             /// SUMMARY
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Items: ${items.length}"),
//                   Text(
//                     "Duration: ${totalDuration ~/ 60}m ${totalDuration % 60}s",
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   /// EXISTING ITEM
//   Widget buildExistingAdItem(CarouselItem item) {
//     return Row(
//       children: [
//         const Icon(Icons.drag_handle),
//         const SizedBox(width: 10),
//         Expanded(child: Text(item.name ?? "")),
//         Text("${item.duration}s"),
//         IconButton(
//           icon: const Icon(Icons.delete, color: Colors.red),
//           onPressed: () => removeItem(item.id),
//         ),
//       ],
//     );
//   }

//   /// NEW ITEM
//   Widget buildNewAdItem(CarouselItem item) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.drag_handle),
//             const SizedBox(width: 10),

//             Expanded(
//               child: TextField(
//                 decoration: const InputDecoration(
//                   labelText: "Ad Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: (v) => updateItem(item.id, name: v),
//               ),
//             ),

//             const SizedBox(width: 10),

//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => removeItem(item.id),
//             ),
//           ],
//         ),

//         const SizedBox(height: 10),

//         Row(
//           children: [
//             ElevatedButton.icon(
//               onPressed: () => uploadFile(item.id),
//               icon: const Icon(Icons.upload),
//               label: const Text("Upload File"),
//             ),
//             const SizedBox(width: 10),

//             if (item.fileUrl != null && item.fileUrl!.isNotEmpty)
//               const Text("Uploaded", style: TextStyle(color: Colors.green))
//             else
//               const Text("Not uploaded", style: TextStyle(color: Colors.red)),
//           ],
//         )
//       ],
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NEW UPDATED UI >>>>>>>>>>>>>>>>>>>>>
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/carousel.dart';
import '../../providers/carousel_provider.dart';
import '../../theme/app_colors.dart';

class EditCarouselPage extends StatefulWidget {
  final String id;

  const EditCarouselPage({super.key, required this.id});

  @override
  State<EditCarouselPage> createState() => _EditCarouselPageState();
}

class _EditCarouselPageState extends State<EditCarouselPage> {
  final nameController = TextEditingController();

  List<CarouselItem> items = [];
  List<dynamic> availableAds = [];

  bool loading = false;
  bool loadingAds = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final provider = context.read<CarouselProvider>();

    final carousel = provider.carousels.firstWhere(
      (c) => c.carouselId == widget.id,
    );

    nameController.text = carousel.name;

    final ads = await provider.fetchAds();

    setState(() {
      items = List.from(carousel.items);
      availableAds = ads;
      loadingAds = false;
    });
  }

  /// ADD EXISTING
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

  /// ADD NEW
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

  Future<void> uploadFile(String itemId) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = File(result.files.single.path!);

    final provider = context.read<CarouselProvider>();
    final fileUrl = await provider.uploadAdFile(file);

    updateItem(itemId, fileUrl: fileUrl);
  }

  int get totalDuration {
    return items.fold(0, (sum, e) => sum + (e.duration ?? 0));
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) return;

    setState(() => loading = true);

    final provider = context.read<CarouselProvider>();

    await provider.updateCarousel(
      carouselId: widget.id,
      name: nameController.text,
      items: items,
    );

    setState(() => loading = false);

    if (!mounted) return;
    Navigator.pop(context);
  }

  /// BOTTOM SHEET
  void showExistingAdsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Select Existing Ad",
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 18),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availableAds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final ad = availableAds[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: appColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: appColors.border),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: appColors.orangeLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: appColors.orange,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          ad["name"],
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          "Duration: ${ad["duration"]}s",
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          addExistingAd(ad["ad_id"]);
                          Navigator.pop(context);
                        },
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
  Widget build(BuildContext context) {
    if (loadingAds) {
      return Scaffold(
        backgroundColor: appColors.bg,
        body: Center(child: CircularProgressIndicator(color: appColors.accent)),
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

        title: Text(
          "Edit Carousel",
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "Save Carousel",
            onPressed: loading ? null : save,
            icon: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: appColors.accent,
                      strokeWidth: 2,
                    ),
                  )
                : Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: appColors.greenLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: appColors.green.withOpacity(0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.save_rounded,
                      color: appColors.green,
                      size: 17,
                    ),
                  ),
          ),

          const SizedBox(width: 4),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          children: [
            /// NAME
            Container(
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
              child: TextField(
                controller: nameController,
                style: TextStyle(color: appColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Carousel Name",
                  hintStyle: TextStyle(color: appColors.textMuted),
                  prefixIcon: Icon(
                    Icons.view_carousel_rounded,
                    color: appColors.orange,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ADD ITEM
            PopupMenuButton<String>(
              color: appColors.surface,
              onSelected: (value) {
                if (value == "upload") {
                  addNewAd();
                } else {
                  showExistingAdsBottomSheet();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [appColors.accent, const Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.accent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Add Item",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "upload",
                  child: Row(
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        color: appColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text("Upload New Ad"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "existing",
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_rounded,
                        color: appColors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text("Select Existing Ad"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// LIST
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
                    decoration: BoxDecoration(
                      color: appColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: appColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: item.isNew
                          ? buildNewAdItem(item)
                          : buildExistingAdItem(item),
                    ),
                  );
                },
              ),
            ),

            /// SUMMARY
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Items: ${items.length}",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Duration: ${totalDuration ~/ 60}m ${totalDuration % 60}s",
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EXISTING ITEM
  Widget buildExistingAdItem(CarouselItem item) {
    return Row(
      children: [
        Icon(Icons.drag_handle_rounded, color: appColors.textMuted),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            item.name ?? "",
            style: TextStyle(
              color: appColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: appColors.orangeLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${item.duration}s",
            style: TextStyle(
              color: appColors.orange,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),

        const SizedBox(width: 8),

        IconButton(
          icon: Icon(Icons.delete_rounded, color: appColors.red),
          onPressed: () => removeItem(item.id),
        ),
      ],
    );
  }

  /// NEW ITEM
  Widget buildNewAdItem(CarouselItem item) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.drag_handle_rounded, color: appColors.textMuted),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                style: TextStyle(color: appColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Ad Name",
                  hintStyle: TextStyle(color: appColors.textMuted),
                  filled: true,
                  fillColor: appColors.surfaceHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColors.accent),
                  ),
                ),
                onChanged: (v) => updateItem(item.id, name: v),
              ),
            ),

            const SizedBox(width: 10),

            IconButton(
              icon: Icon(Icons.delete_rounded, color: appColors.red),
              onPressed: () => removeItem(item.id),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            GestureDetector(
              onTap: () => uploadFile(item.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: appColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.upload_rounded, color: Colors.white, size: 17),
                    SizedBox(width: 8),
                    Text(
                      "Upload File",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                item.fileUrl != null && item.fileUrl!.isNotEmpty
                    ? "Uploaded"
                    : "Not uploaded",
                style: TextStyle(
                  color: item.fileUrl != null && item.fileUrl!.isNotEmpty
                      ? appColors.green
                      : appColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
