import 'package:flutter/material.dart';
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
    // This would be driven by the timer state
    final Color backgroundColor = Colors.green; // "Work" state
    final String stateText = "WORK";

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top section for Round Counter
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'ROUND 3/8',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Main Timer
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The Progress Ring
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: TimerPainter(progress: _currentProgress),
                      ),
                    ),
                    // The Big Number
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        "",
                        style: const TextStyle(
                          fontSize: 500, // This will be scaled down by FittedBox
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
            // Bottom "Up Next" panel
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // Glassmorphism effect
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UP NEXT:',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    'Kettlebell Swings',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
