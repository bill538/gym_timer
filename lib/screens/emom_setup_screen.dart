import 'package:flutter/material.dart';
import 'package:gym_timer/screens/emom_timer_screen.dart';
import 'package:numberpicker/numberpicker.dart';

class EmomSetupScreen extends StatefulWidget {
  const EmomSetupScreen({super.key});

  @override
  _EmomSetupScreenState createState() => _EmomSetupScreenState();
}

class _EmomSetupScreenState extends State<EmomSetupScreen> {
  int _minutes = 10; // Default total minutes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMOM Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            _buildNumberPicker("Total Minutes", _minutes, 1, 120, (value) => setState(() => _minutes = value)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmomTimerScreen(
                      minutes: _minutes,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          NumberPicker(
            value: currentValue,
            minValue: minValue,
            maxValue: maxValue,
            step: 1,
            haptics: true,
            axis: Axis.vertical,
            onChanged: onChanged,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
