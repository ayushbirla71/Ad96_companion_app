import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import 'ad_details_page.dart';
import 'ad_create_page.dart';

class AdsPage extends StatefulWidget {
  const AdsPage({super.key});

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AdProvider>().loadAds();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<AdProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ads"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Ad",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAdPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH + FILTER TOGGLE
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search ad...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: adProvider.setSearch,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: "Filters",
                  icon: Icon(
                    Icons.filter_list,
                    color: showFilters ? Colors.blue : null,
                  ),
                  onPressed: () {
                    setState(() => showFilters = !showFilters);
                  },
                ),
              ],
            ),
          ),

          // 🎛 FILTERS + CLEAR BUTTON
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: showFilters
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: adProvider.statusFilter,
                    decoration: const InputDecoration(labelText: "Status"),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "pending", child: Text("Pending")),
                      DropdownMenuItem(
                          value: "processing", child: Text("Processing")),
                      DropdownMenuItem(
                          value: "completed", child: Text("Completed")),
                    ],
                    onChanged: (v) => adProvider.setStatusFilter(v!),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text("Clear Filters"),
                      onPressed: adProvider.clearFilters,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(),
          ),

          const SizedBox(height: 8),

          // 📺 ADS LIST
          Expanded(
            child: Builder(
              builder: (_) {
                if (adProvider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adProvider.error != null) {
                  return Center(child: Text(adProvider.error!));
                }

                if (adProvider.filteredAds.isEmpty) {
                  return const Center(child: Text("No ads found"));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    itemCount: adProvider.filteredAds.length,
                    itemBuilder: (_, i) {
                      final ad = adProvider.filteredAds[i];

                      // Detect if the URL is a video or image
                      final isVideo = _isVideo(ad.url ?? "");
                      final icon = isVideo ? Icons.play_circle : Icons.image;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Icon(icon),
                          title: Text(ad.name),
                          subtitle: Text(ad.status),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdDetailsPage(ad: ad),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // URL Type Detection
  // -----------------------------
  bool _isVideo(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      return path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.webm');
    } catch (_) {
      return false;
    }
  }

  bool _isImage(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      return path.endsWith('.jpeg') ||
          path.endsWith('.jpg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif');
    } catch (_) {
      return false;
    }
  }
}
