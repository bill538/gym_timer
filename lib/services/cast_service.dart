import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

class CastService {
  static final CastService instance = CastService._internal();
  CastService._internal() {
    // Automatically send idle message when connected
    GoogleCastSessionManager.instance.currentSessionStream.listen((session) {
      if (session != null && GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected) {
        updateIdle();
      }
    });
  }

  static const _channel = MethodChannel('com.example.gym_timer/cast');
  static const _namespace = 'urn:x-cast:com.example.gym_timer';

  Future<void> updateIdle() async {
    await _sendMessage({
      'type': 'idle',
    });
  }

  Future<void> updateWorkout({
    required String time,
    required String state,
    required int round,
    required int totalRounds,
    required String backgroundColor,
  }) async {
    await _sendMessage({
      'type': 'workout',
      'time': time,
      'state': state,
      'round': round,
      'totalRounds': totalRounds,
      'backgroundColor': backgroundColor,
    });
  }

  Future<void> _sendMessage(Map<String, dynamic> data) async {
    try {
      await _channel.invokeMethod('sendCastMessage', {
        'namespace': _namespace,
        'message': jsonEncode(data),
      });
    } catch (e) {
      // Handle error (e.g., no active session)
    }
  }
}
