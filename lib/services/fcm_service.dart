import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import '../utils/token_storage.dart';

// Top-level background message handler

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCQEcy7Q0tstFeqeqYD75siwEOX5FqzM1A",
        appId: "1:80844393688:android:dc774e1cf19a004d941bad",
        messagingSenderId: "80844393688",
        projectId: "ad96-c974f",
        storageBucket: "ad96-c974f.firebasestorage.app",
      ),
    );
  }
  print("Background FCM message received: ${message.messageId}");
}

class FCMService {
  static String get backendUrl =>
      "${ApiConstants.baseUrl}/v1/notifications/register-token";

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
        playSound: true,
      );

  static Future<void> initialize({String? userId, String? deviceId}) async {
    try {
      // 1. Initialize Firebase App with auto-config or explicit fallback
      try {
        await Firebase.initializeApp();
      } catch (initErr) {
        print(
          "Default Firebase.initializeApp failed, trying explicit options: $initErr",
        );
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCQEcy7Q0tstFeqeqYD75siwEOX5FqzM1A",
            appId: "1:80844393688:android:dc774e1cf19a004d941bad",
            messagingSenderId: "80844393688",
            projectId: "ad96-c974f",
            storageBucket: "ad96-c974f.firebasestorage.app",
          ),
        );
      }

      // 2. Setup Local Notifications for Foreground Banners
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(initSettings);

      // Create Android Notification Channel
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(_androidChannel);
      }

      // 3. Request FCM Permission
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Set foreground notification options for iOS
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        final effectiveDeviceId =
            deviceId ?? await TokenStorage.getOrCreateDeviceId();

        // Fetch & Register Token
        String? token = await messaging.getToken();
        if (token != null) {
          print("Mobile FCM Token: $token");
          await registerTokenWithBackend(
            token,
            userId: userId,
            deviceId: effectiveDeviceId,
          );
        }

        // Listen for Token refresh
        messaging.onTokenRefresh.listen((newToken) {
          registerTokenWithBackend(
            newToken,
            userId: userId,
            deviceId: effectiveDeviceId,
          );
        });
      }

      // 4. Background Message Handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 5. Foreground Message Handler (Shows Local Banner when app is open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
          "Foreground FCM message received: ${message.notification?.title}",
        );

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );
        }
      });

      // 6. Handle Notification Tap (When user clicks push notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notification clicked by user: ${message.data}");
      });
    } catch (e) {
      print("FCM Service Initialization Error: $e");
    }
  }

  static Future<void> registerTokenWithBackend(
    String token, {
    String? userId,
    String? deviceId,
  }) async {
    try {
      String platform = Platform.isAndroid
          ? "android"
          : (Platform.isIOS ? "ios" : "web");
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "deviceToken": token,
          "platform": platform,
          "deviceId": deviceId ?? "flutter_device_${Platform.operatingSystem}",
          "userId": userId,
        }),
      );

      if (response.statusCode == 200) {
        print("Flutter FCM token registered successfully with backend.");
      } else {
        print(
          "Failed to register Flutter token with backend: ${response.body}",
        );
      }
    } catch (e) {
      print("Network error registering Flutter FCM token: $e");
    }
  }
}
