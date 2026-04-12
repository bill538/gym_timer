import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
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

  static Future<void> checkAndAutoConnect({BuildContext? context}) async {
    final sessionManager = GoogleCastSessionManager.instance;
    
    // Check if already connected or connecting
    if (sessionManager.connectionState == GoogleCastConnectState.connected ||
        sessionManager.connectionState == GoogleCastConnectState.connecting) {
      debugPrint("Cast auto-connect: Already connected or connecting.");
      return;
    }

    // Refresh settings from storage before checking
    final prefs = await SharedPreferences.getInstance();
    AppSettings.autoConnectChromecast = prefs.getBool('autoConnectChromecast') ?? AppSettings.autoConnectChromecast;
    AppSettings.lastCastDeviceId = prefs.getString('lastCastDeviceId') ?? AppSettings.lastCastDeviceId;
    AppSettings.lastCastDeviceName = prefs.getString('lastCastDeviceName') ?? AppSettings.lastCastDeviceName;

    debugPrint("Cast auto-connect check: autoConnect=${AppSettings.autoConnectChromecast}, lastId=${AppSettings.lastCastDeviceId}");

    // Check settings
    if (AppSettings.autoConnectChromecast && 
        AppSettings.lastCastDeviceId.isNotEmpty) {
      
      final msg = "Attempting to auto-connect to: ${AppSettings.lastCastDeviceName}";
      debugPrint("Cast auto-connect: $msg");
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
      }
      
      try {
        // Construct manual reference
        final targetDevice = GoogleCastDevice(
          deviceID: AppSettings.lastCastDeviceId,
          friendlyName: AppSettings.lastCastDeviceName,
          modelName: AppSettings.lastCastDeviceName,
          statusText: '',
          deviceVersion: '',
          isOnLocalNetwork: true,
          category: '',
          uniqueID: AppSettings.lastCastDeviceId,
        );

        // First try to see if it's already in the discovery list
        GoogleCastDiscoveryManager.instance.startDiscovery();
        
        // Wait up to 5 seconds for the real device to appear in the stream
        final devices = await GoogleCastDiscoveryManager.instance.devicesStream.first.timeout(
          const Duration(seconds: 5),
          onTimeout: () => [],
        );
        
        GoogleCastDevice? foundDevice;
        try {
          foundDevice = devices.firstWhere((d) => d.deviceID == AppSettings.lastCastDeviceId);
          debugPrint("Cast auto-connect: Real device found in discovery.");
        } catch (_) {
          debugPrint("Cast auto-connect: Device not found in discovery, creating manual reference.");
          if (Platform.isAndroid) {
            foundDevice = GoogleCastAndroidDevice(
              deviceID: AppSettings.lastCastDeviceId,
              friendlyName: AppSettings.lastCastDeviceName,
              modelName: AppSettings.lastCastDeviceName,
              statusText: '',
              deviceVersion: '',
              isOnLocalNetwork: true,
              category: '',
              uniqueID: AppSettings.lastCastDeviceId,
            );
          } else {
            foundDevice = GoogleCastDevice(
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
        }

        // Add a small delay to ensure the discovery manager has settled before starting session
        await Future.delayed(const Duration(seconds: 2));

        await sessionManager.startSessionWithDevice(foundDevice!);
        debugPrint("Cast auto-connect: Session start request sent.");
        
        // Stop discovery after attempt
        Future.delayed(const Duration(seconds: 2), () {
          GoogleCastDiscoveryManager.instance.stopDiscovery();
        });
      } catch (e) {
        debugPrint("Cast auto-connect: Failed to start session: $e");
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Auto-connect failed: $e")));
        }
      }
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
    String? sound,
    String? workoutType,
  }) async {
    isWorkoutActive = true;
    await _sendMessage({
      'type': 'workout',
      'time': time,
      'state': state,
      'round': round,
      'totalRounds': totalRounds,
      'backgroundColor': backgroundColor,
      if (sound != null) 'sound': sound,
      if (workoutType != null) 'workoutType': workoutType,
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
