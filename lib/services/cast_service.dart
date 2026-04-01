import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

class CastService {
  static final CastService instance = CastService._internal();
  CastService._internal();

  static const _channel = MethodChannel('com.example.gym_timer/cast');
  static const _namespace = 'urn:x-cast:com.example.gym_timer';

  static void initialize() {
    GoogleCastSessionManager.instance.currentSessionStream.listen((session) {
      print('CastService: Session update received, State: ${GoogleCastSessionManager.instance.connectionState}');
      if (session != null && GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected) {
        CastService.instance.updateIdle();
      }
    });
  }

  Future<void> updateIdle({String? time}) async {
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
    print('CastService: Sending message: $data');
    try {
      final result = await _channel.invokeMethod('sendCastMessage', {
        'namespace': _namespace,
        'message': jsonEncode(data),
      });
      print('CastService: Message sent successfully: $result');
    } catch (e) {
      print('CastService: Error sending message: $e');
    }
  }
}
