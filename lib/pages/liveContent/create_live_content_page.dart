import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/live_content_provider.dart';
import '../../providers/channel_provider.dart';

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
      startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
      endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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

  Widget previewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("Type: $contentType"),

            if (urlController.text.isNotEmpty)
              Text("URL: ${urlController.text}"),

            const SizedBox(height: 10),

            Text(
              "Duration: ${durationController.text == "0" ? "Indefinite" : "${durationController.text}s"}",
            ),

            const SizedBox(height: 10),

            if (startTime != null)
              Text("Start: ${DateFormat.yMd().add_jm().format(startTime!)}"),

            if (endTime != null)
              Text("End: ${DateFormat.yMd().add_jm().format(endTime!)}"),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: [
                if (autoplay) const Chip(label: Text("Autoplay")),
                if (mute) const Chip(label: Text("Mute")),
                if (loop) const Chip(label: Text("Loop")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget channelDropdown() {
    return Consumer<ChannelProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownButtonFormField<String>(
          value: selectedChannelId,
          decoration: const InputDecoration(
            labelText: "Select Channel",
            border: OutlineInputBorder(),
          ),
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Live Content" : "Create Live Content"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Basic Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Content Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField(
                    value: contentType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Content Type",
                    ),
                    items: const [
                      DropdownMenuItem(value: "streaming", child: Text("Streaming")),
                      DropdownMenuItem(value: "website", child: Text("Website")),
                      DropdownMenuItem(value: "iframe", child: Text("iFrame")),
                      DropdownMenuItem(value: "youtube", child: Text("YouTube")),
                      DropdownMenuItem(value: "custom", child: Text("Custom")),
                      DropdownMenuItem(value: "provider", child: Text("Dacast Provider")),
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

                  const SizedBox(height: 20),

                  if (contentType != "provider")
                    TextField(
                      controller: urlController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: "Content URL",
                        border: OutlineInputBorder(),
                      ),
                    ),

                  if (contentType == "provider") channelDropdown(),

                  const SizedBox(height: 20),

                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: "Duration (seconds)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    title: const Text("Start Time"),
                    subtitle: Text(
                      startTime == null
                          ? "Select"
                          : DateFormat.yMd().add_jm().format(startTime!),
                    ),
                    onTap: pickStart,
                  ),

                  ListTile(
                    title: const Text("End Time"),
                    subtitle: Text(
                      endTime == null
                          ? "Select"
                          : DateFormat.yMd().add_jm().format(endTime!),
                    ),
                    onTap: pickEnd,
                  ),

                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: const Text("Autoplay"),
                    value: autoplay,
                    onChanged: (v) => setState(() => autoplay = v),
                  ),

                  SwitchListTile(
                    title: const Text("Mute"),
                    value: mute,
                    onChanged: (v) => setState(() => mute = v),
                  ),

                  SwitchListTile(
                    title: const Text("Loop"),
                    value: loop,
                    onChanged: (v) => setState(() => loop = v),
                  ),

                  const SizedBox(height: 20),

                  previewCard(),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : Text(
                              isEdit
                                  ? "Update Live Content"
                                  : "Create Live Content",
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}