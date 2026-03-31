
import 'package:flutter/material.dart';
import 'package:gym_timer/models/workout.dart';
import 'package:gym_timer/screens/active_timer_screen.dart';
import 'package:gym_timer/widgets/workout_card.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? selectedWorkoutType;

  final TextEditingController _workController = TextEditingController(text: '20');
  final TextEditingController _restController = TextEditingController(text: '10');
  final TextEditingController _roundsController = TextEditingController(text: '8');
  final TextEditingController _minutesController = TextEditingController(text: '10');
  final TextEditingController _workPerMinuteController = TextEditingController(text: '45');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gym Timer'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          WorkoutCard(
            title: 'Tabata',
            onTap: () {
              setState(() {
                selectedWorkoutType = 'Tabata';
              });
            },
          ),
          WorkoutCard(
            title: 'EMOM',
            onTap: () {
              setState(() {
                selectedWorkoutType = 'EMOM';
              });
            },
          ),
          if (selectedWorkoutType != null) _buildSetupPanel(),
        ],
      ),
    );
  }

  Widget _buildSetupPanel() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '$selectedWorkoutType Setup',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 16.0),
            if (selectedWorkoutType == 'Tabata') ...[
              TextField(
                controller: _workController,
                decoration: InputDecoration(labelText: 'Work (seconds)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _restController,
                decoration: InputDecoration(labelText: 'Rest (seconds)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _roundsController,
                decoration: InputDecoration(labelText: 'Rounds'),
                keyboardType: TextInputType.number,
              ),
            ] else if (selectedWorkoutType == 'EMOM') ...[
              TextField(
                controller: _minutesController,
                decoration: InputDecoration(labelText: 'Minutes'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _workPerMinuteController,
                decoration: InputDecoration(labelText: 'Work per Minute (seconds)'),
                keyboardType: TextInputType.number,
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedWorkoutType == 'Tabata') {
                  final work = int.tryParse(_workController.text) ?? 0;
                  final rest = int.tryParse(_restController.text) ?? 0;
                  final rounds = int.tryParse(_roundsController.text) ?? 0;
                  final workout = TabataWorkout(work: work, rest: rest, rounds: rounds);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveTimerScreen(workout: workout),
                    ),
                  );
                } else if (selectedWorkoutType == 'EMOM') {
                  final every = int.tryParse(_minutesController.text) ?? 0;
                  final rounds = int.tryParse(_workPerMinuteController.text) ?? 0;
                  final workout = EmomWorkout(every: every, rounds: rounds);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveTimerScreen(workout: workout),
                    ),
                  );
                }
              },
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
