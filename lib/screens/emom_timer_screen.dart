import 'dart:async';
import 'package:flutter/material.dart';

class EmomTimerScreen extends StatefulWidget {
  final int minutes;

  const EmomTimerScreen({
    super.key,
    required this.minutes,
  });

  @override
  _EmomTimerScreenState createState() => _EmomTimerScreenState();
}

class _EmomTimerScreenState extends State<EmomTimerScreen> {
  late Timer _timer;
  int _currentMinute = 1;
  int _currentTimeInMinute = 60;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_currentTimeInMinute > 1) {
            _currentTimeInMinute--;
          } else {
            if (_currentMinute < widget.minutes) {
              _currentMinute++;
              _currentTimeInMinute = 60;
            } else {
              _timer.cancel();
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

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _currentMinute = 1;
      _currentTimeInMinute = 60;
      _isPaused = false;
    });
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMOM Workout'),
      ),
      body: Container(
        color: Colors.teal,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Minute $_currentMinute / ${widget.minutes}',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '$_currentTimeInMinute',
                style: const TextStyle(fontSize: 150, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
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
            ],
          ),
        ),
      ),
    );
  }
}
