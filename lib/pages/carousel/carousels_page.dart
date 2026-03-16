import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/carousel_provider.dart';
import 'create_carousel_page.dart';
import 'carousel_details_page.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({super.key});

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CarouselProvider>().loadCarousels();
    });
  }

  String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m}m ${s}s";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarouselProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carousels"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCarouselPage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search carousel...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: provider.setSearch,
            ),
          ),

          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: provider.filteredCarousels.length,
                    itemBuilder: (_, i) {
                      final c = provider.filteredCarousels[i];

                      return Card(
                        margin: const EdgeInsets.all(10),

                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CarouselDetailsPage(id: c.carouselId),
                              ),
                            );
                          },

                          title: Text(c.name),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Items: ${c.items.length}"),
                              Text(
                                "Duration: ${formatDuration(c.totalDuration)}",
                              ),
                              Text("Status: ${c.status}"),
                            ],
                          ),

                          trailing: PopupMenuButton(
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: "toggle",
                                child: Text("Toggle Status"),
                              ),
                              const PopupMenuItem(
                                value: "delete",
                                child: Text("Delete"),
                              ),
                            ],

                            onSelected: (v) async {
                              if (v == "toggle") {
                                await provider.toggleStatus(c);
                              } else if (v == "delete") {
                                await provider.deleteCarousel(c.carouselId);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
