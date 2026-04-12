import 'package:flutter/material.dart';
import 'package:gym_timer/screens/tabata_timer_screen.dart';
import 'package:numberpicker/numberpicker.dart';

class TabataSetupScreen extends StatefulWidget {
  const TabataSetupScreen({super.key});


  @override
  _TabataSetupScreenState createState() => _TabataSetupScreenState();
}

class _TabataSetupScreenState extends State<TabataSetupScreen> {
  int _workTime = 20; // Default work time in seconds
  int _restTime = 10; // Default rest time in seconds
  int _rounds = 8;    // Default number of rounds

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabata Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            _buildNumberPicker("Work Time (s)", _workTime, 1, 300, (value) => setState(() => _workTime = value)),
            const SizedBox(height: 20),
            _buildNumberPicker("Rest Time (s)", _restTime, 0, 300, (value) => setState(() => _restTime = value)),
            const SizedBox(height: 20),
            _buildNumberPicker("Rounds", _rounds, 1, 100, (value) => setState(() => _rounds = value)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TabataTimerScreen(
                      workTime: _workTime,
                      restTime: _restTime,
                      rounds: _rounds,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF90EE90),
                foregroundColor: Colors.black,
              ),
              child: const Text('Start Workout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
