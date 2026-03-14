import 'package:cms_app/models/carousel.dart';
import 'package:cms_app/providers/carousel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CarouselDetailsPage extends StatefulWidget {
  final String id;

  const CarouselDetailsPage({super.key, required this.id});

  @override
  State<CarouselDetailsPage> createState() => _CarouselDetailsPageState();
}

class _CarouselDetailsPageState extends State<CarouselDetailsPage> {

  final nameController = TextEditingController();

  List<CarouselItem> items = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadCarousel();
  }

  Future<void> loadCarousel() async {

    final provider = context.read<CarouselProvider>();

    final carousel = provider.carousels.firstWhere(
      (c) => c.carouselId == widget.id,
    );

    nameController.text = carousel.name;

    setState(() {
      items = List.from(carousel.items);
    });
  }

  void addNewAd() {

    setState(() {
      items.add(
        CarouselItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "",
          duration: 0,
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

  void updateItem(String id, String name, int duration) {

    setState(() {
      final index = items.indexWhere((e) => e.id == id);

      items[index] = items[index].copyWith(
        name: name,
        duration: duration,
      );
    });
  }

  int get totalDuration {
    return items.fold(0, (sum, e) => sum + e.duration);
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Carousel"),
        actions: [

          IconButton(
            onPressed: loading ? null : save,
            icon: loading
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
          )

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// Carousel Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Carousel Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// Add new ad
            Row(
              children: [

                ElevatedButton.icon(
                  onPressed: addNewAd,
                  icon: const Icon(Icons.add),
                  label: const Text("New Ad"),
                ),

                const Spacer(),

                Text(
                  "Items: ${items.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )

              ],
            ),

            const SizedBox(height: 20),

            /// Items list
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

                  final nameController =
                      TextEditingController(text: item.name);

                  final durationController =
                      TextEditingController(text: item.duration.toString());

                  return Card(
                    key: ValueKey(item.id),

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        children: [

                          Row(
                            children: [

                              const Icon(Icons.drag_handle),

                              const SizedBox(width: 10),

                              Expanded(
                                child: TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: "Ad Name",
                                  ),
                                  onChanged: (v) => updateItem(
                                    item.id,
                                    v,
                                    item.duration,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Sec",
                                  ),
                                  onChanged: (v) => updateItem(
                                    item.id,
                                    item.name ?? "",
                                    int.tryParse(v) ?? 0,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => removeItem(item.id),
                              )
                            ],
                          ),

                          if (item.fileUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                "File uploaded",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text("Total Items: ${items.length}"),

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
}