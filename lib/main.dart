import 'package:cms_app/providers/channel_provider.dart';
import 'package:cms_app/providers/live_content_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/device_provider.dart';
import 'providers/ad_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/group_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()), 
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
         ChangeNotifierProvider(create: (_) => LiveContentProvider()),
         ChangeNotifierProvider(create: (_) => ChannelProvider()),

      ],
      child: const MyApp(),
    ),
  );
}
