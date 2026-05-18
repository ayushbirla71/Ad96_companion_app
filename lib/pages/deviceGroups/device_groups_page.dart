// import 'package:cms_app/pages/deviceGroups/device_group_details_page.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/group_provider.dart';
// import '../../models/group.dart';
// import 'group_details_page.dart';

// class GroupsPage extends StatefulWidget {
//   const GroupsPage({super.key});

//   @override
//   State<GroupsPage> createState() => _GroupsPageState();
// }

// class _GroupsPageState extends State<GroupsPage> {
//   String searchText = "";

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<GroupProvider>().loadGroups();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<GroupProvider>();

//     final filteredGroups = provider.groups.where((group) {
//       return group.name.toLowerCase().contains(searchText.toLowerCase());
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Groups"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: provider.loadGroups,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search group...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onChanged: (v) => setState(() => searchText = v),
//             ),
//           ),
//           Expanded(
//             child: provider.loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : RefreshIndicator(
//                     onRefresh: provider.loadGroups,
//                     child: ListView.builder(
//                       itemCount: filteredGroups.length,
//                       itemBuilder: (_, i) {
//                         final group = filteredGroups[i];

//                         return Card(
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           child: ListTile(
//                             title: Text(group.name),
//                             subtitle: Text(
//                               "Client: ${group.clientName}\nDevices: ${group.deviceCount}",
//                             ),
//                             isThreeLine: true,
//                             trailing: const Icon(
//                               Icons.arrow_forward_ios,
//                               size: 16,
//                             ),
//                             onTap: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       // GroupDetailsPage(group: group),
//                                       DeviceGroupDetailsPage(group: group),
//                                 ),
//                               );
//                               context.read<GroupProvider>().loadGroups();
//                             },
//                           ),
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

import 'package:cms_app/pages/deviceGroups/device_group_details_page.dart';
import 'package:cms_app/pages/widgets/dashboard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group.dart';
import 'package:cms_app/theme/app_colors.dart';

// ─── Colour palette ───────────────────────────────────────────────────────────
// const _c = _Colors();

// class _Colors {
//   const _Colors();
//   Color get accent => const Color(0xFF2563EB);
//   Color get accentLight => const Color(0xFFEFF6FF);
//   Color get green => const Color(0xFF059669);
//   Color get greenLight => const Color(0xFFECFDF5);
//   Color get bg => const Color(0xFFF1F5F9);
//   Color get surface => const Color(0xFFFFFFFF);
//   Color get surfaceHigh => const Color(0xFFF8FAFC);
//   Color get textPrimary => const Color(0xFF0F172A);
//   Color get textSecondary => const Color(0xFF475569);
//   Color get textMuted => const Color(0xFF94A3B8);
//   Color get border => const Color(0xFFE2E8F0);
//   Color get borderLight => const Color(0xFFF1F5F9);
//   Color get shadow => const Color(0x08000000);
//   Color get purple => const Color(0xFF7C3AED);
//   Color get purpleLight => const Color(0xFFF5F3FF);
// }

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String searchText = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroups();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    final filteredGroups = provider.groups.where((group) {
      return group.name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: appColors.bg,
      // appBar: AppBar(
      //   backgroundColor: appColors.surface,
      //   surfaceTintColor: Colors.transparent,
      //   elevation: 0,
      //   titleSpacing: 16,
      //   title: Row(
      //     children: [
      //       Container(
      //         width: 34,
      //         height: 34,
      //         decoration: BoxDecoration(
      //           gradient: LinearGradient(
      //             colors: [appColors.accent, const Color(0xFF1D4ED8)],
      //             begin: Alignment.topLeft,
      //             end: Alignment.bottomRight,
      //           ),
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //         child: const Icon(
      //           Icons.group_work_rounded,
      //           color: Colors.white,
      //           size: 18,
      //         ),
      //       ),
      //       const SizedBox(width: 10),
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             'Device Groups',
      //             style: TextStyle(
      //               color: appColors.textPrimary,
      //               fontSize: 15,
      //               fontWeight: FontWeight.w700,
      //               letterSpacing: -0.3,
      //               height: 1.1,
      //             ),
      //           ),
      //           Text(
      //             '${filteredGroups.length} group${filteredGroups.length != 1 ? 's' : ''}',
      //             style: TextStyle(
      //               color: appColors.textMuted,
      //               fontSize: 10,
      //               height: 1,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Container(
      //         width: 34,
      //         height: 34,
      //         decoration: BoxDecoration(
      //           color: appColors.surfaceHigh,
      //           shape: BoxShape.circle,
      //           border: Border.all(color: appColors.border),
      //         ),
      //         child: Icon(
      //           Icons.refresh_rounded,
      //           color: appColors.textSecondary,
      //           size: 17,
      //         ),
      //       ),
      //       onPressed: provider.loadGroups,
      //     ),
      //     const SizedBox(width: 8),
      //   ],
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     child: Container(height: 1, color: appColors.border),
      //   ),
      // ),
      appBar: DashboardAppBar(
        title: "Device Groups 1",
        subtitle:
            '${filteredGroups.length} group${filteredGroups.length != 1 ? 's' : ''}',
        icon: Icons.group_work_rounded,
        onRefresh: provider.loadGroups,
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                style: TextStyle(color: appColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search group...',
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
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onChanged: (v) => setState(() => searchText = v),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── List ──
          Expanded(
            child: provider.loading
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
                          'Loading groups…',
                          style: TextStyle(
                            color: appColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredGroups.isEmpty
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
                            Icons.group_work_outlined,
                            color: appColors.textMuted,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No groups found',
                          style: TextStyle(
                            color: appColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          searchText.isNotEmpty
                              ? 'Try a different search term'
                              : 'No device groups available',
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
                    onRefresh: provider.loadGroups,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: filteredGroups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final group = filteredGroups[i];
                        return _GroupCard(
                          group: group,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DeviceGroupDetailsPage(group: group),
                              ),
                            );
                            context.read<GroupProvider>().loadGroups();
                          },
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

// ─── Group Card ───────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final dynamic group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(16),
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
            // Icon container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: appColors.purpleLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: appColors.purple.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.group_work_rounded,
                color: appColors.purple,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.clientName ?? '—',
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Device count badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: appColors.accentLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: appColors.accent.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.devices_rounded,
                              size: 11,
                              color: appColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${group.deviceCount} device${group.deviceCount != 1 ? 's' : ''}',
                              style: TextStyle(
                                color: appColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Arrow
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: appColors.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: appColors.border),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: appColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
