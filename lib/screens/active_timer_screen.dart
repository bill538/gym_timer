import 'package:flutter/material.dart';
import 'package:gym_timer/screens/settings_screen.dart'; // Import the settings screen
import 'package:gym_timer/widgets/painters/timer_painter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ActiveTimerScreen extends StatefulWidget {
  const ActiveTimerScreen({super.key});

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  // Placeholder data
  final int _totalTime = 30;
  int _timeLeft = 25;
  double get _currentProgress => _timeLeft / _totalTime;

  @override
  void initState() {
    super.initState();
    // Keep the screen on
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Release the wakelock
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.green; // "Work" state
    final String stateText = "WORK";

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              automaticallyImplyLeading: false, // No default back button
              title: const Text(
                '21BOOM',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.cast, color: Colors.white, size: 30),
                  onPressed: () { /* Chromecast functionality */ },
                  tooltip: 'Cast to device',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      print('Settings button pressed!');
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 10), // Small spacing
                  Text(
                    'Test content below button.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
                  ),
                ],
              ),
            ),
            // Original content area (simplified for now)
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: TimerPainter(progress: _currentProgress),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        "",
                        style: const TextStyle(
                          fontSize: 500,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
