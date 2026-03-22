import 'package:flutter/material.dart';
import 'package:gym_timer/screens/setup_screen.dart';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF121212),
        fontFamily: 'monospace',
      ),
      home: const SetupScreen(),
    );
  }
}
