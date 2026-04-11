import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_timer/screens/splash_screen.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:gym_timer/services/cast_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_timer/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load settings on app startup
  final prefs = await SharedPreferences.getInstance();
  AppSettings.getReadyDuration = prefs.getInt('getReadyDuration') ?? AppSettings.getReadyDuration;
  AppSettings.lastCastDeviceName = prefs.getString('lastCastDeviceName') ?? AppSettings.lastCastDeviceName;
  AppSettings.lastCastDeviceId = prefs.getString('lastCastDeviceId') ?? AppSettings.lastCastDeviceId;
  AppSettings.autoConnectChromecast = prefs.getBool('autoConnectChromecast') ?? AppSettings.autoConnectChromecast;

  CastService.initialize();
  runApp(const GymTimerApp());
}

class GymTimerApp extends StatelessWidget {
  const GymTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Gym Timer',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF40324B),
        primaryColor: const Color(0xFF40324B),
        fontFamily: 'monospace',
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
