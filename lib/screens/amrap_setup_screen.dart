import 'package:flutter/material.dart';
import 'package:gym_timer/screens/amrap_timer_screen.dart';
import 'package:numberpicker/numberpicker.dart';

class AmrapSetupScreen extends StatefulWidget {
  const AmrapSetupScreen({super.key});

  @override
  _AmrapSetupScreenState createState() => _AmrapSetupScreenState();
}

class _AmrapSetupScreenState extends State<AmrapSetupScreen> {
  int _totalTime = 10; // Default total time in minutes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AMRAP Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            _buildNumberPicker("Total Time (minutes)", _totalTime, 1, 120, (value) => setState(() => _totalTime = value)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AmrapTimerScreen(
                      totalTime: _totalTime,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Workout', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPicker(String title, int currentValue, int minValue, int maxValue, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        NumberPicker(
          value: currentValue,
          minValue: minValue,
          maxValue: maxValue,
          step: 1,
          haptics: true,
          axis: Axis.horizontal,
          onChanged: onChanged,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
