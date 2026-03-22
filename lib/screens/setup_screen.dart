import 'package:flutter/material.dart';
import 'package:gym_timer/widgets/workout_card.dart';
import 'package:gym_timer/screens/tabata_timer_screen.dart';
import 'package:gym_timer/screens/emom_setup_screen.dart';
import 'package:gym_timer/screens/amrap_setup_screen.dart';
import 'package:gym_timer/screens/circuit_setup_screen.dart';
import 'package:gym_timer/services/cast_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final CastService _castService;

  @override
  void initState() {
    super.initState();
    _castService = CastService();
  }

  @override
  void dispose() {
    _castService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Setup'),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cast feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            WorkoutCard(
              title: 'Tabata',
              glowColor: Colors.blue.shade400,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TabataTimerScreen()),
                );
              },
            ),
            WorkoutCard(
              title: 'EMOM',
              glowColor: Colors.yellow.shade400,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmomSetupScreen()),
                );
              },
            ),
            WorkoutCard(
              title: 'AMRAP',
              glowColor: Colors.green.shade400,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AmrapSetupScreen()),
                );
              },
            ),
            WorkoutCard(
              title: 'Circuit',
              glowColor: Colors.orange.shade400,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CircuitSetupScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
