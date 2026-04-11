import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_timer/settings.dart';

class CastService {
  static final CastService instance = CastService._internal();
  CastService._internal();

  static const _channel = MethodChannel('com.example.gym_timer/cast');
  static const _namespace = 'urn:x-cast:com.example.gym_timer';

  bool isWorkoutActive = false;

  static void initialize() {
    _startHeartbeat();
    
    // Listen for connection state changes to save last connected device
    GoogleCastSessionManager.instance.currentSessionStream.listen((session) async {
      if (session != null && session.connectionState == GoogleCastConnectState.connected) {
        final device = session.device;
        if (device != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lastCastDeviceName', device.friendlyName);
          await prefs.setString('lastCastDeviceId', device.deviceID);
          AppSettings.lastCastDeviceName = device.friendlyName;
          AppSettings.lastCastDeviceId = device.deviceID;
        }
      }
    });
  }

  static Future<void> checkAndAutoConnect() async {
    final sessionManager = GoogleCastSessionManager.instance;
    
    // Check if already connected or connecting
    if (sessionManager.connectionState == GoogleCastConnectState.connected ||
        sessionManager.connectionState == GoogleCastConnectState.connecting) {
      print("Cast auto-connect: Already connected or connecting.");
      return;
    }

    // Check settings
    if (AppSettings.autoConnectChromecast && 
        AppSettings.lastCastDeviceId.isNotEmpty) {
      
      print("Cast auto-connect: Attempting to connect to: ${AppSettings.lastCastDeviceName} (${AppSettings.lastCastDeviceId})");
      
      try {
        // First try to see if it's already in the discovery list
        final devices = await GoogleCastDiscoveryManager.instance.devicesStream.first.timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => [],
        );
        
        GoogleCastDevice? targetDevice;
        try {
          targetDevice = devices.firstWhere((d) => d.deviceID == AppSettings.lastCastDeviceId);
          print("Cast auto-connect: Found device in discovery list.");
        } catch (_) {
          print("Cast auto-connect: Device not in discovery list, creating manual reference.");
          targetDevice = GoogleCastDevice(
            deviceID: AppSettings.lastCastDeviceId,
            friendlyName: AppSettings.lastCastDeviceName,
            modelName: AppSettings.lastCastDeviceName,
            statusText: '',
            deviceVersion: '',
            isOnLocalNetwork: true,
            category: '',
            uniqueID: AppSettings.lastCastDeviceId,
          );
        }

        await sessionManager.startSessionWithDevice(targetDevice);
        print("Cast auto-connect: Session start request sent.");
      } catch (e) {
        print("Cast auto-connect: Failed to start session: $e");
      }
    } else {
      print("Cast auto-connect: Disabled or no last device ID found.");
    }
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
