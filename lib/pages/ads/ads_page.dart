import 'package:cms_app/utils/feature_access.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AdProvider>().loadAds();
  }

  // 🎛️ MODAL FILTER UI
  void openFilter() {
    final adProvider = context.read<AdProvider>();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  /// STATUS DROPDOWN
                  DropdownButtonFormField<String>(
                    value: adProvider.statusFilter,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(
                        value: "pending",
                        child: Text("Pending"),
                      ),
                      DropdownMenuItem(
                        value: "processing",
                        child: Text("Processing"),
                      ),
                      DropdownMenuItem(
                        value: "completed",
                        child: Text("Completed"),
                      ),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        adProvider.setStatusFilter(v!);
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      /// CLEAR BUTTON
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            adProvider.clearFilters();
                            Navigator.pop(context);
                          },
                          child: const Text("Clear"),
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// APPLY BUTTON
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // The provider already updates when onChanged fires,
                            // so we just need to close the modal.
                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

            // onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const AddAdPage()),
            //   );
            // },
            onPressed: () {
              FeatureAccess.openStorageLimitedFeature(
                context: context,

                newFileSizeBytes: 0,

                page: const AddAdPage(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH + FILTER TOGGLE
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search ad...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (v) {
                      Future.microtask(() {
                        adProvider.setSearch(v);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: "Filters",
                  icon: const Icon(Icons.filter_list),
                  onPressed: openFilter, // Trigger Bottom Sheet
                ),
              ],
            ),
          ),

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
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(icon),
                          title: Text(
                            ad.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
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
