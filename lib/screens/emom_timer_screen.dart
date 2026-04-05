import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_timer/bloc/timer_bloc.dart';
import 'package:gym_timer/services/cast_service.dart';
import 'package:gym_timer/ticker/ticker.dart';

class EmomTimerScreen extends StatelessWidget {
  final int minutes;

  const EmomTimerScreen({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(
        ticker: const Ticker(),
        workoutType: "EMOM",
        totalRounds: minutes,
      )..add(TimerStarted(duration: minutes * 60)),
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is TimerRunFinished) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: EmomTimerView(minutes: minutes),
      ),
    );
  }
}

class EmomTimerView extends StatelessWidget {
  final int minutes;

  const EmomTimerView({super.key, required this.minutes});

  Color _getBackgroundColor(TimerState state) {
    if (state is TimerRunPause) return const Color(0xFFEBEB3B);
    if (state is TimerCountdown) return const Color(0xFFF44336);
    if (state is TimerRunComplete) return const Color(0xFF2196F3);
    // In standard TimerBloc, EMOM uses "Go!" status which we map to green.
    // Standard Rest colors are handled in Tabata/Circuit.
    return const Color(0xFF90EE90);
  }

  String _formatClockTime(DateTime now) {
    int hour = now.hour;
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final String m = now.minute.toString().padLeft(2, '0');
    final String s = now.second.toString().padLeft(2, '0');
    return '$hour:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMOM Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            CastService.instance.stopWorkout();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocBuilder<TimerBloc, TimerState>(
        builder: (context, state) {
          String status = "Go!";
          bool isPaused = state is TimerRunPause;
          if (state is TimerCountdown) status = "Get Ready";
          if (state is TimerRunComplete) status = "Finished";

          return Container(
            color: _getBackgroundColor(state),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (state is TimerCountdown)
                    Text(
                      '${state.duration}',
                      style: const TextStyle(fontSize: 150, color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  else if (state is TimerRunInProgress || state is TimerRunPause) ...[
                    Text(
                      state is TimerRunPause ? 'PAUSED' : 'Minute ${(minutes * 60 - state.duration) ~/ 60 + 1} / $minutes',
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${60 - (state.duration % 60)}',
                      style: const TextStyle(fontSize: 150, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ] else if (state is TimerRunComplete)
                    const Text(
                      'Workout Complete!',
                      style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  
                  const Spacer(),
                  
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                        _formatClockTime(DateTime.now()),
                        style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state is! TimerRunComplete)
                          IconButton(
                            icon: Icon(state is TimerRunInProgress ? Icons.pause : Icons.play_arrow),
                            iconSize: 80,
                            color: Colors.white,
                            onPressed: () {
                              if (state is TimerRunInProgress) {
                                context.read<TimerBloc>().add(const TimerPaused());
                              } else {
                                context.read<TimerBloc>().add(const TimerResumed());
                              }
                            },
                          ),
                        const SizedBox(width: 40),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          iconSize: 80,
                          color: Colors.white,
                          onPressed: () => context.read<TimerBloc>().add(TimerStarted(duration: minutes * 60)),
                        ),
                      ],
                    ),
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
