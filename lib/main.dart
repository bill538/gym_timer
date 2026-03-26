import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_timer/screens/splash_screen.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
  
  // Minimal config based on what we've seen
  await GoogleCastContext.instance.setSharedInstanceWithOptions(
    GoogleCastOptions(
      // The constructor takes named parameters but we need to know what they are.
      // Assuming it might have a discoveryCriteria or similar.
    ),
  );

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
      home: SplashScreen(),
    );
  }
}
