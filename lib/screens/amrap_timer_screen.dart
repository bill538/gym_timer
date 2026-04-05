import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_timer/bloc/timer_bloc.dart';
import 'package:gym_timer/services/cast_service.dart';
import 'package:gym_timer/ticker/ticker.dart';

class AmrapTimerScreen extends StatelessWidget {
  final int totalTime;

  const AmrapTimerScreen({super.key, required this.totalTime});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(
        ticker: const Ticker(),
        workoutType: "AMRAP",
      )..add(TimerStarted(duration: totalTime * 60)),
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is TimerRunFinished) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: AmrapTimerView(totalTime: totalTime),
      ),
    );
  }
}

class AmrapTimerView extends StatelessWidget {
  final int totalTime;

  const AmrapTimerView({super.key, required this.totalTime});

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Color _getBackgroundColor(TimerState state) {
    if (state is TimerRunPause) return const Color(0xFFEBEB3B);
    if (state is TimerCountdown) return const Color(0xFFF44336);
    if (state is TimerRunComplete) return const Color(0xFF2196F3);
    return const Color(0xFF90EE90);
  }

  String _formatClockTime(DateTime now) {
    int hour = now.hour;
    final String amPm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final String m = now.minute.toString().padLeft(2, '0');
    final String s = now.second.toString().padLeft(2, '0');
    return '$hour:$m:$s $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AMRAP Workout'),
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
                    const Text(
                      'Time Remaining',
                      style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${state.duration}',
                      style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold),
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
                          onPressed: () => context.read<TimerBloc>().add(TimerStarted(duration: totalTime * 60)),
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
