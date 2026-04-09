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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0, // No shadow for a flat look
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () { Scaffold.of(context).openDrawer(); },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white, size: 30),
            onPressed: () { /* Chromecast functionality */ },
            tooltip: 'Cast to device',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Get Ready Time (seconds)'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
