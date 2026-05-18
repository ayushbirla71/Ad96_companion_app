// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../../providers/live_content_provider.dart';
// import '../../providers/channel_provider.dart';

// class CreateLiveContentPage extends StatefulWidget {
//   final String? id;

//   const CreateLiveContentPage({super.key, this.id});

//   @override
//   State<CreateLiveContentPage> createState() => _CreateLiveContentPageState();
// }

// class _CreateLiveContentPageState extends State<CreateLiveContentPage> {
//   final nameController = TextEditingController();
//   final urlController = TextEditingController();
//   final durationController = TextEditingController();

//   String contentType = "streaming";
//   String status = "active";

//   String? selectedChannelId;

//   DateTime? startTime;
//   DateTime? endTime;

//   bool autoplay = false;
//   bool mute = false;
//   bool loop = false;

//   bool loading = false;

//   bool get isEdit => widget.id != null;

//   @override
//   void initState() {
//     super.initState();

//     if (isEdit) {
//       fetchLiveContent();
//     }
//   }

//   Future fetchLiveContent() async {
//     setState(() {
//       loading = true;
//     });

//     final provider = context.read<LiveContentProvider>();

//     await provider.fetchContents();

//     final item = provider.contents.firstWhere((e) => e.id == widget.id);

//     nameController.text = item.name;
//     urlController.text = item.url;
//     durationController.text = item.duration.toString();
//     contentType = item.type;
//     status = item.status;

//     setState(() {
//       loading = false;
//     });
//   }

//   Future pickStart() async {
//     DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2024),
//       lastDate: DateTime(2100),
//     );

//     if (date == null) return;

//     TimeOfDay? time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (time == null) return;

//     setState(() {
//       startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//     });
//   }

//   Future pickEnd() async {
//     DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2024),
//       lastDate: DateTime(2100),
//     );

//     if (date == null) return;

//     TimeOfDay? time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (time == null) return;

//     setState(() {
//       endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//     });
//   }

//   Future submit() async {
//     if (nameController.text.isEmpty) return;
//     if (urlController.text.isEmpty) return;

//     setState(() {
//       loading = true;
//     });

//     try {

//       print("    ddddddddddddddd ${contentType}");
//       final provider = context.read<LiveContentProvider>();

//       await provider.createContent(
//         name: nameController.text,
//         url: urlController.text,
//         duration: int.tryParse(durationController.text) ?? 0,
//         type: contentType,
//         channelId: selectedChannelId,
//         status: status,
//         startTime: startTime,
//         endTime: endTime,
//         autoplay: autoplay,
//         mute: mute,
//         loop: loop,
//       );

//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       debugPrint("Create error: $e");
//     }

//     setState(() {
//       loading = false;
//     });
//   }

//   Widget previewCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Preview",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             Text("Type: $contentType"),

//             if (urlController.text.isNotEmpty)
//               Text("URL: ${urlController.text}"),

//             const SizedBox(height: 10),

//             Text(
//               "Duration: ${durationController.text == "0" ? "Indefinite" : "${durationController.text}s"}",
//             ),

//             const SizedBox(height: 10),

//             if (startTime != null)
//               Text("Start: ${DateFormat.yMd().add_jm().format(startTime!)}"),

//             if (endTime != null)
//               Text("End: ${DateFormat.yMd().add_jm().format(endTime!)}"),

//             const SizedBox(height: 10),

//             Wrap(
//               spacing: 8,
//               children: [
//                 if (autoplay) const Chip(label: Text("Autoplay")),
//                 if (mute) const Chip(label: Text("Mute")),
//                 if (loop) const Chip(label: Text("Loop")),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget channelDropdown() {
//     return Consumer<ChannelProvider>(
//       builder: (context, provider, _) {
//         if (provider.loading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return DropdownButtonFormField<String>(
//           value: selectedChannelId,
//           decoration: const InputDecoration(
//             labelText: "Select Channel",
//             border: OutlineInputBorder(),
//           ),
//           items: provider.channels.map((channel) {
//             return DropdownMenuItem(
//               value: channel.channelId,
//               child: Text(channel.name),
//             );
//           }).toList(),
//           onChanged: (value) {
//             final selected = provider.channels.firstWhere(
//               (c) => c.channelId == value,
//             );

//             setState(() {
//               selectedChannelId = value;
//               urlController.text = selected.playbackUrl;
//             });
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEdit ? "Edit Live Content" : "Create Live Content"),
//       ),

//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),

//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   const Text(
//                     "Basic Information",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 20),

//                   TextField(
//                     controller: nameController,
//                     decoration: const InputDecoration(
//                       labelText: "Content Name",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   DropdownButtonFormField(
//                     value: contentType,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: "Content Type",
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: "streaming", child: Text("Streaming")),
//                       DropdownMenuItem(value: "website", child: Text("Website")),
//                       DropdownMenuItem(value: "iframe", child: Text("iFrame")),
//                       DropdownMenuItem(value: "youtube", child: Text("YouTube")),
//                       DropdownMenuItem(value: "custom", child: Text("Custom")),
//                       DropdownMenuItem(value: "provider", child: Text("Dacast Provider")),
//                     ],
//                     onChanged: (v) async {

//                       setState(() {
//                         contentType = v.toString();
//                       });

//                       if (contentType == "provider") {
//                         final channelProvider = context.read<ChannelProvider>();

//                         if (channelProvider.channels.isEmpty) {
//                           await channelProvider.fetchChannels();
//                         }
//                       }
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   if (contentType != "provider")
//                     TextField(
//                       controller: urlController,
//                       onChanged: (_) => setState(() {}),
//                       decoration: const InputDecoration(
//                         labelText: "Content URL",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),

//                   if (contentType == "provider") channelDropdown(),

//                   const SizedBox(height: 20),

//                   TextField(
//                     controller: durationController,
//                     keyboardType: TextInputType.number,
//                     onChanged: (_) => setState(() {}),
//                     decoration: const InputDecoration(
//                       labelText: "Duration (seconds)",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   ListTile(
//                     title: const Text("Start Time"),
//                     subtitle: Text(
//                       startTime == null
//                           ? "Select"
//                           : DateFormat.yMd().add_jm().format(startTime!),
//                     ),
//                     onTap: pickStart,
//                   ),

//                   ListTile(
//                     title: const Text("End Time"),
//                     subtitle: Text(
//                       endTime == null
//                           ? "Select"
//                           : DateFormat.yMd().add_jm().format(endTime!),
//                     ),
//                     onTap: pickEnd,
//                   ),

//                   const SizedBox(height: 20),

//                   SwitchListTile(
//                     title: const Text("Autoplay"),
//                     value: autoplay,
//                     onChanged: (v) => setState(() => autoplay = v),
//                   ),

//                   SwitchListTile(
//                     title: const Text("Mute"),
//                     value: mute,
//                     onChanged: (v) => setState(() => mute = v),
//                   ),

//                   SwitchListTile(
//                     title: const Text("Loop"),
//                     value: loop,
//                     onChanged: (v) => setState(() => loop = v),
//                   ),

//                   const SizedBox(height: 20),

//                   previewCard(),

//                   const SizedBox(height: 20),

//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: loading ? null : submit,
//                       child: loading
//                           ? const SizedBox(
//                               height: 22,
//                               width: 22,
//                               child: CircularProgressIndicator(color: Colors.white),
//                             )
//                           : Text(
//                               isEdit
//                                   ? "Update Live Content"
//                                   : "Create Live Content",
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATED UI>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/live_content_provider.dart';
import '../../providers/channel_provider.dart';
import 'package:cms_app/theme/app_colors.dart';

class CreateLiveContentPage extends StatefulWidget {
  final String? id;

  const CreateLiveContentPage({super.key, this.id});

  @override
  State<CreateLiveContentPage> createState() => _CreateLiveContentPageState();
}

class _CreateLiveContentPageState extends State<CreateLiveContentPage> {
  final nameController = TextEditingController();
  final urlController = TextEditingController();
  final durationController = TextEditingController();

  String contentType = "streaming";
  String status = "active";

  String? selectedChannelId;

  DateTime? startTime;
  DateTime? endTime;

  bool autoplay = false;
  bool mute = false;
  bool loop = false;

  bool loading = false;

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      fetchLiveContent();
    }
  }

  Future fetchLiveContent() async {
    setState(() {
      loading = true;
    });

    final provider = context.read<LiveContentProvider>();

    await provider.fetchContents();

    final item = provider.contents.firstWhere((e) => e.id == widget.id);

    nameController.text = item.name;
    urlController.text = item.url;
    durationController.text = item.duration.toString();
    contentType = item.type;
    status = item.status;

    setState(() {
      loading = false;
    });
  }

  Future pickStart() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future pickEnd() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      endTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future submit() async {
    if (nameController.text.isEmpty) return;
    if (urlController.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      print("    ddddddddddddddd ${contentType}");
      final provider = context.read<LiveContentProvider>();

      await provider.createContent(
        name: nameController.text,
        url: urlController.text,
        duration: int.tryParse(durationController.text) ?? 0,
        type: contentType,
        channelId: selectedChannelId,
        status: status,
        startTime: startTime,
        endTime: endTime,
        autoplay: autoplay,
        mute: mute,
        loop: loop,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Create error: $e");
    }

    setState(() {
      loading = false;
    });
  }

  // ─── Preview Card ──────────────────────────────────────────────────────────

  Widget previewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appColors.purpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.preview_rounded,
                  color: appColors.purple,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Preview',
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: appColors.borderLight),
          const SizedBox(height: 14),

          // Type
          _previewRow(
            icon: Icons.category_rounded,
            label: 'Type',
            value: contentType[0].toUpperCase() + contentType.substring(1),
          ),

          // URL
          if (urlController.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _previewRow(
              icon: Icons.link_rounded,
              label: 'URL',
              value: urlController.text,
            ),
          ],

          // Duration
          const SizedBox(height: 10),
          _previewRow(
            icon: Icons.timer_rounded,
            label: 'Duration',
            value:
                durationController.text == "0" ||
                    durationController.text.isEmpty
                ? 'Indefinite'
                : '${durationController.text}s',
          ),

          // Start / End
          if (startTime != null) ...[
            const SizedBox(height: 10),
            _previewRow(
              icon: Icons.play_arrow_rounded,
              label: 'Start',
              value: DateFormat.yMd().add_jm().format(startTime!),
            ),
          ],
          if (endTime != null) ...[
            const SizedBox(height: 10),
            _previewRow(
              icon: Icons.stop_rounded,
              label: 'End',
              value: DateFormat.yMd().add_jm().format(endTime!),
            ),
          ],

          // Toggles
          if (autoplay || mute || loop) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: appColors.borderLight),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (autoplay)
                  _previewChip(
                    'Autoplay',
                    Icons.play_circle_rounded,
                    appColors.green,
                    appColors.greenLight,
                  ),
                if (mute)
                  _previewChip(
                    'Mute',
                    Icons.volume_off_rounded,
                    appColors.orange,
                    appColors.orangeLight,
                  ),
                if (loop)
                  _previewChip(
                    'Loop',
                    Icons.loop_rounded,
                    appColors.teal,
                    appColors.tealLight,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _previewRow({
    required IconData icon,
    required String label,
    required String value,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: appColors.textMuted),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: TextStyle(
          color: appColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _previewChip(String label, IconData icon, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  // ─── Channel Dropdown ──────────────────────────────────────────────────────

  Widget channelDropdown() {
    return Consumer<ChannelProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: appColors.accent,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          );
        }

        return _styledDropdown<String>(
          value: selectedChannelId,
          hint: 'Select Channel',
          icon: Icons.tv_rounded,
          items: provider.channels.map((channel) {
            return DropdownMenuItem(
              value: channel.channelId,
              child: Text(channel.name),
            );
          }).toList(),
          onChanged: (value) {
            final selected = provider.channels.firstWhere(
              (c) => c.channelId == value,
            );
            setState(() {
              selectedChannelId = value;
              urlController.text = selected.playbackUrl;
            });
          },
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

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
        title: Text(
          isEdit ? 'Edit Live Content' : 'Create Live Content',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: appColors.border),
        ),
      ),
      body: loading
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
                    isEdit ? 'Loading content…' : 'Creating content…',
                    style: TextStyle(color: appColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero banner ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appColors.accent, const Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.accent.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_rounded : Icons.live_tv_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Edit Live Content' : 'New Live Content',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEdit
                                  ? 'Update your live content settings'
                                  : 'Configure streaming or web content',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Basic Information ────────────────────────────────
                  _sectionLabel(
                    'Basic Information',
                    Icons.info_outline_rounded,
                    appColors.accent,
                    appColors.accentLight,
                  ),
                  const SizedBox(height: 12),

                  // Content Name
                  _fieldLabel('Content Name'),
                  const SizedBox(height: 6),
                  _styledTextField(
                    controller: nameController,
                    hint: 'Enter content name',
                    icon: Icons.label_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Content Type
                  _fieldLabel('Content Type'),
                  const SizedBox(height: 6),
                  _styledDropdown<String>(
                    value: contentType,
                    hint: 'Select content type',
                    icon: Icons.category_rounded,
                    items: const [
                      DropdownMenuItem(
                        value: "streaming",
                        child: Text("Streaming"),
                      ),
                      DropdownMenuItem(
                        value: "website",
                        child: Text("Website"),
                      ),
                      DropdownMenuItem(value: "iframe", child: Text("iFrame")),
                      DropdownMenuItem(
                        value: "youtube",
                        child: Text("YouTube"),
                      ),
                      DropdownMenuItem(value: "custom", child: Text("Custom")),
                      DropdownMenuItem(
                        value: "provider",
                        child: Text("Dacast Provider"),
                      ),
                    ],
                    onChanged: (v) async {
                      setState(() {
                        contentType = v.toString();
                      });
                      if (contentType == "provider") {
                        final channelProvider = context.read<ChannelProvider>();
                        if (channelProvider.channels.isEmpty) {
                          await channelProvider.fetchChannels();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // URL / Channel
                  if (contentType != "provider") ...[
                    _fieldLabel('Content URL'),
                    const SizedBox(height: 6),
                    _styledTextField(
                      controller: urlController,
                      hint: 'Enter content URL',
                      icon: Icons.link_rounded,
                      onChanged: (_) => setState(() {}),
                    ),
                  ] else ...[
                    _fieldLabel('Select Channel'),
                    const SizedBox(height: 6),
                    channelDropdown(),
                  ],
                  const SizedBox(height: 16),

                  // Duration
                  _fieldLabel('Duration (seconds)'),
                  const SizedBox(height: 6),
                  _styledTextField(
                    controller: durationController,
                    hint: 'Enter duration in seconds',
                    icon: Icons.timer_rounded,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // ── Schedule ─────────────────────────────────────────
                  _sectionLabel(
                    'Schedule',
                    Icons.schedule_rounded,
                    appColors.teal,
                    appColors.tealLight,
                  ),
                  const SizedBox(height: 12),

                  // Start Time
                  _timeTile(
                    icon: Icons.play_arrow_rounded,
                    iconColor: appColors.green,
                    iconBg: appColors.greenLight,
                    label: 'Start Time',
                    value: startTime == null
                        ? 'Tap to select'
                        : DateFormat.yMd().add_jm().format(startTime!),
                    hasValue: startTime != null,
                    onTap: pickStart,
                  ),
                  const SizedBox(height: 10),
                  _timeTile(
                    icon: Icons.stop_rounded,
                    iconColor: appColors.red,
                    iconBg: appColors.redLight,
                    label: 'End Time',
                    value: endTime == null
                        ? 'Tap to select'
                        : DateFormat.yMd().add_jm().format(endTime!),
                    hasValue: endTime != null,
                    onTap: pickEnd,
                  ),
                  const SizedBox(height: 24),

                  // ── Playback Options ─────────────────────────────────
                  _sectionLabel(
                    'Playback Options',
                    Icons.tune_rounded,
                    appColors.purple,
                    appColors.purpleLight,
                  ),
                  const SizedBox(height: 12),

                  Container(
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
                    child: Column(
                      children: [
                        _toggleRow(
                          icon: Icons.play_circle_rounded,
                          iconColor: appColors.green,
                          iconBg: appColors.greenLight,
                          label: 'Autoplay',
                          subtitle: 'Start playing automatically',
                          value: autoplay,
                          onChanged: (v) => setState(() => autoplay = v),
                          isFirst: true,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: appColors.borderLight,
                          indent: 16,
                        ),
                        _toggleRow(
                          icon: Icons.volume_off_rounded,
                          iconColor: appColors.orange,
                          iconBg: appColors.orangeLight,
                          label: 'Mute',
                          subtitle: 'Silence audio output',
                          value: mute,
                          onChanged: (v) => setState(() => mute = v),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: appColors.borderLight,
                          indent: 16,
                        ),
                        _toggleRow(
                          icon: Icons.loop_rounded,
                          iconColor: appColors.teal,
                          iconBg: appColors.tealLight,
                          label: 'Loop',
                          subtitle: 'Repeat content continuously',
                          value: loop,
                          onChanged: (v) => setState(() => loop = v),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Preview ──────────────────────────────────────────
                  _sectionLabel(
                    'Preview',
                    Icons.preview_rounded,
                    appColors.purple,
                    appColors.purpleLight,
                  ),
                  const SizedBox(height: 12),
                  previewCard(),
                  const SizedBox(height: 24),

                  // ── Submit ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: loading ? null : submit,
                      icon: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isEdit
                                  ? Icons.save_rounded
                                  : Icons.live_tv_rounded,
                              size: 18,
                            ),
                      label: Text(
                        isEdit ? 'Update Live Content' : 'Create Live Content',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: appColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: appColors.accent.withOpacity(
                          0.6,
                        ),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ─── Shared UI helpers ────────────────────────────────────────────────────

  Widget _sectionLabel(String text, IconData icon, Color color, Color bg) =>
      Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      );

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      color: appColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) => Container(
    decoration: BoxDecoration(
      color: appColors.surface,
      borderRadius: BorderRadius.circular(14),
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
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: appColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: appColors.textMuted, size: 17),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    ),
  );

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) => Container(
    decoration: BoxDecoration(
      color: appColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: appColors.border),
      boxShadow: [
        BoxShadow(
          color: appColors.shadow,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: DropdownButtonFormField<T>(
      value: value,
      dropdownColor: appColors.surface,
      style: TextStyle(color: appColors.textPrimary, fontSize: 13),
      hint: Text(
        hint,
        style: TextStyle(color: appColors.textMuted, fontSize: 13),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: appColors.textMuted, size: 17),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      items: items,
      onChanged: onChanged,
    ),
  );

  Widget _timeTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required bool hasValue,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasValue ? iconColor.withOpacity(0.4) : appColors.border,
          width: hasValue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: appColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: hasValue
                        ? appColors.textPrimary
                        : appColors.textMuted,
                    fontSize: 13,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: appColors.textMuted,
            size: 18,
          ),
        ],
      ),
    ),
  );

  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) => Padding(
    padding: EdgeInsets.only(top: isFirst ? 4 : 0, bottom: isLast ? 4 : 0),
    child: SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 17),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: appColors.textMuted, fontSize: 11),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: iconColor,
      activeTrackColor: iconColor.withOpacity(0.2),
      inactiveThumbColor: appColors.textMuted,
      inactiveTrackColor: appColors.borderLight,
    ),
  );
}
