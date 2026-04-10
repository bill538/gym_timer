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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a test button.',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                print('Test button pressed!');
                // You could navigate to settings from here for debugging
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: Text(
                'Press Me!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            // Placeholder for other content, ensuring layout space
            Expanded(
              child: Center(
                child: Text(
                  'Content Area',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
