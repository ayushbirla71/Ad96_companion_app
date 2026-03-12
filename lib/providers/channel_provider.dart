import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';

class ChannelProvider extends ChangeNotifier {

  List<Channel> _channels = [];
  bool _loading = false;
  String? _error;

  List<Channel> get channels => _channels;
  bool get loading => _loading;
  String? get error => _error;

  /// FETCH CHANNELS
  Future<void> fetchChannels() async {

    _loading = true;
    _error = null;
    notifyListeners();

    try {

      final data = await ChannelService.fetchChannels();

      _channels = data
          .map<Channel>((e) => Channel.fromJson(e))
          .toList();

    } catch (e) {

      _error = e.toString();

    }

    _loading = false;
    notifyListeners();
  }

  /// CREATE CHANNEL
  Future<void> createChannel(String name) async {

    try {

      await ChannelService.createChannel(name);

      await fetchChannels();

    } catch (e) {

      _error = e.toString();
      notifyListeners();

    }
  }

  /// DELETE CHANNEL
  Future<void> deleteChannel(String id) async {

    try {

      await ChannelService.deleteChannel(id);

      _channels.removeWhere((c) => c.channelId == id);

      notifyListeners();

    } catch (e) {

      _error = e.toString();
      notifyListeners();

    }
  }
}