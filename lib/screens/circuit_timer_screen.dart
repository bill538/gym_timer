import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_timer/bloc/circuit_timer_bloc.dart';
import 'package:gym_timer/ticker/ticker.dart';

class CircuitTimerScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CircuitTimerBloc(
        ticker: const Ticker(),
        stations: stations,
        workTime: workTime,
        restTime: restTime,
        rounds: rounds,
        restBetweenRounds: restBetweenRounds,
      )..add(const CircuitTimerStarted(duration: 0)),
      child: BlocListener<CircuitTimerBloc, CircuitTimerState>(
        listener: (context, state) {
          if (state is CircuitTimerFinished) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: const CircuitTimerView(),
      ),
    );
  }
}

class CircuitTimerView extends StatelessWidget {
  const CircuitTimerView({super.key});

  Color _getBackgroundColor(String currentState) {
    switch (currentState) {
      case "Work":
        return Colors.green;
      case "Rest":
        return Colors.orange;
      case "Round Rest":
        return Colors.red;
      case "Get Ready":
        return const Color(0xFF40324B);
      default:
        return const Color(0xFF40324B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rounds = context.select((CircuitTimerBloc bloc) => bloc.rounds);
    final stations = context.select((CircuitTimerBloc bloc) => bloc.stations);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Signal idle to Chromecast before popping
            CastService.instance.updateIdle();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocBuilder<CircuitTimerBloc, CircuitTimerState>(
        builder: (context, state) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            color: _getBackgroundColor(state.currentState),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Round ${state.currentRound} / $rounds',
                    style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Station ${state.currentStation} / $stations',
                    style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.currentState,
                    style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${state.duration}',
                    style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  if (state is! CircuitTimerComplete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(state is CircuitTimerInProgress ? Icons.pause : Icons.play_arrow),
                          iconSize: 60,
                          color: Colors.white,
                          onPressed: () {
                            if (state is CircuitTimerInProgress) {
                              context.read<CircuitTimerBloc>().add(const CircuitTimerPause());
                            } else {
                              context.read<CircuitTimerBloc>().add(const CircuitTimerResumed());
                            }
                          },
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          iconSize: 60,
                          color: Colors.white,
                          onPressed: () => context.read<CircuitTimerBloc>().add(const CircuitTimerReset()),
                        ),
                      ],
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 60,
                      color: Colors.white,
                      onPressed: () => context.read<CircuitTimerBloc>().add(const CircuitTimerReset()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
