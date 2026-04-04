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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMOM Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Signal idle to Chromecast before popping
            CastService.instance.updateIdle();
            Navigator.of(context).pop();
          },
        ),
      ),
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
                final currentMinute = (minutes * 60 - state.duration) ~/ 60 + 1;
                final currentTimeInMinute = 60 - (state.duration % 60);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Minute $currentMinute / $minutes',
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$currentTimeInMinute',
                      style: const TextStyle(fontSize: 150, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final now = DateTime.now();
                        return Text(
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 37.5, color: Colors.white70, fontWeight: FontWeight.bold),
                        );
                      },
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
                          onPressed: () => context.read<TimerBloc>().add(TimerStarted(duration: minutes * 60)),
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
                      onPressed: () => context.read<TimerBloc>().add(TimerStarted(duration: minutes * 60)),
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
