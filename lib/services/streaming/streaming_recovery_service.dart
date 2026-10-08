import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/channel_provider.dart';
import '../../providers/live_content_provider.dart';

/// Remembers a live session that has started but whose teardown (stop channel
/// + delete live schedule) has not been confirmed yet. If the app is killed or
/// offline during teardown, the next launch finishes the job.
class StreamingRecoveryService {
  static const String _key = 'pending_stream_stop';

  /// True while a GoLivePage owns a session, so recovery never fights it.
  static bool sessionActive = false;

  static Future<void> markPending({
    required String channelId,
    required String contentId,
    required String contentType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'channelId': channelId,
          'contentId': contentId,
          'contentType': contentType,
        }),
      );
    } catch (e) {
      debugPrint('Recovery mark error: $e');
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('Recovery clear error: $e');
    }
  }

  /// Finishes a teardown that never completed. Safe to call repeatedly.
  static Future<void> recoverIfNeeded({
    required ChannelProvider channels,
    required LiveContentProvider liveContent,
  }) async {
    if (sessionActive) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final channelId = (data['channelId'] as String?) ?? '';
      final contentId = (data['contentId'] as String?) ?? '';
      final contentType = (data['contentType'] as String?) ?? '';

      var stopped = true;
      if (channelId.isNotEmpty) {
        stopped = await channels.stopChannelWithRetry(channelId);
      }
      if (contentId.isNotEmpty) {
        await liveContent.deleteSchedules(contentId, contentType);
      }
      if (stopped) await clear();
    } catch (e) {
      debugPrint('Recovery error: $e');
    }
  }
}
