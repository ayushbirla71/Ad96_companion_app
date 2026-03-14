import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';

class ChannelProvider extends ChangeNotifier {
  List<Channel> _channels = [];
  Channel? _selectedChannel; // <-- for details page
  bool _loading = false;
  String? _error;

  List<Channel> get channels => _channels;
  Channel? get selectedChannel => _selectedChannel;
  bool get loading => _loading;
  String? get error => _error;

  /// FETCH CHANNELS
  Future<void> fetchChannels() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ChannelService.fetchChannels();
      _channels = data.map<Channel>((e) => Channel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// FETCH SINGLE CHANNEL DETAILS
  Future<void> fetchChannelDetails(String id) async {
    _loading = true;
    _error = null;
    _selectedChannel = null;
    notifyListeners();

    try {
      final data = await ChannelService.fetchChannelDetails(id);
      _selectedChannel = Channel.fromJson(data); // single channel
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> startChannel(String id) async {
  _loading = true; // ✅ start loader
  notifyListeners();
  try {
    await ChannelService.startChannel(id);
    // if (_selectedChannel != null && _selectedChannel!.channelId == id) {
    //   _selectedChannel!.status = "live";
    // }
  } catch (e) {
    _error = e.toString();
  }
  _loading = false; // ✅ stop loader
  notifyListeners();
}

Future<void> stopChannel(String id) async {
  _loading = true; // ✅ start loader
  notifyListeners();
  try {
    await ChannelService.stopChannel(id);
    // if (_selectedChannel != null && _selectedChannel!.channelId == id) {
    //   _selectedChannel!.status = "stopped";
    // }
  } catch (e) {
    _error = e.toString();
  }
  _loading = false; // ✅ stop loader
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