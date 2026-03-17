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

      print("adssssssssssssssssssssss ${ads}");

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

  /// CREATE CAROUSEL
  Future<void> create() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Carousel name required")));

      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one ad")));

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

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingAds) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// CAROUSEL INFO
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Carousel Info",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Carousel Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ADD ADS SECTION
                Card(
                  elevation: 2,

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Row(
                      children: [
                        /// SELECT EXISTING AD
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,

                            hint: const Text("Select Existing Ad"),

                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),

                            items: availableAds.map<DropdownMenuItem<String>>((
                              ad,
                            ) {
                              return DropdownMenuItem<String>(
                                value: ad["ad_id"].toString(),
                                child: Text(ad["name"]),
                              );
                            }).toList(),

                            onChanged: (value) {
                              if (value != null) addExistingAd(value);
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// UPLOAD NEW AD
                        ElevatedButton.icon(
                          onPressed: addNewAd,

                          icon: const Icon(Icons.add),

                          label: const Text("Upload Ad"),

                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ITEMS HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Carousel Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text("Total: ${items.length}"),
                  ],
                ),

                const SizedBox(height: 10),

                /// ITEMS LIST
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),

                      child: Padding(
                        padding: const EdgeInsets.all(16),

                        child: item.isNew
                            ? buildNewAdItem(item)
                            : buildExistingAdItem(item),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                /// SUMMARY
                Card(
                  color: Colors.grey.shade100,

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Items: ${items.length}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text(
                          "Duration: ${totalDuration ~/ 60}m ${totalDuration % 60}s",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
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

  /// EXISTING AD ITEM
  Widget buildExistingAdItem(CarouselItem item) {
    return Row(
      children: [
        const Icon(Icons.drag_handle),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name ?? "", style: const TextStyle(fontSize: 16)),

              Text("Duration: ${item.duration}s"),
            ],
          ),
        ),

        SizedBox(
          width: 80,

          child: TextField(
            keyboardType: TextInputType.number,

            controller: TextEditingController(text: item.duration.toString()),

            decoration: const InputDecoration(labelText: "Sec"),

            onChanged: (v) {
              updateItem(item.id, duration: int.tryParse(v) ?? 0);
            },
          ),
        ),

        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => removeItem(item.id),
        ),
      ],
    );
  }

  /// NEW AD ITEM
  Widget buildNewAdItem(CarouselItem item) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.drag_handle),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: "Ad Name"),
                onChanged: (v) {
                  updateItem(item.id, name: v);
                },
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 80,

              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Sec"),

                onChanged: (v) {
                  updateItem(item.id, duration: int.tryParse(v) ?? 0);
                },
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete),
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
              const Text(
                "File uploaded",
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ],
    );
  }
}
