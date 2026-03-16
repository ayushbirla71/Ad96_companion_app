import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/live_content_provider.dart';
import '../../providers/carousel_provider.dart';

enum ScheduleType { single, multiple }

enum ContentType { live, ad, carousel }

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  ContentType selectedContentType = ContentType.live;
  String? selectedItemId;

  final Set<String> selectedGroupIds = {};

  String itemSearch = "";
  String groupSearch = "";

  ScheduleType scheduleType = ScheduleType.single;

  late String singleDate;
  late String fromDate;
  late String toDate;

  bool _buttonLoading = false;

  bool showAdvancedScheduling = false;

  List<int> selectedWeekdays = [1, 2, 3, 4, 5];

  List<Map<String, String>> timeSlots = [
    {"start": "06:00", "end": "10:00"},
    {"start": "18:00", "end": "22:00"},
  ];

  String getContentTypeValue() {
    switch (selectedContentType) {
      case ContentType.live:
        return "live_content";
      case ContentType.ad:
        return "ad";
      case ContentType.carousel:
        return "carousel";
    }
  }

  final List<String> weekdayNames = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];

  @override
  void initState() {
    super.initState();

    final today = _fmt(DateTime.now());

    singleDate = today;
    fromDate = today;
    toDate = today;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdProvider>().loadAds();
      context.read<GroupProvider>().loadGroups();
      context.read<LiveContentProvider>().loadLiveContents();
      context.read<CarouselProvider>().loadCarousels();
    });
  }

  String _fmt(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Future<String?> _pickDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (d == null) return null;

    return _fmt(d);
  }

  /// FORMAT TIME FOR UI (AM/PM)
  String formatTimeDisplay(String time24) {
    final parts = time24.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final period = hour >= 12 ? "PM" : "AM";

    hour = hour % 12;
    if (hour == 0) hour = 12;

    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');

    return "$h:$m $period";
  }

  /// TIME PICKER
  Future<String?> _pickTime(String initial) async {
    final parts = initial.split(":");

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );

    if (picked == null) return null;

    final h = picked.hour.toString().padLeft(2, '0');
    final m = picked.minute.toString().padLeft(2, '0');

    return "$h:$m";
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<AdProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final liveProvider = context.watch<LiveContentProvider>();
    final carouselProvider = context.watch<CarouselProvider>();

    List<dynamic> items = [];
    bool loading = false;
    String emptyText = "";

    switch (selectedContentType) {
      case ContentType.live:
        items = liveProvider.liveContents
            .where(
              (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
            )
            .toList();
        loading = liveProvider.loading;
        emptyText = "No live content found";
        break;

      case ContentType.ad:
        items = adProvider.ads
            .where(
              (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
            )
            .toList();
        loading = adProvider.loading;
        emptyText = "No ads found";
        break;

      case ContentType.carousel:
        items = carouselProvider.carousels
            .where(
              (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
            )
            .toList();
        loading = carouselProvider.loading;
        emptyText = "No carousels found";
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Create Schedule")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CONTENT TYPE
            _cardSection(
              "Content Type",
              DropdownButtonFormField<ContentType>(
                value: selectedContentType,
                decoration: const InputDecoration(border: OutlineInputBorder()),

                items: const [
                  DropdownMenuItem(
                    value: ContentType.live,
                    child: Text("Live Content"),
                  ),
                  DropdownMenuItem(value: ContentType.ad, child: Text("Ads")),
                  DropdownMenuItem(
                    value: ContentType.carousel,
                    child: Text("Carousel"),
                  ),
                ],

                onChanged: (v) {
                  setState(() {
                    selectedContentType = v!;
                    selectedItemId = null;
                    itemSearch = "";
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            /// SELECT ITEM
            _cardSection(
              "Select Item",
              Column(
                children: [
                  _searchBox(
                    hint: "Search item...",
                    onChanged: (v) {
                      setState(() => itemSearch = v);
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 200,
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                        ? Center(child: Text(emptyText))
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (_, i) {
                              final e = items[i];

                              return RadioListTile<String>(
                                value: e.id,
                                groupValue: selectedItemId,
                                title: Text(e.name),
                                onChanged: (v) {
                                  setState(() => selectedItemId = v);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// DEVICE GROUPS
            _cardSection(
              "Device Groups",
              Column(
                children: [
                  _searchBox(
                    hint: "Search groups...",
                    onChanged: (v) {
                      setState(() => groupSearch = v);
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 200,
                    child: groupProvider.loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            children: groupProvider.groups
                                .where(
                                  (g) => g.name.toLowerCase().contains(
                                    groupSearch.toLowerCase(),
                                  ),
                                )
                                .map((g) {
                                  return CheckboxListTile(
                                    value: selectedGroupIds.contains(g.id),
                                    title: Text(g.name),
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          selectedGroupIds.add(g.id);
                                        } else {
                                          selectedGroupIds.remove(g.id);
                                        }
                                      });
                                    },
                                  );
                                })
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// SCHEDULE DURATION
            _cardSection(
              "Schedule Duration",
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Single Day"),
                          value: ScheduleType.single,
                          groupValue: scheduleType,
                          onChanged: (v) {
                            setState(() => scheduleType = v!);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Multiple Days"),
                          value: ScheduleType.multiple,
                          groupValue: scheduleType,
                          onChanged: (v) {
                            setState(() => scheduleType = v!);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// SINGLE DATE
                  if (scheduleType == ScheduleType.single)
                    _dateButton("Date: $singleDate", () async {
                      final d = await _pickDate(context);
                      if (d != null) {
                        setState(() => singleDate = d);
                      }
                    }),

                  /// MULTIPLE DATE
                  if (scheduleType == ScheduleType.multiple)
                    Row(
                      children: [
                        Expanded(
                          child: _dateButton("From: $fromDate", () async {
                            final d = await _pickDate(context);
                            if (d != null) {
                              setState(() => fromDate = d);
                            }
                          }),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _dateButton("To: $toDate", () async {
                            final d = await _pickDate(context);
                            if (d != null) {
                              setState(() => toDate = d);
                            }
                          }),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ADVANCED
            _cardSection(
              "Advanced Scheduling",
              Column(
                children: [
                  SwitchListTile(
                    title: const Text("Enable Advanced Scheduling"),
                    value: showAdvancedScheduling,
                    onChanged: (v) {
                      setState(() => showAdvancedScheduling = v);
                    },
                  ),

                  if (showAdvancedScheduling) ...[
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final selected = selectedWeekdays.contains(index);

                        return ChoiceChip(
                          label: Text(weekdayNames[index]),
                          selected: selected,

                          onSelected: (_) {
                            setState(() {
                              if (selected) {
                                selectedWeekdays.remove(index);
                              } else {
                                selectedWeekdays.add(index);
                              }
                            });
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 15),

                    Column(
                      children: List.generate(timeSlots.length, (i) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),

                            child: Row(
                              children: [
                                /// START
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final t = await _pickTime(
                                        timeSlots[i]["start"]!,
                                      );

                                      if (t != null) {
                                        setState(() {
                                          timeSlots[i]["start"] = t;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: "Start",
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.access_time),
                                      ),
                                      child: Text(
                                        formatTimeDisplay(
                                          timeSlots[i]["start"]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// END
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final t = await _pickTime(
                                        timeSlots[i]["end"]!,
                                      );

                                      if (t != null) {
                                        setState(() {
                                          timeSlots[i]["end"] = t;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: "End",
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.access_time),
                                      ),
                                      child: Text(
                                        formatTimeDisplay(timeSlots[i]["end"]!),
                                      ),
                                    ),
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (timeSlots.length > 1) {
                                        timeSlots.removeAt(i);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Time Slot"),
                      onPressed: () {
                        setState(() {
                          timeSlots.add({"start": "09:00", "end": "17:00"});
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: _buttonLoading ? null : _submit,

                child: _buttonLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Create Schedule",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardSection(String title, Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _searchBox({
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _dateButton(String text, VoidCallback onTap) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text(text),
      onPressed: onTap,
    );
  }

  void _submit() async {
    if (selectedItemId == null) return _err("Select an item");

    if (selectedGroupIds.isEmpty) return _err("Select at least one group");

    if (scheduleType == ScheduleType.multiple &&
        fromDate.compareTo(toDate) > 0) {
      return _err("Invalid date range");
    }

    setState(() => _buttonLoading = true);

    final payload = {
      "content_type": getContentTypeValue(),

      "groups": selectedGroupIds.toList(),

      "start_time": toISODate(
        scheduleType == ScheduleType.single ? singleDate : fromDate,
      ),

      "end_time": toISODate(
        scheduleType == ScheduleType.single ? singleDate : toDate,
      ),

      "total_duration": "360",
      "priority": 1,

      "weekdays": showAdvancedScheduling
          ? selectedWeekdays
          : [0, 1, 2, 3, 4, 5, 6],

      "time_slots": showAdvancedScheduling
          ? timeSlots
          : [
              {"start": "00:00", "end": "23:59"},
            ],
    };

    if (selectedContentType == ContentType.ad) {
      // payload["ad_id"]=selectedItemId!;
      payload["content_id"] = selectedItemId!;
    } else {
      payload["content_id"] = selectedItemId!;
    }

    try {
      final response = await ApiService.post("/schedule/add_v2", payload);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Schedule created successfully")),
        );

        Navigator.pop(context);
      } else {
        _err("Failed to create schedule");
      }
    } catch (e) {
      _err("Something went wrong");
    }

    setState(() => _buttonLoading = false);
  }

  String toISODate(String date) {
    return "${date}T00:00:00.000Z";
  }
}
