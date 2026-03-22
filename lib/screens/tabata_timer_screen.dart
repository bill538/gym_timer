import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TabataTimerScreen extends StatefulWidget {
  const TabataTimerScreen({super.key});

  @override
  _TabataTimerScreenState createState() => _TabataTimerScreenState();
}

class _TabataTimerScreenState extends State<TabataTimerScreen> {
  late Timer _timer;
  int _workTime = 20;
  int _restTime = 10;
  int _rounds = 8;
  int _currentRound = 1;
  int _currentTime = 0;
  String _currentState = "Get Ready";
  bool _isPaused = true;
  bool _showSettings = true;

  @override
  void initState() {
    super.initState();
    _currentTime = 5;
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_currentTime > 1) {
            _currentTime--;
          } else {
            if (_currentState == "Get Ready") {
              _currentState = "Work";
              _currentTime = _workTime;
            } else if (_currentState == "Work") {
              if (_currentRound < _rounds) {
                _currentState = "Rest";
                _currentTime = _restTime;
              } else {
                _currentState = "Finished";
                _timer.cancel();
              }
            } else if (_currentState == "Rest") {
              _currentRound++;
              _currentState = "Work";
              _currentTime = _workTime;
            }
          }
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _play() {
    setState(() {
      _showSettings = false;
      _isPaused = false;
    });
    startTimer();
  }

  void _resetTimer() {
    if (this.mounted) {
      _timer.cancel();
      setState(() {
        _currentRound = 1;
        _currentTime = 5;
        _currentState = "Get Ready";
        _isPaused = true;
        _showSettings = true;
      });
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (_currentState == "Work") return Colors.green;
    if (_currentState == "Rest") return Colors.orange;
    if (_currentState == "Get Ready") return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabata Workout'),
      ),
      body: _showSettings
          ? _buildSettings()
          : AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: _getBackgroundColor(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Round $_currentRound / $_rounds',
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _currentState,
                      style: const TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_currentTime',
                      style: const TextStyle(
                          fontSize: 150,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause),
                            iconSize: 60,
                            color: Colors.white,
                            onPressed: _togglePause,
                          ),
                          const SizedBox(width: 40),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            iconSize: 60,
                            color: Colors.white,
                            onPressed: _resetTimer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20),
          _buildNumberPicker(
              "Work Time (s)", _workTime, 1, 300, (value) => setState(() => _workTime = value)),
          const SizedBox(height: 20),
          _buildNumberPicker(
              "Rest Time (s)", _restTime, 0, 300, (value) => setState(() => _restTime = value)),
          const SizedBox(height: 20),
          _buildNumberPicker("Rounds", _rounds, 1, 100, (value) => setState(() => _rounds = value)),
          const Spacer(),
          ElevatedButton(
            onPressed: _play,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Play', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Reset', style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }

  Widget _buildNumberPicker(
      String title, int currentValue, int minValue, int maxValue, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 150, child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        NumberPicker(
          value: currentValue,
          minValue: minValue,
          maxValue: maxValue,
          step: 1,
          itemHeight: 50,
          haptics: true,
          axis: Axis.vertical,
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
