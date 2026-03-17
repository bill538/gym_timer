import 'dart:convert';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:flutter/foundation.dart';

class CastService {
  final FlutterChromeCast _chromeCast;
  final String _namespace = 'urn:x-cast:com.gymtimer.data';
  GoogleCastDevice? _connectedDevice;

  // Singleton pattern
  CastService._privateConstructor() : _chromeCast = FlutterChromeCast.instance;
  static final CastService _instance = CastService._privateConstructor();
  factory CastService() {
    return _instance;
  }

  void init() {
    _chromeCast.onDeviceConnected.listen((device) {
      _connectedDevice = device;
      _chromeCast.requestSession();
    });

    _chromeCast.onDeviceDisconnected.listen((device) {
      _connectedDevice = null;
    });

    _chromeCast.onSessionStarted.listen((_) {
      debugPrint("Session started, ready to send messages.");
    });
  }

  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (_connectedDevice == null) {
      debugPrint("No device connected, cannot send message.");
      return;
    }

    try {
      await _chromeCast.sendMessage(
        namespace: _namespace,
        message: jsonEncode(message),
      );
      debugPrint('Successfully sent message: $message');
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Example of sending the specific timer update payload
  void sendTimerUpdate({
    required String timeLeft,
    required double progress,
    required String state,
    required int currentRound,
    required int totalRounds,
    required String nextExercise,
  }) {
    final payload = {
      "command": "UPDATE_TIMER",
      "data": {
        "timeLeft": timeLeft,
        "progress": progress,
        "state": state,
        "currentRound": currentRound,
        "totalRounds": totalRounds,
        "nextExercise": nextExercise
      }
    };
    sendMessage(payload);
  }
}
