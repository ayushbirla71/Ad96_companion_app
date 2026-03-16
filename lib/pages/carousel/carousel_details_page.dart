import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/carousel_provider.dart';
import 'edit_carousel_page.dart';

class CarouselDetailsPage extends StatelessWidget {
  final String id;

  const CarouselDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<CarouselProvider>();

    final carousel =
        provider.carousels.firstWhere((c) => c.carouselId == id);

    int totalDuration = carousel.items.fold(
      0,
      (sum, e) => sum + e.duration,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carousel Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCarouselPage(id: id),
                ),
              );
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              carousel.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Status: ${carousel.status}"),
            Text("Items: ${carousel.items.length}"),

            Text(
              "Duration: ${totalDuration ~/ 60}m ${totalDuration % 60}s",
            ),

            const SizedBox(height: 20),

            const Divider(),

            const Text(
              "Carousel Items",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: carousel.items.length,
                itemBuilder: (_, i) {

                  final item = carousel.items[i];

                  return Card(
                    child: ListTile(
                      leading: Text("${i + 1}"),
                      title: Text(item.name ?? "Ad"),
                      subtitle: Text("Duration: ${item.duration}s"),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}