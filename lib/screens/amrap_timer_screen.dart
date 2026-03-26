import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_timer/bloc/timer_bloc.dart';
import 'package:gym_timer/ticker/ticker.dart';

class AmrapTimerScreen extends StatelessWidget {
  final int totalTime;

  const AmrapTimerScreen({super.key, required this.totalTime});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: const Ticker())..add(TimerStarted(duration: totalTime * 60)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AMRAP Workout')),
      body: Container(
        color: const Color(0xFF40324B),
        child: Center(
          child: BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) {
              if (state is TimerCountdown) {
                return Text(
                  '${state.duration}',
                  style: const TextStyle(fontSize: 150, color: Colors.white, fontWeight: FontWeight.bold),
                );
              }
              if (state is TimerRunInProgress || state is TimerRunPause) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Time Remaining',
                      style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _formatTime(state.duration),
                      style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(state is TimerRunInProgress ? Icons.pause : Icons.play_arrow),
                          iconSize: 60,
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
                          iconSize: 60,
                          color: Colors.white,
                          onPressed: () => context.read<TimerBloc>().add(TimerStarted(duration: totalTime * 60)),
                        ),
                      ],
                    ),
                  ],
                );
              }
              if (state is TimerRunComplete) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Workout Complete!',
                      style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 60,
                      color: Colors.white,
                      onPressed: () => context.read<TimerBloc>().add(TimerStarted(duration: totalTime * 60)),
                    ),
                  ],
                );
              }
              return const CircularProgressIndicator(color: Colors.white);
            },
          ),
        ),
      ),
    );
  }
}
