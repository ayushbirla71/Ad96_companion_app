import 'package:cms_app/providers/carousel_provider.dart';
import 'package:cms_app/providers/channel_provider.dart';
import 'package:cms_app/providers/export_provider.dart';

import 'package:cms_app/providers/live_content_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/device_provider.dart';
import 'providers/ad_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/group_provider.dart';
import 'providers/subscription_provider.dart';

import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase & FCM Push Notifications
  await FCMService.initialize();

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
        ChangeNotifierProvider(create: (_) => CarouselProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ExportProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
