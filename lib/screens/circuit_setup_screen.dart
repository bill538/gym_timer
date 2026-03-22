import 'package:flutter/material.dart';
import 'package:gym_timer/screens/circuit_timer_screen.dart';
import 'package:numberpicker/numberpicker.dart';

class CircuitSetupScreen extends StatefulWidget {
  const CircuitSetupScreen({super.key});

  @override
  _CircuitSetupScreenState createState() => _CircuitSetupScreenState();
}

class _CircuitSetupScreenState extends State<CircuitSetupScreen> {
  int _stations = 5;
  int _workTime = 45;
  int _restTime = 15;
  int _rounds = 3;
  int _restBetweenRounds = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit Setup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildNumberPicker("Stations/Exercises", _stations, 1, 20, (value) => setState(() => _stations = value)),
              _buildNumberPicker("Work Time (s)", _workTime, 1, 300, (value) => setState(() => _workTime = value)),
              _buildNumberPicker("Rest Between Stations (s)", _restTime, 0, 300, (value) => setState(() => _restTime = value)),
              _buildNumberPicker("Rounds", _rounds, 1, 100, (value) => setState(() => _rounds = value)),
              _buildNumberPicker("Rest Between Rounds (s)", _restBetweenRounds, 0, 300, (value) => setState(() => _restBetweenRounds = value)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CircuitTimerScreen(
                        stations: _stations,
                        workTime: _workTime,
                        restTime: _restTime,
                        rounds: _rounds,
                        restBetweenRounds: _restBetweenRounds,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start Workout', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPicker(String title, int currentValue, int minValue, int maxValue, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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
      ),
    );
  }
}
