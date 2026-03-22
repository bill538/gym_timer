import 'dart:async';
import 'package:flutter/material.dart';

class CircuitTimerScreen extends StatefulWidget {
  final int stations;
  final int workTime;
  final int restTime;
  final int rounds;
  final int restBetweenRounds;

  const CircuitTimerScreen({
    super.key,
    required this.stations,
    required this.workTime,
    required this.restTime,
    required this.rounds,
    required this.restBetweenRounds,
  });

  @override
  _CircuitTimerScreenState createState() => _CircuitTimerScreenState();
}

class _CircuitTimerScreenState extends State<CircuitTimerScreen> {
  late Timer _timer;
  int _currentRound = 1;
  int _currentStation = 1;
  int _currentTime = 0;
  String _currentState = "Get Ready";
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentTime = 5; // Initial countdown
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_currentTime > 1) {
            _currentTime--;
          } else {
            // Main timer logic
            if (_currentState == "Get Ready") {
              _currentState = "Work";
              _currentTime = widget.workTime;
            } else if (_currentState == "Work") {
              if (_currentStation < widget.stations) {
                _currentState = "Rest";
                _currentTime = widget.restTime;
                _currentStation++;
              } else {
                if (_currentRound < widget.rounds) {
                  _currentState = "Round Rest";
                  _currentTime = widget.restBetweenRounds;
                  _currentRound++;
                  _currentStation = 1;
                } else {
                  _currentState = "Finished";
                  _timer.cancel();
                }
              }
            } else if (_currentState == "Rest") {
              _currentState = "Work";
              _currentTime = widget.workTime;
            } else if (_currentState == "Round Rest") {
               _currentState = "Work";
              _currentTime = widget.workTime;
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
        _currentRound = 1;
        _currentStation = 1;
        _currentTime = 5;
        _currentState = "Get Ready";
        _isPaused = false;
     });
     startTimer();
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (_currentState) {
      case "Work":
        return Colors.green;
      case "Rest":
        return Colors.orange;
      case "Round Rest":
        return Colors.red;
      case "Get Ready":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit Workout'),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _getBackgroundColor(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Round $_currentRound / ${widget.rounds}',
                style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
              ),
               Text(
                'Station $_currentStation / ${widget.stations}',
                style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                _currentState,
                style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                '$_currentTime',
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
