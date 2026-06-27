// // import 'package:cms_app/services/api_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../providers/ad_provider.dart';
// // import '../../providers/group_provider.dart';
// // import '../../providers/live_content_provider.dart';
// // import '../../providers/carousel_provider.dart';

// // enum ScheduleType { single, multiple }

// // enum ContentType { live, ad, carousel }

// // class CreateSchedulePage extends StatefulWidget {
// //   const CreateSchedulePage({super.key});

// //   @override
// //   State<CreateSchedulePage> createState() => _CreateSchedulePageState();
// // }

// // class _CreateSchedulePageState extends State<CreateSchedulePage> {
// //   ContentType selectedContentType = ContentType.live;
// //   String? selectedItemId;

// //   final Set<String> selectedGroupIds = {};

// //   String itemSearch = "";
// //   String groupSearch = "";

// //   ScheduleType scheduleType = ScheduleType.single;

// //   late String singleDate;
// //   late String fromDate;
// //   late String toDate;

// //   bool _buttonLoading = false;

// //   bool showAdvancedScheduling = false;

// //   List<int> selectedWeekdays = [1, 2, 3, 4, 5];

// //   List<Map<String, String>> timeSlots = [
// //     {"start": "06:00", "end": "10:00"},
// //     {"start": "18:00", "end": "22:00"},
// //   ];

// //   String getContentTypeValue() {
// //     switch (selectedContentType) {
// //       case ContentType.live:
// //         return "live_content";
// //       case ContentType.ad:
// //         return "ad";
// //       case ContentType.carousel:
// //         return "carousel";
// //     }
// //   }

// //   final List<String> weekdayNames = [
// //     "Sun",
// //     "Mon",
// //     "Tue",
// //     "Wed",
// //     "Thu",
// //     "Fri",
// //     "Sat",
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();

// //     final today = _fmt(DateTime.now());

// //     singleDate = today;
// //     fromDate = today;
// //     toDate = today;

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       context.read<AdProvider>().loadAds();
// //       context.read<GroupProvider>().loadGroups();
// //       context.read<LiveContentProvider>().loadLiveContents();
// //       context.read<CarouselProvider>().loadCarousels();
// //     });
// //   }

// //   String _fmt(DateTime d) {
// //     return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
// //   }

// //   Future<String?> _pickDate(BuildContext context) async {
// //     final d = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2035),
// //     );

// //     if (d == null) return null;

// //     return _fmt(d);
// //   }

// //   /// FORMAT TIME FOR UI (AM/PM)
// //   String formatTimeDisplay(String time24) {
// //     final parts = time24.split(":");
// //     int hour = int.parse(parts[0]);
// //     int minute = int.parse(parts[1]);

// //     final period = hour >= 12 ? "PM" : "AM";

// //     hour = hour % 12;
// //     if (hour == 0) hour = 12;

// //     final h = hour.toString().padLeft(2, '0');
// //     final m = minute.toString().padLeft(2, '0');

// //     return "$h:$m $period";
// //   }

// //   /// TIME PICKER
// //   Future<String?> _pickTime(String initial) async {
// //     final parts = initial.split(":");

// //     final picked = await showTimePicker(
// //       context: context,
// //       initialTime: TimeOfDay(
// //         hour: int.parse(parts[0]),
// //         minute: int.parse(parts[1]),
// //       ),
// //     );

// //     if (picked == null) return null;

// //     final h = picked.hour.toString().padLeft(2, '0');
// //     final m = picked.minute.toString().padLeft(2, '0');

// //     return "$h:$m";
// //   }

// //   void _err(String msg) {
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final adProvider = context.watch<AdProvider>();
// //     final groupProvider = context.watch<GroupProvider>();
// //     final liveProvider = context.watch<LiveContentProvider>();
// //     final carouselProvider = context.watch<CarouselProvider>();

// //     List<dynamic> items = [];
// //     bool loading = false;
// //     String emptyText = "";

// //     switch (selectedContentType) {
// //       case ContentType.live:
// //         items = liveProvider.liveContents
// //             .where(
// //               (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
// //             )
// //             .toList();
// //         loading = liveProvider.loading;
// //         emptyText = "No live content found";
// //         break;

// //       case ContentType.ad:
// //         items = adProvider.ads
// //             .where(
// //               (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
// //             )
// //             .toList();
// //         loading = adProvider.loading;
// //         emptyText = "No ads found";
// //         break;

// //       case ContentType.carousel:
// //         items = carouselProvider.carousels
// //             .where(
// //               (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
// //             )
// //             .toList();
// //         loading = carouselProvider.loading;
// //         emptyText = "No carousels found";
// //         break;
// //     }

// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Create Schedule")),

// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),

// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             /// CONTENT TYPE
// //             _cardSection(
// //               "Content Type",
// //               DropdownButtonFormField<ContentType>(
// //                 value: selectedContentType,
// //                 decoration: const InputDecoration(border: OutlineInputBorder()),

// //                 items: const [
// //                   DropdownMenuItem(
// //                     value: ContentType.live,
// //                     child: Text("Live Content"),
// //                   ),
// //                   DropdownMenuItem(value: ContentType.ad, child: Text("Ads")),
// //                   DropdownMenuItem(
// //                     value: ContentType.carousel,
// //                     child: Text("Carousel"),
// //                   ),
// //                 ],

// //                 onChanged: (v) {
// //                   setState(() {
// //                     selectedContentType = v!;
// //                     selectedItemId = null;
// //                     itemSearch = "";
// //                   });
// //                 },
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             /// SELECT ITEM
// //             _cardSection(
// //               "Select Item",
// //               Column(
// //                 children: [
// //                   _searchBox(
// //                     hint: "Search item...",
// //                     onChanged: (v) {
// //                       setState(() => itemSearch = v);
// //                     },
// //                   ),

// //                   const SizedBox(height: 10),

// //                   SizedBox(
// //                     height: 200,
// //                     child: loading
// //                         ? const Center(child: CircularProgressIndicator())
// //                         : items.isEmpty
// //                         ? Center(child: Text(emptyText))
// //                         : ListView.builder(
// //                             itemCount: items.length,
// //                             itemBuilder: (_, i) {
// //                               final e = items[i];

// //                               return RadioListTile<String>(
// //                                 value: e.id,
// //                                 groupValue: selectedItemId,
// //                                 title: Text(e.name),
// //                                 onChanged: (v) {
// //                                   setState(() => selectedItemId = v);
// //                                 },
// //                               );
// //                             },
// //                           ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             /// DEVICE GROUPS
// //             _cardSection(
// //               "Device Groups",
// //               Column(
// //                 children: [
// //                   _searchBox(
// //                     hint: "Search groups...",
// //                     onChanged: (v) {
// //                       setState(() => groupSearch = v);
// //                     },
// //                   ),

// //                   const SizedBox(height: 10),

// //                   SizedBox(
// //                     height: 200,
// //                     child: groupProvider.loading
// //                         ? const Center(child: CircularProgressIndicator())
// //                         : ListView(
// //                             children: groupProvider.groups
// //                                 .where(
// //                                   (g) => g.name.toLowerCase().contains(
// //                                     groupSearch.toLowerCase(),
// //                                   ),
// //                                 )
// //                                 .map((g) {
// //                                   return CheckboxListTile(
// //                                     value: selectedGroupIds.contains(g.id),
// //                                     title: Text(g.name),
// //                                     onChanged: (v) {
// //                                       setState(() {
// //                                         if (v == true) {
// //                                           selectedGroupIds.add(g.id);
// //                                         } else {
// //                                           selectedGroupIds.remove(g.id);
// //                                         }
// //                                       });
// //                                     },
// //                                   );
// //                                 })
// //                                 .toList(),
// //                           ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             // const SizedBox(height: 16),

// //             // /// SCHEDULE DURATION
// //             // _cardSection(
// //             //   "Schedule Duration",
// //             //   Column(
// //             //     children: [
// //             //       Row(
// //             //         children: [
// //             //           Expanded(
// //             //             child: RadioListTile(
// //             //               title: const Text("Single Day"),
// //             //               value: ScheduleType.single,
// //             //               groupValue: scheduleType,
// //             //               onChanged: (v) {
// //             //                 setState(() => scheduleType = v!);
// //             //               },
// //             //             ),
// //             //           ),
// //             //           Expanded(
// //             //             child: RadioListTile(
// //             //               title: const Text("Multiple Days"),
// //             //               value: ScheduleType.multiple,
// //             //               groupValue: scheduleType,
// //             //               onChanged: (v) {
// //             //                 setState(() => scheduleType = v!);
// //             //               },
// //             //             ),
// //             //           ),
// //             //         ],
// //             //       ),

// //             //       const SizedBox(height: 10),

// //             //       /// SINGLE DATE
// //             //       if (scheduleType == ScheduleType.single)
// //             //         _dateButton("Date: $singleDate", () async {
// //             //           final d = await _pickDate(context);
// //             //           if (d != null) {
// //             //             setState(() => singleDate = d);
// //             //           }
// //             //         }),

// //             //       /// MULTIPLE DATE
// //             //       if (scheduleType == ScheduleType.multiple)
// //             //         Row(
// //             //           children: [
// //             //             Expanded(
// //             //               child: _dateButton("From: $fromDate", () async {
// //             //                 final d = await _pickDate(context);
// //             //                 if (d != null) {
// //             //                   setState(() => fromDate = d);
// //             //                 }
// //             //               }),
// //             //             ),

// //             //             const SizedBox(width: 10),

// //             //             Expanded(
// //             //               child: _dateButton("To: $toDate", () async {
// //             //                 final d = await _pickDate(context);
// //             //                 if (d != null) {
// //             //                   setState(() => toDate = d);
// //             //                 }
// //             //               }),
// //             //             ),
// //             //           ],
// //             //         ),
// //             //     ],
// //             //   ),
// //             // ),

// //             // const SizedBox(height: 16),
// //             const SizedBox(height: 16),

// //             /// SCHEDULE DURATION
// //             _cardSection(
// //               "Schedule Duration",
// //               Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: RadioListTile<ScheduleType>(
// //                           title: const Text(
// //                             "Single Day",
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                           value: ScheduleType.single,
// //                           groupValue: scheduleType,
// //                           dense: true,
// //                           visualDensity: VisualDensity.compact,
// //                           contentPadding: EdgeInsets.zero,
// //                           onChanged: (v) {
// //                             setState(() => scheduleType = v!);
// //                           },
// //                         ),
// //                       ),

// //                       Expanded(
// //                         child: RadioListTile<ScheduleType>(
// //                           title: const Text(
// //                             "Multiple Days",
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                           value: ScheduleType.multiple,
// //                           groupValue: scheduleType,
// //                           dense: true,
// //                           visualDensity: VisualDensity.compact,
// //                           contentPadding: EdgeInsets.zero,
// //                           onChanged: (v) {
// //                             setState(() => scheduleType = v!);
// //                           },
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 10),

// //                   /// SINGLE DATE
// //                   if (scheduleType == ScheduleType.single)
// //                     _dateButton("Date: $singleDate", () async {
// //                       final d = await _pickDate(context);
// //                       if (d != null) {
// //                         setState(() => singleDate = d);
// //                       }
// //                     }),

// //                   /// MULTIPLE DATE
// //                   if (scheduleType == ScheduleType.multiple)
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: _dateButton("From: $fromDate", () async {
// //                             final d = await _pickDate(context);
// //                             if (d != null) {
// //                               setState(() => fromDate = d);
// //                             }
// //                           }),
// //                         ),

// //                         const SizedBox(width: 10),

// //                         Expanded(
// //                           child: _dateButton("To: $toDate", () async {
// //                             final d = await _pickDate(context);
// //                             if (d != null) {
// //                               setState(() => toDate = d);
// //                             }
// //                           }),
// //                         ),
// //                       ],
// //                     ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             /// ADVANCED
// //             _cardSection(
// //               "Advanced Scheduling",
// //               Column(
// //                 children: [
// //                   SwitchListTile(
// //                     title: const Text("Enable Advanced Scheduling"),
// //                     value: showAdvancedScheduling,
// //                     onChanged: (v) {
// //                       setState(() => showAdvancedScheduling = v);
// //                     },
// //                   ),

// //                   if (showAdvancedScheduling) ...[
// //                     const SizedBox(height: 10),

// //                     Wrap(
// //                       spacing: 8,
// //                       children: List.generate(7, (index) {
// //                         final selected = selectedWeekdays.contains(index);

// //                         return ChoiceChip(
// //                           label: Text(weekdayNames[index]),
// //                           selected: selected,

// //                           onSelected: (_) {
// //                             setState(() {
// //                               if (selected) {
// //                                 selectedWeekdays.remove(index);
// //                               } else {
// //                                 selectedWeekdays.add(index);
// //                               }
// //                             });
// //                           },
// //                         );
// //                       }),
// //                     ),

// //                     const SizedBox(height: 15),

// //                     Column(
// //                       children: List.generate(timeSlots.length, (i) {
// //                         return Card(
// //                           margin: const EdgeInsets.only(bottom: 10),
// //                           child: Padding(
// //                             padding: const EdgeInsets.all(12),

// //                             child: Row(
// //                               children: [
// //                                 /// START
// //                                 Expanded(
// //                                   child: InkWell(
// //                                     onTap: () async {
// //                                       final t = await _pickTime(
// //                                         timeSlots[i]["start"]!,
// //                                       );

// //                                       if (t != null) {
// //                                         setState(() {
// //                                           timeSlots[i]["start"] = t;
// //                                         });
// //                                       }
// //                                     },
// //                                     child: InputDecorator(
// //                                       decoration: const InputDecoration(
// //                                         labelText: "Start",
// //                                         border: OutlineInputBorder(),
// //                                         prefixIcon: Icon(Icons.access_time),
// //                                       ),
// //                                       // child: Text(
// //                                       //   formatTimeDisplay(
// //                                       //     timeSlots[i]["start"]!,
// //                                       //   ),
// //                                       // ),
// //                                       child: FittedBox(
// //                                         fit: BoxFit.scaleDown,
// //                                         alignment: Alignment.centerLeft,
// //                                         child: Text(
// //                                           formatTimeDisplay(
// //                                             timeSlots[i]["start"]!,
// //                                           ),
// //                                           style: const TextStyle(fontSize: 16),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),

// //                                 const SizedBox(width: 10),

// //                                 /// END
// //                                 Expanded(
// //                                   child: InkWell(
// //                                     onTap: () async {
// //                                       final t = await _pickTime(
// //                                         timeSlots[i]["end"]!,
// //                                       );

// //                                       if (t != null) {
// //                                         setState(() {
// //                                           timeSlots[i]["end"] = t;
// //                                         });
// //                                       }
// //                                     },
// //                                     child: InputDecorator(
// //                                       decoration: const InputDecoration(
// //                                         labelText: "End",
// //                                         border: OutlineInputBorder(),
// //                                         prefixIcon: Icon(Icons.access_time),
// //                                       ),
// //                                       // child: Text(
// //                                       //   formatTimeDisplay(timeSlots[i]["end"]!),
// //                                       // ),
// //                                       child: FittedBox(
// //                                         fit: BoxFit.scaleDown,
// //                                         alignment: Alignment.centerLeft,
// //                                         child: Text(
// //                                           formatTimeDisplay(
// //                                             timeSlots[i]["end"]!,
// //                                           ),
// //                                           style: const TextStyle(fontSize: 16),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),

// //                                 IconButton(
// //                                   icon: const Icon(
// //                                     Icons.delete,
// //                                     color: Colors.red,
// //                                   ),
// //                                   onPressed: () {
// //                                     setState(() {
// //                                       if (timeSlots.length > 1) {
// //                                         timeSlots.removeAt(i);
// //                                       }
// //                                     });
// //                                   },
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       }),
// //                     ),

// //                     const SizedBox(height: 10),

// //                     ElevatedButton.icon(
// //                       icon: const Icon(Icons.add),
// //                       label: const Text("Add Time Slot"),
// //                       onPressed: () {
// //                         setState(() {
// //                           timeSlots.add({"start": "09:00", "end": "17:00"});
// //                         });
// //                       },
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 20),

// //             /// SUBMIT BUTTON
// //             SizedBox(
// //               width: double.infinity,
// //               height: 50,

// //               child: ElevatedButton(
// //                 onPressed: _buttonLoading ? null : _submit,

// //                 child: _buttonLoading
// //                     ? const SizedBox(
// //                         height: 20,
// //                         width: 20,
// //                         child: CircularProgressIndicator(
// //                           strokeWidth: 2,
// //                           color: Colors.white,
// //                         ),
// //                       )
// //                     : const Text(
// //                         "Create Schedule",
// //                         style: TextStyle(fontSize: 16),
// //                       ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _cardSection(String title, Widget child) {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               title,
// //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 12),
// //             child,
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _searchBox({
// //     required String hint,
// //     required ValueChanged<String> onChanged,
// //   }) {
// //     return TextField(
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         prefixIcon: const Icon(Icons.search),
// //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// //       ),
// //       onChanged: onChanged,
// //     );
// //   }

// //   // Widget _dateButton(String text, VoidCallback onTap) {
// //   //   return OutlinedButton.icon(
// //   //     icon: const Icon(Icons.date_range),
// //   //     label: Text(text),
// //   //     onPressed: onTap,
// //   //   );
// //   // }

// //   Widget _dateButton(String text, VoidCallback onTap) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(30),
// //           border: Border.all(color: Colors.grey.shade300),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(Icons.calendar_today, size: 18, color: Colors.purple),

// //             const SizedBox(width: 6),

// //             Expanded(
// //               child: FittedBox(
// //                 fit: BoxFit.scaleDown,
// //                 child: Text(
// //                   text,
// //                   style: const TextStyle(
// //                     color: Colors.purple,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void _submit() async {
// //     if (selectedItemId == null) return _err("Select an item");

// //     if (selectedGroupIds.isEmpty) return _err("Select at least one group");

// //     if (scheduleType == ScheduleType.multiple &&
// //         fromDate.compareTo(toDate) > 0) {
// //       return _err("Invalid date range");
// //     }

// //     setState(() => _buttonLoading = true);

// //     final payload = {
// //       "content_type": getContentTypeValue(),

// //       "groups": selectedGroupIds.toList(),

// //       "start_time": toISODate(
// //         scheduleType == ScheduleType.single ? singleDate : fromDate,
// //       ),

// //       "end_time": toISODate(
// //         scheduleType == ScheduleType.single ? singleDate : toDate,
// //       ),

// //       "total_duration": "360",
// //       "priority": 1,

// //       "weekdays": showAdvancedScheduling
// //           ? selectedWeekdays
// //           : [0, 1, 2, 3, 4, 5, 6],

// //       "time_slots": showAdvancedScheduling
// //           ? timeSlots
// //           : [
// //               {"start": "00:00", "end": "23:59"},
// //             ],
// //     };

// //     if (selectedContentType == ContentType.ad) {
// //       // payload["ad_id"]=selectedItemId!;
// //       payload["content_id"] = selectedItemId!;
// //     } else {
// //       payload["content_id"] = selectedItemId!;
// //     }

// //     try {
// //       final response = await ApiService.post("/schedule/add_v2", payload);

// //       print("STATUS: ${response.statusCode}");
// //       print("BODY: ${response.body}");

// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Schedule created successfully")),
// //         );

// //         Navigator.pop(context);
// //       } else {
// //         _err("Failed to create schedule");
// //       }
// //     } catch (e) {
// //       _err("Something went wrong");
// //     }

// //     setState(() => _buttonLoading = false);
// //   }

// //   String toISODate(String date) {
// //     return "${date}T00:00:00.000Z";
// //   }
// // }

// // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NEW UPDATED UI>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// import 'package:cms_app/services/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/ad_provider.dart';
// import '../../providers/group_provider.dart';
// import '../../providers/live_content_provider.dart';
// import '../../providers/carousel_provider.dart';
// import 'package:cms_app/theme/app_colors.dart';

// // ─── Colour palette ───────────────────────────────────────────────────────────
// // const _c = _Colors();

// // class _Colors {
// //   const _Colors();
// //   Color get accent => const Color(0xFF2563EB);
// //   Color get accentLight => const Color(0xFFEFF6FF);
// //   Color get green => const Color(0xFF059669);
// //   Color get greenLight => const Color(0xFFECFDF5);
// //   Color get orange => const Color(0xFFEA580C);
// //   Color get orangeLight => const Color(0xFFFFF7ED);
// //   Color get yellow => const Color(0xFFD97706);
// //   Color get yellowLight => const Color(0xFFFFFBEB);
// //   Color get purple => const Color(0xFF7C3AED);
// //   Color get purpleLight => const Color(0xFFF5F3FF);
// //   Color get red => const Color(0xFFDC2626);
// //   Color get redLight => const Color(0xFFFEF2F2);
// //   Color get teal => const Color(0xFF0891B2);
// //   Color get tealLight => const Color(0xFFECFEFF);
// //   Color get bg => const Color(0xFFF1F5F9);
// //   Color get surface => const Color(0xFFFFFFFF);
// //   Color get surfaceHigh => const Color(0xFFF8FAFC);
// //   Color get textPrimary => const Color(0xFF0F172A);
// //   Color get textSecondary => const Color(0xFF475569);
// //   Color get textMuted => const Color(0xFF94A3B8);
// //   Color get border => const Color(0xFFE2E8F0);
// //   Color get borderLight => const Color(0xFFF1F5F9);
// //   Color get shadow => const Color(0x08000000);
// // }

// enum ScheduleType { single, multiple }

// enum ContentType { live, ad, carousel }

// class CreateSchedulePage extends StatefulWidget {
//   const CreateSchedulePage({super.key});

//   @override
//   State<CreateSchedulePage> createState() => _CreateSchedulePageState();
// }

// class _CreateSchedulePageState extends State<CreateSchedulePage> {
//   ContentType selectedContentType = ContentType.live;
//   String? selectedItemId;

//   final Set<String> selectedGroupIds = {};

//   String itemSearch = '';
//   String groupSearch = '';

//   ScheduleType scheduleType = ScheduleType.single;

//   late String singleDate;
//   late String fromDate;
//   late String toDate;

//   bool _buttonLoading = false;

//   bool showAdvancedScheduling = false;

//   List<int> selectedWeekdays = [1, 2, 3, 4, 5];

//   List<Map<String, String>> timeSlots = [
//     {'start': '06:00', 'end': '10:00'},
//     {'start': '18:00', 'end': '22:00'},
//   ];

//   // ─── Logic (untouched) ────────────────────────────────────────────────────

//   String getContentTypeValue() {
//     switch (selectedContentType) {
//       case ContentType.live:
//         return 'live_content';
//       case ContentType.ad:
//         return 'ad';
//       case ContentType.carousel:
//         return 'carousel';
//     }
//   }

//   final List<String> weekdayNames = [
//     'Sun',
//     'Mon',
//     'Tue',
//     'Wed',
//     'Thu',
//     'Fri',
//     'Sat',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     final today = _fmt(DateTime.now());
//     singleDate = today;
//     fromDate = today;
//     toDate = today;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AdProvider>().loadAds();
//       context.read<GroupProvider>().loadGroups();
//       context.read<LiveContentProvider>().loadLiveContents();
//       context.read<CarouselProvider>().loadCarousels();
//     });
//   }

//   String _fmt(DateTime d) {
//     return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//   }

//   Future<String?> _pickDate(BuildContext context) async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: appColors.accent,
//             onPrimary: Colors.white,
//             surface: appColors.surface,
//             onSurface: appColors.textPrimary,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (d == null) return null;
//     return _fmt(d);
//   }

//   String formatTimeDisplay(String time24) {
//     final parts = time24.split(':');
//     int hour = int.parse(parts[0]);
//     int minute = int.parse(parts[1]);
//     final period = hour >= 12 ? 'PM' : 'AM';
//     hour = hour % 12;
//     if (hour == 0) hour = 12;
//     final h = hour.toString().padLeft(2, '0');
//     final m = minute.toString().padLeft(2, '0');
//     return '$h:$m $period';
//   }

//   Future<String?> _pickTime(String initial) async {
//     final parts = initial.split(':');
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay(
//         hour: int.parse(parts[0]),
//         minute: int.parse(parts[1]),
//       ),
//     );
//     if (picked == null) return null;
//     final h = picked.hour.toString().padLeft(2, '0');
//     final m = picked.minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }

//   void _err(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: appColors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _submit() async {
//     if (selectedItemId == null) return _err('Select an item');
//     if (selectedGroupIds.isEmpty) return _err('Select at least one group');
//     if (scheduleType == ScheduleType.multiple &&
//         fromDate.compareTo(toDate) > 0) {
//       return _err('Invalid date range');
//     }

//     setState(() => _buttonLoading = true);

//     final payload = {
//       'content_type': getContentTypeValue(),
//       'groups': selectedGroupIds.toList(),
//       'start_time': toISODate(
//         scheduleType == ScheduleType.single ? singleDate : fromDate,
//       ),
//       'end_time': toISODate(
//         scheduleType == ScheduleType.single ? singleDate : toDate,
//       ),
//       'total_duration': '360',
//       'priority': 1,
//       'weekdays': showAdvancedScheduling
//           ? selectedWeekdays
//           : [0, 1, 2, 3, 4, 5, 6],
//       'time_slots': showAdvancedScheduling
//           ? timeSlots
//           : [
//               {'start': '00:00', 'end': '23:59'},
//             ],
//     };

//     if (selectedContentType == ContentType.ad) {
//       payload['content_id'] = selectedItemId!;
//     } else {
//       payload['content_id'] = selectedItemId!;
//     }

//     try {
//       final response = await ApiService.post('/schedule/add_v2', payload);
//       print('STATUS: ${response.statusCode}');
//       print('BODY: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Schedule created successfully'),
//             backgroundColor: appColors.green,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//         Navigator.pop(context);
//       } else {
//         _err('Failed to create schedule');
//       }
//     } catch (e) {
//       _err('Something went wrong');
//     }

//     setState(() => _buttonLoading = false);
//   }

//   String toISODate(String date) => '${date}T00:00:00.000Z';

//   // ─── Build ────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final adProvider = context.watch<AdProvider>();
//     final groupProvider = context.watch<GroupProvider>();
//     final liveProvider = context.watch<LiveContentProvider>();
//     final carouselProvider = context.watch<CarouselProvider>();

//     List<dynamic> items = [];
//     bool loading = false;
//     String emptyText = '';

//     switch (selectedContentType) {
//       case ContentType.live:
//         items = liveProvider.liveContents
//             .where(
//               (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
//             )
//             .toList();
//         loading = liveProvider.loading;
//         emptyText = 'No live content found';
//         break;
//       case ContentType.ad:
//         items = adProvider.ads
//             .where(
//               (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
//             )
//             .toList();
//         loading = adProvider.loading;
//         emptyText = 'No ads found';
//         break;
//       case ContentType.carousel:
//         items = carouselProvider.carousels
//             .where(
//               (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
//             )
//             .toList();
//         loading = carouselProvider.loading;
//         emptyText = 'No carousels found';
//         break;
//     }

//     return Scaffold(
//       backgroundColor: appColors.bg,
//       appBar: AppBar(
//         backgroundColor: appColors.surface,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               color: appColors.surfaceHigh,
//               shape: BoxShape.circle,
//               border: Border.all(color: appColors.border),
//             ),
//             child: Icon(
//               Icons.arrow_back_ios_new_rounded,
//               color: appColors.textSecondary,
//               size: 15,
//             ),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Create Schedule',
//           style: TextStyle(
//             color: appColors.textPrimary,
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//             letterSpacing: -0.3,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(height: 1, color: appColors.border),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Content Type ──
//             _cardSection(
//               title: 'Content Type',
//               icon: Icons.category_rounded,
//               iconColor: appColors.accent,
//               iconBg: appColors.accentLight,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 decoration: BoxDecoration(
//                   color: appColors.surfaceHigh,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: appColors.border),
//                 ),
//                 child: DropdownButtonFormField<ContentType>(
//                   value: selectedContentType,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     isDense: true,
//                     contentPadding: EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   dropdownColor: appColors.surface,
//                   style: TextStyle(
//                     color: appColors.textPrimary,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   icon: Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     color: appColors.textMuted,
//                   ),
//                   items: const [
//                     DropdownMenuItem(
//                       value: ContentType.live,
//                       child: Text('Live Content'),
//                     ),
//                     DropdownMenuItem(value: ContentType.ad, child: Text('Ads')),
//                     DropdownMenuItem(
//                       value: ContentType.carousel,
//                       child: Text('Carousel'),
//                     ),
//                   ],
//                   onChanged: (v) {
//                     setState(() {
//                       selectedContentType = v!;
//                       selectedItemId = null;
//                       itemSearch = '';
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),

//             // ── Select Item ──
//             _cardSection(
//               title: 'Select Item',
//               icon: Icons.list_alt_rounded,
//               iconColor: appColors.purple,
//               iconBg: appColors.purpleLight,
//               child: Column(
//                 children: [
//                   _searchBox(
//                     hint: 'Search item...',
//                     onChanged: (v) => setState(() => itemSearch = v),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height: 200,
//                     child: loading
//                         ? Center(
//                             child: CircularProgressIndicator(
//                               color: appColors.accent,
//                               strokeWidth: 2.5,
//                               strokeCap: StrokeCap.round,
//                             ),
//                           )
//                         : items.isEmpty
//                         ? Center(
//                             child: Text(
//                               emptyText,
//                               style: TextStyle(
//                                 color: appColors.textMuted,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: items.length,
//                             itemBuilder: (_, i) {
//                               final e = items[i];
//                               final isSelected = selectedItemId == e.id;
//                               return InkWell(
//                                 onTap: () =>
//                                     setState(() => selectedItemId = e.id),
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Container(
//                                   margin: const EdgeInsets.only(bottom: 6),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 10,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isSelected
//                                         ? appColors.accentLight
//                                         : appColors.surfaceHigh,
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(
//                                       color: isSelected
//                                           ? appColors.accent.withOpacity(0.4)
//                                           : appColors.border,
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width: 18,
//                                         height: 18,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: isSelected
//                                                 ? appColors.accent
//                                                 : appColors.border,
//                                             width: 2,
//                                           ),
//                                           color: isSelected
//                                               ? appColors.accent
//                                               : Colors.transparent,
//                                         ),
//                                         child: isSelected
//                                             ? const Icon(
//                                                 Icons.check_rounded,
//                                                 color: Colors.white,
//                                                 size: 11,
//                                               )
//                                             : null,
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                         child: Text(
//                                           e.name,
//                                           style: TextStyle(
//                                             color: isSelected
//                                                 ? appColors.accent
//                                                 : appColors.textPrimary,
//                                             fontSize: 13,
//                                             fontWeight: isSelected
//                                                 ? FontWeight.w600
//                                                 : FontWeight.w400,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 14),

//             // ── Device Groups ──
//             _cardSection(
//               title: 'Device Groups',
//               icon: Icons.group_work_rounded,
//               iconColor: appColors.teal,
//               iconBg: appColors.tealLight,
//               child: Column(
//                 children: [
//                   _searchBox(
//                     hint: 'Search groups...',
//                     onChanged: (v) => setState(() => groupSearch = v),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height: 200,
//                     child: groupProvider.loading
//                         ? Center(
//                             child: CircularProgressIndicator(
//                               color: appColors.accent,
//                               strokeWidth: 2.5,
//                               strokeCap: StrokeCap.round,
//                             ),
//                           )
//                         : ListView(
//                             children: groupProvider.groups
//                                 .where(
//                                   (g) => g.name.toLowerCase().contains(
//                                     groupSearch.toLowerCase(),
//                                   ),
//                                 )
//                                 .map((g) {
//                                   final isChecked = selectedGroupIds.contains(
//                                     g.id,
//                                   );
//                                   return InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         if (isChecked) {
//                                           selectedGroupIds.remove(g.id);
//                                         } else {
//                                           selectedGroupIds.add(g.id);
//                                         }
//                                       });
//                                     },
//                                     borderRadius: BorderRadius.circular(10),
//                                     child: Container(
//                                       margin: const EdgeInsets.only(bottom: 6),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 10,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isChecked
//                                             ? appColors.tealLight
//                                             : appColors.surfaceHigh,
//                                         borderRadius: BorderRadius.circular(10),
//                                         border: Border.all(
//                                           color: isChecked
//                                               ? appColors.teal.withOpacity(0.4)
//                                               : appColors.border,
//                                         ),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             width: 18,
//                                             height: 18,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                               border: Border.all(
//                                                 color: isChecked
//                                                     ? appColors.teal
//                                                     : appColors.border,
//                                                 width: 2,
//                                               ),
//                                               color: isChecked
//                                                   ? appColors.teal
//                                                   : Colors.transparent,
//                                             ),
//                                             child: isChecked
//                                                 ? const Icon(
//                                                     Icons.check_rounded,
//                                                     color: Colors.white,
//                                                     size: 11,
//                                                   )
//                                                 : null,
//                                           ),
//                                           const SizedBox(width: 10),
//                                           Expanded(
//                                             child: Text(
//                                               g.name,
//                                               style: TextStyle(
//                                                 color: isChecked
//                                                     ? appColors.teal
//                                                     : appColors.textPrimary,
//                                                 fontSize: 13,
//                                                 fontWeight: isChecked
//                                                     ? FontWeight.w600
//                                                     : FontWeight.w400,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 })
//                                 .toList(),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 14),

//             // ── Schedule Duration ──
//             _cardSection(
//               title: 'Schedule Duration',
//               icon: Icons.date_range_rounded,
//               iconColor: appColors.yellow,
//               iconBg: appColors.yellowLight,
//               child: Column(
//                 children: [
//                   // Single / Multiple toggle
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _radioOption(
//                           label: 'Single Day',
//                           value: ScheduleType.single,
//                           groupValue: scheduleType,
//                           onChanged: (v) => setState(() => scheduleType = v!),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: _radioOption(
//                           label: 'Multiple Days',
//                           value: ScheduleType.multiple,
//                           groupValue: scheduleType,
//                           onChanged: (v) => setState(() => scheduleType = v!),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   // Single date
//                   if (scheduleType == ScheduleType.single)
//                     _dateButton('Date: $singleDate', () async {
//                       final d = await _pickDate(context);
//                       if (d != null) setState(() => singleDate = d);
//                     }),

//                   // Multiple dates
//                   if (scheduleType == ScheduleType.multiple)
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _dateButton('From: $fromDate', () async {
//                             final d = await _pickDate(context);
//                             if (d != null) setState(() => fromDate = d);
//                           }),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _dateButton('To: $toDate', () async {
//                             final d = await _pickDate(context);
//                             if (d != null) setState(() => toDate = d);
//                           }),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 14),

//             // ── Advanced Scheduling ──
//             _cardSection(
//               title: 'Advanced Scheduling',
//               icon: Icons.tune_rounded,
//               iconColor: appColors.orange,
//               iconBg: appColors.orangeLight,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Toggle row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Enable Advanced Scheduling',
//                         style: TextStyle(
//                           color: appColors.textSecondary,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Switch(
//                         value: showAdvancedScheduling,
//                         onChanged: (v) =>
//                             setState(() => showAdvancedScheduling = v),
//                         activeColor: appColors.accent,
//                       ),
//                     ],
//                   ),

//                   if (showAdvancedScheduling) ...[
//                     const SizedBox(height: 14),

//                     // Weekday chips
//                     Text(
//                       'Days of Week',
//                       style: TextStyle(
//                         color: appColors.textSecondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 6,
//                       runSpacing: 6,
//                       children: List.generate(7, (index) {
//                         final selected = selectedWeekdays.contains(index);
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               if (selected) {
//                                 selectedWeekdays.remove(index);
//                               } else {
//                                 selectedWeekdays.add(index);
//                               }
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 7,
//                             ),
//                             decoration: BoxDecoration(
//                               color: selected
//                                   ? appColors.accent
//                                   : appColors.surfaceHigh,
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: selected
//                                     ? appColors.accent
//                                     : appColors.border,
//                               ),
//                             ),
//                             child: Text(
//                               weekdayNames[index],
//                               style: TextStyle(
//                                 color: selected
//                                     ? Colors.white
//                                     : appColors.textSecondary,
//                                 fontSize: 12,
//                                 fontWeight: selected
//                                     ? FontWeight.w700
//                                     : FontWeight.w400,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                     const SizedBox(height: 16),

//                     // Time slots
//                     Text(
//                       'Time Slots',
//                       style: TextStyle(
//                         color: appColors.textSecondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     ...List.generate(timeSlots.length, (i) {
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 10),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: appColors.surfaceHigh,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: appColors.border),
//                         ),
//                         child: Row(
//                           children: [
//                             // Start time
//                             Expanded(
//                               child: InkWell(
//                                 onTap: () async {
//                                   final t = await _pickTime(
//                                     timeSlots[i]['start']!,
//                                   );
//                                   if (t != null) {
//                                     setState(() => timeSlots[i]['start'] = t);
//                                   }
//                                 },
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 10,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: appColors.surface,
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(color: appColors.border),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.access_time_rounded,
//                                         size: 14,
//                                         color: appColors.accent,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: FittedBox(
//                                           fit: BoxFit.scaleDown,
//                                           alignment: Alignment.centerLeft,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'Start',
//                                                 style: TextStyle(
//                                                   color: appColors.textMuted,
//                                                   fontSize: 9,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 formatTimeDisplay(
//                                                   timeSlots[i]['start']!,
//                                                 ),
//                                                 style: TextStyle(
//                                                   color: appColors.textPrimary,
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                               ),
//                               child: Icon(
//                                 Icons.arrow_forward_rounded,
//                                 size: 14,
//                                 color: appColors.textMuted,
//                               ),
//                             ),
//                             // End time
//                             Expanded(
//                               child: InkWell(
//                                 onTap: () async {
//                                   final t = await _pickTime(
//                                     timeSlots[i]['end']!,
//                                   );
//                                   if (t != null) {
//                                     setState(() => timeSlots[i]['end'] = t);
//                                   }
//                                 },
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 10,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: appColors.surface,
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(color: appColors.border),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.access_time_rounded,
//                                         size: 14,
//                                         color: appColors.orange,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: FittedBox(
//                                           fit: BoxFit.scaleDown,
//                                           alignment: Alignment.centerLeft,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'End',
//                                                 style: TextStyle(
//                                                   color: appColors.textMuted,
//                                                   fontSize: 9,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 formatTimeDisplay(
//                                                   timeSlots[i]['end']!,
//                                                 ),
//                                                 style: TextStyle(
//                                                   color: appColors.textPrimary,
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             // Delete slot
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   if (timeSlots.length > 1) {
//                                     timeSlots.removeAt(i);
//                                   }
//                                 });
//                               },
//                               child: Container(
//                                 width: 30,
//                                 height: 30,
//                                 decoration: BoxDecoration(
//                                   color: appColors.redLight,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: appColors.red.withOpacity(0.2),
//                                   ),
//                                 ),
//                                 child: Icon(
//                                   Icons.delete_rounded,
//                                   color: appColors.red,
//                                   size: 14,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }),

//                     // Add time slot button
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           timeSlots.add({'start': '09:00', 'end': '17:00'});
//                         });
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         decoration: BoxDecoration(
//                           color: appColors.accentLight,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: appColors.accent.withOpacity(0.3),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add_rounded,
//                               color: appColors.accent,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Add Time Slot',
//                               style: TextStyle(
//                                 color: appColors.accent,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // ── Submit ──
//             GestureDetector(
//               onTap: _buttonLoading ? null : _submit,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: double.infinity,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   gradient: _buttonLoading
//                       ? null
//                       : LinearGradient(
//                           colors: [appColors.accent, const Color(0xFF1E40AF)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                   color: _buttonLoading
//                       ? appColors.accent.withOpacity(0.6)
//                       : null,
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: _buttonLoading
//                       ? []
//                       : [
//                           BoxShadow(
//                             color: appColors.accent.withOpacity(0.35),
//                             blurRadius: 12,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                 ),
//                 child: Center(
//                   child: _buttonLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: const [
//                             Icon(
//                               Icons.event_available_rounded,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                             SizedBox(width: 8),
//                             Text(
//                               'Create Schedule',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─── Shared widgets ───────────────────────────────────────────────────────

//   Widget _cardSection({
//     required String title,
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBg,
//     required Widget child,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: appColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: appColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: appColors.shadow,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(7),
//                 decoration: BoxDecoration(
//                   color: iconBg,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: Icon(icon, color: iconColor, size: 15),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: appColors.textPrimary,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: -0.2,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           child,
//         ],
//       ),
//     );
//   }

//   Widget _searchBox({
//     required String hint,
//     required ValueChanged<String> onChanged,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: appColors.surfaceHigh,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: appColors.border),
//       ),
//       child: TextField(
//         style: TextStyle(color: appColors.textPrimary, fontSize: 13),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             color: appColors.textMuted,
//             size: 17,
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 11,
//           ),
//         ),
//         onChanged: onChanged,
//       ),
//     );
//   }

//   Widget _dateButton(String text, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: appColors.accentLight,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: appColors.accent.withOpacity(0.3)),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.calendar_today_rounded,
//               size: 15,
//               color: appColors.accent,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   text,
//                   style: TextStyle(
//                     color: appColors.accent,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _radioOption<T>({
//     required String label,
//     required T value,
//     required T groupValue,
//     required ValueChanged<T?> onChanged,
//   }) {
//     final isSelected = value == groupValue;
//     return GestureDetector(
//       onTap: () => onChanged(value),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? appColors.accentLight : appColors.surfaceHigh,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected
//                 ? appColors.accent.withOpacity(0.4)
//                 : appColors.border,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 16,
//               height: 16,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected ? appColors.accent : appColors.border,
//                   width: 2,
//                 ),
//                 color: isSelected ? appColors.accent : Colors.transparent,
//               ),
//               child: isSelected
//                   ? const Icon(Icons.circle, color: Colors.white, size: 6)
//                   : null,
//             ),
//             const SizedBox(width: 8),
//             Flexible(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected
//                       ? appColors.accent
//                       : appColors.textSecondary,
//                   fontSize: 12,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NEW UPDATE GIVE SCREEN LAYOUT OPTION ON DROPDOWN AND DISABLE THE CREATE SCHEDULE BUTTON IF SCREEN LAYOUT IS SELECTED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import 'package:cms_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ad_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/live_content_provider.dart';
import '../../providers/carousel_provider.dart';
import 'package:cms_app/theme/app_colors.dart';
import 'package:cms_app/utils/feature_access.dart';
import '../../providers/subscription_provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum ScheduleType { single, multiple }

enum ContentType { live, ad, carousel, screenLayout }

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  ContentType selectedContentType = ContentType.live;
  String? selectedItemId;

  final Set<String> selectedGroupIds = {};

  String itemSearch = '';
  String groupSearch = '';

  ScheduleType scheduleType = ScheduleType.single;

  late String singleDate;
  late String fromDate;
  late String toDate;

  bool _buttonLoading = false;

  bool showAdvancedScheduling = false;

  List<int> selectedWeekdays = [1, 2, 3, 4, 5];

  List<Map<String, String>> timeSlots = [
    {'start': '06:00', 'end': '10:00'},
    {'start': '18:00', 'end': '22:00'},
  ];

  // ─── Logic (untouched) ────────────────────────────────────────────────────

  String getContentTypeValue() {
    switch (selectedContentType) {
      case ContentType.live:
        return 'live_content';
      case ContentType.ad:
        return 'ad';
      case ContentType.carousel:
        return 'carousel';
      case ContentType.screenLayout:
        return 'screen_layout';
    }
  }

  final List<String> weekdayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  void initState() {
    super.initState();
    final today = _fmt(DateTime.now());
    singleDate = today;
    fromDate = today;
    toDate = today;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadSubscription();

      context.read<AdProvider>().loadAds();
      context.read<GroupProvider>().loadGroups();
      context.read<LiveContentProvider>().loadLiveContents();
      context.read<CarouselProvider>().loadCarousels();
    });
  }

  String _fmt(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<String?> _pickDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: appColors.accent,
            onPrimary: Colors.white,
            surface: appColors.surface,
            onSurface: appColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (d == null) return null;
    return _fmt(d);
  }

  String formatTimeDisplay(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Future<String?> _pickTime(String initial) async {
    final parts = initial.split(':');
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
    return '$h:$m';
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: appColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Screen Layout popup ──────────────────────────────────────────────────

  void _showScreenLayoutPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: appColors.accent.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [appColors.accent, const Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.accent.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard_customize_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              // ── Title ──
              Text(
                'Screen Layout',
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),

              // ── Body ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: appColors.accentLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: appColors.accent.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: appColors.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Screen Layout scheduling is available on the web platform. Please visit our website to create and manage screen layouts.',
                        style: TextStyle(
                          color: appColors.accent,
                          fontSize: 13,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'This feature allows you to design multi-zone layouts, set content per zone, and schedule them across your device groups — all from the web dashboard.',
                style: TextStyle(
                  color: appColors.textSecondary,
                  fontSize: 12,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),

              // ── Website chip ──
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16,
              //     vertical: 10,
              //   ),
              //   decoration: BoxDecoration(
              //     color: appColors.surfaceHigh,
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: appColors.border),
              //   ),

              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(
              //         Icons.language_rounded,
              //         color: appColors.textMuted,
              //         size: 15,
              //       ),
              //       const SizedBox(width: 8),
              //       Text(
              //         'Available on Web Dashboard',
              //         style: TextStyle(
              //           color: appColors.textSecondary,
              //           fontSize: 12,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              InkWell(
                onTap: _openWebDashboard,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        color: appColors.textMuted,
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available on Web Dashboard',
                        style: TextStyle(
                          color: appColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ── Close button ──
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Revert selection back to previous valid type
                    // setState(() => selectedContentType = ContentType.live);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: appColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (selectedItemId == null) return _err('Select an item');
    if (selectedGroupIds.isEmpty) return _err('Select at least one group');
    if (scheduleType == ScheduleType.multiple &&
        fromDate.compareTo(toDate) > 0) {
      return _err('Invalid date range');
    }

    setState(() => _buttonLoading = true);

    final payload = {
      'content_type': getContentTypeValue(),
      'groups': selectedGroupIds.toList(),
      'start_time': toISODate(
        scheduleType == ScheduleType.single ? singleDate : fromDate,
      ),
      'end_time': toISODate(
        scheduleType == ScheduleType.single ? singleDate : toDate,
      ),
      'total_duration': '360',
      'priority': 1,
      'weekdays': showAdvancedScheduling
          ? selectedWeekdays
          : [0, 1, 2, 3, 4, 5, 6],
      'time_slots': showAdvancedScheduling
          ? timeSlots
          : [
              {'start': '00:00', 'end': '23:59'},
            ],
    };

    if (selectedContentType == ContentType.ad) {
      payload['content_id'] = selectedItemId!;
    } else {
      payload['content_id'] = selectedItemId!;
    }

    try {
      final response = await ApiService.post('/schedule/add_v2', payload);
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Schedule created successfully'),
            backgroundColor: appColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Navigator.pop(context);
        Navigator.pop(context, true);
      } else {
        _err('Failed to create schedule');
      }
    } catch (e) {
      _err('Something went wrong');
    }

    setState(() => _buttonLoading = false);
  }

  String toISODate(String date) => '${date}T00:00:00.000Z';

  Future<void> _openWebDashboard() async {
    final url = Uri.parse("https://cms.ad96.in/");

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<AdProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final liveProvider = context.watch<LiveContentProvider>();
    final carouselProvider = context.watch<CarouselProvider>();

    List<dynamic> items = [];
    bool loading = false;
    String emptyText = '';

    switch (selectedContentType) {
      case ContentType.live:
        items = liveProvider.liveContents
            .where(
              (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
            )
            .toList();
        loading = liveProvider.loading;
        emptyText = 'No live content found';
        break;
      case ContentType.ad:
        items = adProvider.ads
            .where(
              (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
            )
            .toList();
        loading = adProvider.loading;
        emptyText = 'No ads found';
        break;
      case ContentType.carousel:
        items = carouselProvider.carousels
            .where(
              (e) => e.name.toLowerCase().contains(itemSearch.toLowerCase()),
            )
            .toList();
        loading = carouselProvider.loading;
        emptyText = 'No carousels found';
        break;
      case ContentType.screenLayout:
        items = [];
        loading = false;
        emptyText = '';
        break;
    }

    final showLive = FeatureAccess.showLiveStreaming(context);
    final showCarousels = FeatureAccess.showCarousels(context);

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
          'Create Schedule',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Content Type ──
            _cardSection(
              title: 'Content Type',
              icon: Icons.category_rounded,
              iconColor: appColors.accent,
              iconBg: appColors.accentLight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: appColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appColors.border),
                ),
                child: DropdownButtonFormField<ContentType>(
                  value: selectedContentType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  dropdownColor: appColors.surface,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: appColors.textMuted,
                  ),
                  items: [
                    if (showLive)
                      const DropdownMenuItem(
                        value: ContentType.live,
                        child: Text('Live Content'),
                      ),
                    const DropdownMenuItem(
                      value: ContentType.ad,
                      child: Text('Ads'),
                    ),

                    if (showCarousels)
                      const DropdownMenuItem(
                        value: ContentType.carousel,
                        child: Text('Carousel'),
                      ),
                    // ── NEW: Screen Layout ──
                    DropdownMenuItem(
                      value: ContentType.screenLayout,
                      child: Row(
                        children: [
                          const Text('Screen Layout'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.accentLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Web Only',
                              style: TextStyle(
                                color: appColors.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      selectedContentType = v!;
                      selectedItemId = null;
                      itemSearch = '';
                    });
                    if (v == ContentType.screenLayout) {
                      _showScreenLayoutPopup();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Select Item ──
            _cardSection(
              title: 'Select Item',
              icon: Icons.list_alt_rounded,
              iconColor: appColors.purple,
              iconBg: appColors.purpleLight,
              child: Column(
                children: [
                  _searchBox(
                    hint: 'Search item...',
                    onChanged: (v) => setState(() => itemSearch = v),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appColors.accent,
                              strokeWidth: 2.5,
                              strokeCap: StrokeCap.round,
                            ),
                          )
                        : items.isEmpty
                        ? Center(
                            child: Text(
                              emptyText,
                              style: TextStyle(
                                color: appColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (_, i) {
                              final e = items[i];
                              final isSelected = selectedItemId == e.id;
                              return InkWell(
                                onTap: () =>
                                    setState(() => selectedItemId = e.id),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? appColors.accentLight
                                        : appColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? appColors.accent.withOpacity(0.4)
                                          : appColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? appColors.accent
                                                : appColors.border,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? appColors.accent
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 11,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          e.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? appColors.accent
                                                : appColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Device Groups ──
            _cardSection(
              title: 'Device Groups',
              icon: Icons.group_work_rounded,
              iconColor: appColors.teal,
              iconBg: appColors.tealLight,
              child: Column(
                children: [
                  _searchBox(
                    hint: 'Search groups...',
                    onChanged: (v) => setState(() => groupSearch = v),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: groupProvider.loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: appColors.accent,
                              strokeWidth: 2.5,
                              strokeCap: StrokeCap.round,
                            ),
                          )
                        : ListView(
                            children: groupProvider.groups
                                .where(
                                  (g) => g.name.toLowerCase().contains(
                                    groupSearch.toLowerCase(),
                                  ),
                                )
                                .map((g) {
                                  final isChecked = selectedGroupIds.contains(
                                    g.id,
                                  );
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isChecked) {
                                          selectedGroupIds.remove(g.id);
                                        } else {
                                          selectedGroupIds.add(g.id);
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? appColors.tealLight
                                            : appColors.surfaceHigh,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isChecked
                                              ? appColors.teal.withOpacity(0.4)
                                              : appColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: isChecked
                                                    ? appColors.teal
                                                    : appColors.border,
                                                width: 2,
                                              ),
                                              color: isChecked
                                                  ? appColors.teal
                                                  : Colors.transparent,
                                            ),
                                            child: isChecked
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 11,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              g.name,
                                              style: TextStyle(
                                                color: isChecked
                                                    ? appColors.teal
                                                    : appColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: isChecked
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Schedule Duration ──
            _cardSection(
              title: 'Schedule Duration',
              icon: Icons.date_range_rounded,
              iconColor: appColors.yellow,
              iconBg: appColors.yellowLight,
              child: Column(
                children: [
                  // Single / Multiple toggle
                  Row(
                    children: [
                      Expanded(
                        child: _radioOption(
                          label: 'Single Day',
                          value: ScheduleType.single,
                          groupValue: scheduleType,
                          onChanged: (v) => setState(() => scheduleType = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _radioOption(
                          label: 'Multiple Days',
                          value: ScheduleType.multiple,
                          groupValue: scheduleType,
                          onChanged: (v) => setState(() => scheduleType = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Single date
                  if (scheduleType == ScheduleType.single)
                    _dateButton('Date: $singleDate', () async {
                      final d = await _pickDate(context);
                      if (d != null) setState(() => singleDate = d);
                    }),

                  // Multiple dates
                  if (scheduleType == ScheduleType.multiple)
                    Row(
                      children: [
                        Expanded(
                          child: _dateButton('From: $fromDate', () async {
                            final d = await _pickDate(context);
                            if (d != null) setState(() => fromDate = d);
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dateButton('To: $toDate', () async {
                            final d = await _pickDate(context);
                            if (d != null) setState(() => toDate = d);
                          }),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Advanced Scheduling ──
            _cardSection(
              title: 'Advanced Scheduling',
              icon: Icons.tune_rounded,
              iconColor: appColors.orange,
              iconBg: appColors.orangeLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enable Advanced Scheduling',
                        style: TextStyle(
                          color: appColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: showAdvancedScheduling,
                        onChanged: (v) =>
                            setState(() => showAdvancedScheduling = v),
                        activeColor: appColors.accent,
                      ),
                    ],
                  ),

                  if (showAdvancedScheduling) ...[
                    const SizedBox(height: 14),

                    // Weekday chips
                    Text(
                      'Days of Week',
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(7, (index) {
                        final selected = selectedWeekdays.contains(index);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                selectedWeekdays.remove(index);
                              } else {
                                selectedWeekdays.add(index);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? appColors.accent
                                  : appColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? appColors.accent
                                    : appColors.border,
                              ),
                            ),
                            child: Text(
                              weekdayNames[index],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : appColors.textSecondary,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Time slots
                    Text(
                      'Time Slots',
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...List.generate(timeSlots.length, (i) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: appColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: appColors.border),
                        ),
                        child: Row(
                          children: [
                            // Start time
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final t = await _pickTime(
                                    timeSlots[i]['start']!,
                                  );
                                  if (t != null) {
                                    setState(() => timeSlots[i]['start'] = t);
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: appColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: appColors.accent,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Start',
                                                style: TextStyle(
                                                  color: appColors.textMuted,
                                                  fontSize: 9,
                                                ),
                                              ),
                                              Text(
                                                formatTimeDisplay(
                                                  timeSlots[i]['start']!,
                                                ),
                                                style: TextStyle(
                                                  color: appColors.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: appColors.textMuted,
                              ),
                            ),
                            // End time
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final t = await _pickTime(
                                    timeSlots[i]['end']!,
                                  );
                                  if (t != null) {
                                    setState(() => timeSlots[i]['end'] = t);
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: appColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: appColors.orange,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'End',
                                                style: TextStyle(
                                                  color: appColors.textMuted,
                                                  fontSize: 9,
                                                ),
                                              ),
                                              Text(
                                                formatTimeDisplay(
                                                  timeSlots[i]['end']!,
                                                ),
                                                style: TextStyle(
                                                  color: appColors.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete slot
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (timeSlots.length > 1) {
                                    timeSlots.removeAt(i);
                                  }
                                });
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: appColors.redLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: appColors.red.withOpacity(0.2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: appColors.red,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Add time slot button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          timeSlots.add({'start': '09:00', 'end': '17:00'});
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: appColors.accentLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: appColors.accent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Add Time Slot',
                              style: TextStyle(
                                color: appColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ──
            GestureDetector(
              // onTap: _buttonLoading ? null : _submit,
              onTap:
                  _buttonLoading ||
                      selectedContentType == ContentType.screenLayout
                  ? null
                  : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  // gradient: _buttonLoading
                  //     ? null
                  gradient:
                      (_buttonLoading ||
                          selectedContentType == ContentType.screenLayout)
                      ? null
                      : LinearGradient(
                          colors: [appColors.accent, const Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  // color: _buttonLoading
                  //     ? appColors.accent.withOpacity(0.6)
                  //     : null,
                  color:
                      (_buttonLoading ||
                          selectedContentType == ContentType.screenLayout)
                      ? appColors.textMuted.withOpacity(0.35)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _buttonLoading
                      ? []
                      : [
                          BoxShadow(
                            color: appColors.accent.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Center(
                  child: _buttonLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedContentType == ContentType.screenLayout
                                  ? 'Web Only Feature'
                                  : 'Create Schedule',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────

  Widget _cardSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget child,
  }) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _searchBox({
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColors.border),
      ),
      child: TextField(
        style: TextStyle(color: appColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: appColors.textMuted, fontSize: 13),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: appColors.textMuted,
            size: 17,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dateButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: appColors.accentLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appColors.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: appColors.accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: TextStyle(
                    color: appColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioOption<T>({
    required String label,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? appColors.accentLight : appColors.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? appColors.accent.withOpacity(0.4)
                : appColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? appColors.accent : appColors.border,
                  width: 2,
                ),
                color: isSelected ? appColors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, color: Colors.white, size: 6)
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? appColors.accent
                      : appColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
