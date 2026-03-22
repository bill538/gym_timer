import 'dart:async';
import 'package:flutter/material.dart';

class AmrapTimerScreen extends StatefulWidget {
  final int totalTime;

  const AmrapTimerScreen({
    super.key,
    required this.totalTime,
  });

  @override
  _AmrapTimerScreenState createState() => _AmrapTimerScreenState();
}

class _AmrapTimerScreenState extends State<AmrapTimerScreen> {
  late Timer _timer;
  late int _remainingTime;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.totalTime * 60;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer.cancel();
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
       _remainingTime = widget.totalTime * 60;
      _isPaused = false;
    });
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AMRAP Workout'),
      ),
      body: Container(
        color: Colors.deepPurple,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Text(
                'Time Remaining',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                _formatTime(_remainingTime),
                style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold),
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
