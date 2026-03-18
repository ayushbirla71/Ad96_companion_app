import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../models/carousel.dart';
import '../../providers/carousel_provider.dart';

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

    final carousel =
        provider.carousels.firstWhere((c) => c.carouselId == widget.id);

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

  void updateItem(String id,
      {String? name, int? duration, String? fileUrl}) {
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
        );
      },
    );
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
        title: const Text("Edit Carousel"),
        actions: [
          IconButton(
            onPressed: loading ? null : save,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          )
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

            /// ADD ITEM DROPDOWN (CLEAN)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "upload") {
                  addNewAd();
                } else {
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
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "upload",
                  child: Row(
                    children: [
                      Icon(Icons.upload),
                      SizedBox(width: 10),
                      Text("Upload New Ad"),
                    ],
                  ),
                ),
                PopupMenuItem(
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

            /// SUMMARY
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Items: ${items.length}"),
                  Text(
                    "Duration: ${totalDuration ~/ 60}m ${totalDuration % 60}s",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// EXISTING ITEM
  Widget buildExistingAdItem(CarouselItem item) {
    return Row(
      children: [
        const Icon(Icons.drag_handle),
        const SizedBox(width: 10),
        Expanded(child: Text(item.name ?? "")),
        Text("${item.duration}s"),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
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
            const Icon(Icons.drag_handle),
            const SizedBox(width: 10),

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

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => removeItem(item.id),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => uploadFile(item.id),
              icon: const Icon(Icons.upload),
              label: const Text("Upload File"),
            ),
            const SizedBox(width: 10),

            if (item.fileUrl != null && item.fileUrl!.isNotEmpty)
              const Text("Uploaded", style: TextStyle(color: Colors.green))
            else
              const Text("Not uploaded", style: TextStyle(color: Colors.red)),
          ],
        )
      ],
    );
  }
}