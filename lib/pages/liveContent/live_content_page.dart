// import 'package:cms_app/pages/liveContent/create_live_content_page.dart';
// import 'package:flutter/material.dart';
// import '../../models/liveContent.dart';
// import '../../services/live_content_service.dart';
// import 'live_content_details_page.dart';

// class LiveContentPage extends StatefulWidget {
//   const LiveContentPage({super.key});

//   @override
//   State<LiveContentPage> createState() => _LiveContentPageState();
// }

// class _LiveContentPageState extends State<LiveContentPage> {

//   List<LiveContent> contents = [];
//   List<LiveContent> filtered = [];

//   String searchText = "";

//   String statusFilter = "all";
//   String typeFilter = "all";

//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadContents();
//   }

//   Future<void> loadContents() async {

//     final data = await LiveContentService().fetchLiveContents();

//     setState(() {
//       contents = data;
//       filtered = data;
//       loading = false;
//     });
//   }

//   /// APPLY FILTERS
//   void applyFilters() {

//     List<LiveContent> temp = List.from(contents);

//     /// SEARCH
//     if (searchText.isNotEmpty) {
//       temp = temp.where((e) =>
//           e.name.toLowerCase().contains(searchText.toLowerCase())).toList();
//     }

//     /// STATUS FILTER
//     if (statusFilter != "all") {
//       temp = temp.where((e) => e.status == statusFilter).toList();
//     }

//     /// TYPE FILTER
//     if (typeFilter != "all") {
//       temp = temp.where((e) => e.type == typeFilter).toList();
//     }

//     setState(() {
//       filtered = temp;
//     });
//   }

//   /// FILTER MODAL
//   void openFilter() {

//     showModalBottomSheet(
//       context: context,
//       builder: (_) {

//         return StatefulBuilder(
//           builder: (context, setModalState) {

//             return Padding(
//               padding: const EdgeInsets.all(16),

//               child: Column(
//                 mainAxisSize: MainAxisSize.min,

//                 children: [

//                   const Text(
//                     "Filters",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// STATUS FILTER
//                   DropdownButtonFormField<String>(

//                     value: statusFilter,

//                     decoration: const InputDecoration(
//                       labelText: "Status",
//                       border: OutlineInputBorder(),
//                     ),

//                     items: const [
//                       DropdownMenuItem(value: "all", child: Text("All")),
//                       DropdownMenuItem(value: "active", child: Text("Active")),
//                       DropdownMenuItem(value: "inactive", child: Text("Inactive")),
//                     ],

//                     onChanged: (v) {
//                       setModalState(() {
//                         statusFilter = v!;
//                       });
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   /// TYPE FILTER
//                   DropdownButtonFormField<String>(

//                     value: typeFilter,

//                     decoration: const InputDecoration(
//                       labelText: "Content Type",
//                       border: OutlineInputBorder(),
//                     ),

//                     items: const [
//                       DropdownMenuItem(value: "all", child: Text("All")),
//                       DropdownMenuItem(value: "provider", child: Text("Provider")),
//                       DropdownMenuItem(value: "streaming", child: Text("Streaming")),
//                       DropdownMenuItem(value: "website", child: Text("Website")),
//                     ],

//                     onChanged: (v) {
//                       setModalState(() {
//                         typeFilter = v!;
//                       });
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   /// BUTTONS
//                   Row(
//                     children: [

//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {

//                             setState(() {
//                               statusFilter = "all";
//                               typeFilter = "all";
//                             });

//                             applyFilters();

//                             Navigator.pop(context);
//                           },
//                           child: const Text("Clear"),
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {

//                             applyFilters();

//                             Navigator.pop(context);
//                           },
//                           child: const Text("Apply"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   /// STATUS COLOR
//   Color statusColor(String status) {
//     if (status == "active") return Colors.green;
//     return Colors.grey;
//   }

//   /// TYPE ICON
//   IconData typeIcon(String type) {

//     switch (type) {

//       case "provider":
//         return Icons.cloud;

//       case "streaming":
//         return Icons.live_tv;

//       case "website":
//         return Icons.language;

//       default:
//         return Icons.video_collection;
//     }
//   }

//   /// DURATION TEXT
//   String durationText(int seconds) {

//     if (seconds == 0) return "Indefinite";

//     final m = seconds ~/ 60;
//     final s = seconds % 60;

//     return "${m}m ${s}s";
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(

//     appBar: AppBar(
//   title: const Text("Live Content"),
//   actions: [
//     IconButton(
//       icon: const Icon(Icons.add),
//       tooltip: "Create Live Content",
//       onPressed: () async {

//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const CreateLiveContentPage(),
//           ),
//         );

//         /// refresh list after create
//         if (result == true) {
//           loadContents();
//         }
//       },
//     ),
//   ],
// ),

//       body: Column(
//         children: [

//           /// SEARCH + FILTER
//           Padding(
//             padding: const EdgeInsets.all(12),

//             child: Row(
//               children: [

//                 Expanded(
//                   child: TextField(

//                     decoration: InputDecoration(
//                       hintText: "Search live content...",
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),

//                     onChanged: (v) {

//                       setState(() {
//                         searchText = v;
//                       });

//                       applyFilters();
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 10),

//                 IconButton(
//                   icon: const Icon(Icons.filter_list),
//                   onPressed: openFilter,
//                 ),
//               ],
//             ),
//           ),

//           Expanded(

//             child: loading
//                 ? const Center(child: CircularProgressIndicator())

//                 : RefreshIndicator(

//                     onRefresh: loadContents,

//                     child: ListView.separated(

//                       itemCount: filtered.length,

//                       separatorBuilder: (_, __) =>
//                           const Divider(height: 1),

//                       itemBuilder: (context, index) {

//                         final item = filtered[index];

//                         return ListTile(

//                           leading: CircleAvatar(
//                             backgroundColor: Colors.blue.withOpacity(0.1),

//                             child: Icon(
//                               typeIcon(item.type),
//                               color: Colors.blue,
//                             ),
//                           ),

//                           title: Text(
//                             item.name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),

//                           subtitle: Text(
//                             "${item.type} • ${durationText(item.duration)}",
//                           ),

//                           trailing: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),

//                             decoration: BoxDecoration(
//                               color: statusColor(item.status)
//                                   .withOpacity(0.15),

//                               borderRadius: BorderRadius.circular(6),
//                             ),

//                             child: Text(
//                               item.status,

//                               style: TextStyle(
//                                 color: statusColor(item.status),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),

//                           onTap: () {

//                             Navigator.push(
//                               context,

//                               MaterialPageRoute(
//                                 builder: (_) => LiveContentDetailsPage(
//                                   content: item,
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cms_app/pages/liveContent/create_live_content_page.dart';
import 'package:flutter/material.dart';
import '../../models/liveContent.dart';
import '../../services/live_content_service.dart';
import '../../theme/app_colors.dart'; // adjust import path as needed
import 'live_content_details_page.dart';

class LiveContentPage extends StatefulWidget {
  const LiveContentPage({super.key});

  @override
  State<LiveContentPage> createState() => _LiveContentPageState();
}

class _LiveContentPageState extends State<LiveContentPage> {
  final _searchCtrl = TextEditingController();

  List<LiveContent> contents = [];
  List<LiveContent> filtered = [];

  String searchText = "";
  String statusFilter = "all";
  String typeFilter = "all";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadContents();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> loadContents() async {
    final data = await LiveContentService().fetchLiveContents();

    setState(() {
      contents = data;
      filtered = data;
      loading = false;
    });
  }

  /// APPLY FILTERS
  void applyFilters() {
    List<LiveContent> temp = List.from(contents);

    /// SEARCH
    if (searchText.isNotEmpty) {
      temp = temp
          .where((e) => e.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    /// STATUS FILTER
    if (statusFilter != "all") {
      temp = temp.where((e) => e.status == statusFilter).toList();
    }

    /// TYPE FILTER
    if (typeFilter != "all") {
      temp = temp.where((e) => e.type == typeFilter).toList();
    }

    setState(() {
      filtered = temp;
    });
  }

  /// FILTER MODAL
  void openFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          Icons.filter_list_rounded,
                          color: appColors.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Filters",
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
                  const SizedBox(height: 16),

                  /// STATUS FILTER
                  Container(
                    decoration: BoxDecoration(
                      color: appColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appColors.border),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: statusFilter,
                      dropdownColor: appColors.surface,
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: "Status",
                        labelStyle: TextStyle(
                          color: appColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.toggle_on_rounded,
                          color: appColors.textMuted,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      items: const [
                        DropdownMenuItem(value: "all", child: Text("All")),
                        DropdownMenuItem(
                          value: "active",
                          child: Text("Active"),
                        ),
                        DropdownMenuItem(
                          value: "inactive",
                          child: Text("Inactive"),
                        ),
                      ],
                      onChanged: (v) {
                        setModalState(() {
                          statusFilter = v!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// TYPE FILTER
                  Container(
                    decoration: BoxDecoration(
                      color: appColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appColors.border),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: typeFilter,
                      dropdownColor: appColors.surface,
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: "Content Type",
                        labelStyle: TextStyle(
                          color: appColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.category_rounded,
                          color: appColors.textMuted,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      items: const [
                        DropdownMenuItem(value: "all", child: Text("All")),
                        DropdownMenuItem(
                          value: "provider",
                          child: Text("Provider"),
                        ),
                        DropdownMenuItem(
                          value: "streaming",
                          child: Text("Streaming"),
                        ),
                        DropdownMenuItem(
                          value: "website",
                          child: Text("Website"),
                        ),
                      ],
                      onChanged: (v) {
                        setModalState(() {
                          typeFilter = v!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              statusFilter = "all";
                              typeFilter = "all";
                            });
                            applyFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: appColors.textSecondary,
                            side: BorderSide(color: appColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text("Clear"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            applyFilters();
                            Navigator.pop(context);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: appColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

  /// STATUS COLOR
  Color statusColor(String status) {
    if (status == "active") return appColors.green;
    return appColors.textMuted;
  }

  Color statusBgColor(String status) {
    if (status == "active") return appColors.greenLight;
    return appColors.surfaceHigh;
  }

  /// TYPE ICON
  IconData typeIcon(String type) {
    switch (type) {
      case "provider":
        return Icons.cloud_rounded;
      case "streaming":
        return Icons.live_tv_rounded;
      case "website":
        return Icons.language_rounded;
      default:
        return Icons.video_collection_rounded;
    }
  }

  Color typeIconColor(String type) {
    switch (type) {
      case "provider":
        return appColors.teal;
      case "streaming":
        return appColors.red;
      case "website":
        return appColors.purple;
      default:
        return appColors.accent;
    }
  }

  Color typeIconBg(String type) {
    switch (type) {
      case "provider":
        return appColors.tealLight;
      case "streaming":
        return appColors.redLight;
      case "website":
        return appColors.purpleLight;
      default:
        return appColors.accentLight;
    }
  }

  /// DURATION TEXT
  String durationText(int seconds) {
    if (seconds == 0) return "Indefinite";
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m}m ${s}s";
  }

  bool get _hasActiveFilters => statusFilter != "all" || typeFilter != "all";

  @override
  Widget build(BuildContext context) {
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
                Icons.live_tv_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Content',
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                Text(
                  '${filtered.length} item${filtered.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: appColors.textMuted,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.border),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: appColors.textSecondary,
                size: 17,
              ),
            ),
            onPressed: loadContents,
          ),
          IconButton(
            tooltip: 'Create Live Content',
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.accentLight,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.accent.withOpacity(0.3)),
              ),
              child: Icon(Icons.add_rounded, color: appColors.accent, size: 18),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateLiveContentPage(),
                ),
              );

              /// refresh list after create
              if (result == true) {
                loadContents();
              }
            },
          ),
          const SizedBox(width: 4),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),

      body: Column(
        children: [
          /// SEARCH + FILTER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
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
                      controller: _searchCtrl,
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search live content...",
                        hintStyle: TextStyle(
                          color: appColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: appColors.textMuted,
                          size: 18,
                        ),
                        suffixIcon: searchText.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: appColors.textMuted,
                                  size: 16,
                                ),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => searchText = '');
                                  applyFilters();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          searchText = v;
                        });
                        applyFilters();
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// FILTER BUTTON
                GestureDetector(
                  onTap: openFilter,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hasActiveFilters
                          ? appColors.accentLight
                          : appColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasActiveFilters
                            ? appColors.accent.withOpacity(0.4)
                            : appColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: _hasActiveFilters
                          ? appColors.accent
                          : appColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: loading
                ? Center(
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
                          'Loading live content…',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: appColors.surfaceHigh,
                            shape: BoxShape.circle,
                            border: Border.all(color: appColors.border),
                          ),
                          child: Icon(
                            Icons.live_tv_rounded,
                            color: appColors.textMuted,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No live content found',
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: appColors.accent,
                    backgroundColor: appColors.surface,
                    onRefresh: loadContents,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filtered[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LiveContentDetailsPage(content: item),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: appColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: appColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: appColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                /// TYPE ICON
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: typeIconBg(item.type),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    typeIcon(item.type),
                                    color: typeIconColor(item.type),
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: appColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 4),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.category_rounded,
                                            size: 11,
                                            color: appColors.textMuted,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            item.type,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: appColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.timer_rounded,
                                            size: 11,
                                            color: appColors.textMuted,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            durationText(item.duration),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: appColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                /// STATUS PILL
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBgColor(item.status),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor(
                                        item.status,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: statusColor(item.status),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor(item.status),
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
