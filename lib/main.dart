import 'package:flutter/material.dart';
import 'package:gym_timer/widgets/workout_card.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

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

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late FlutterChromeCast _chromeCast;

  @override
  void initState() {
    super.initState();
    _chromeCast = FlutterChromeCast.instance;
    // It's good practice to initialize here, though the button itself handles discovery.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Setup'),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        actions: [
          // Add the Cast button here
          ChromeCastButton(
            onDeviceConnected: (device) {
              print('Device connected: \${device.name}');
              // Handle connection logic
            },
            onDeviceDisconnected: () {
              print('Device disconnected');
              // Handle disconnection logic
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            WorkoutCard(
              title: 'Tabata',
              glowColor: Colors.blue.shade400,
              onTap: () {
                // TODO: Implement navigation
              },
            ),
            WorkoutCard(
              title: 'EMOM',
              glowColor: Colors.yellow.shade400,
              onTap: () {
                // TODO: Implement navigation
              },
            ),
            WorkoutCard(
              title: 'AMRAP',
              glowColor: Colors.green.shade400,
              onTap: () {
                // TODO: Implement navigation
              },
            ),
            WorkoutCard(
              title: 'Circuit',
              glowColor: Colors.orange.shade400,
              onTap: () {
                // TODO: Implement navigation
              },
            ),
          ],
        ),
      ),
    );
  }
}
