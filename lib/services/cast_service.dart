import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

class CastService {
  static final CastService instance = CastService._internal();
  CastService._internal();

  static const _channel = MethodChannel('com.example.gym_timer/cast');
  static const _namespace = 'urn:x-cast:com.example.gym_timer';

  bool isWorkoutActive = false;

  static void initialize() {
    // No longer auto-sending updateIdle here as it overrides workout starts
    _startHeartbeat();
  }

  static void _startHeartbeat() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final isConnected = GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected;
      if (isConnected) {
        // Sending a minimal message to keep the session active
        try {
          await _channel.invokeMethod('sendCastMessage', {
            'namespace': _namespace,
            'message': jsonEncode({'type': 'heartbeat'}),
          });
        } catch (e) {
          // Ignore
        }
      }
    });
  }

  Future<void> updateIdle({String? time}) async {
    if (isWorkoutActive) return; // Prevent clock from showing during workout
    await _sendMessage({
      'type': 'idle',
      if (time != null) 'time': time,
    });
  }

  Future<void> updateWorkout({
    required String time,
    required String state,
    required int round,
    required int totalRounds,
    required String backgroundColor,
  }) async {
    isWorkoutActive = true;
    await _sendMessage({
      'type': 'workout',
      'time': time,
      'state': state,
      'round': round,
      'totalRounds': totalRounds,
      'backgroundColor': backgroundColor,
    });
  }

  Future<void> stopWorkout() async {
    isWorkoutActive = false;
    await updateIdle();
  }

  Future<void> _sendMessage(Map<String, dynamic> data) async {
    try {
      await _channel.invokeMethod('sendCastMessage', {
        'namespace': _namespace,
        'message': jsonEncode(data),
      });
    } catch (e) {
      // Ignore
    }
  }
}
