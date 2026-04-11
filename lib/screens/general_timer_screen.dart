import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_timer/bloc/timer_bloc.dart';
import 'package:gym_timer/services/cast_service.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:numberpicker/numberpicker.dart';

class GeneralTimerSetupScreen extends StatefulWidget {
  const GeneralTimerSetupScreen({super.key});

  @override
  State<GeneralTimerSetupScreen> createState() => _GeneralTimerSetupScreenState();
}

class _GeneralTimerSetupScreenState extends State<GeneralTimerSetupScreen> {
  int _minutes = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Timer Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 40),
            const Text(
              "Timer Duration (Minutes)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: NumberPicker(
                value: _minutes,
                minValue: 1,
                maxValue: 120,
                step: 1,
                itemHeight: 100,
                textStyle: const TextStyle(fontSize: 30, color: Colors.grey),
                selectedTextStyle: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                onChanged: (value) => setState(() => _minutes = value),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeneralTimerScreen(minutes: _minutes),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF90EE90),
                foregroundColor: Colors.black,
              ),
              child: const Text('Start Timer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class GeneralTimerScreen extends StatelessWidget {
  final int minutes;

  const GeneralTimerScreen({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(
        ticker: const Ticker(),
        workoutType: "General",
      )..add(TimerStarted(duration: minutes * 60)),
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is TimerRunFinished) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            CastService.checkAndAutoConnect(context: context);
          }
        },
        child: GeneralTimerView(minutes: minutes),
      ),
    );
  }
}

class GeneralTimerView extends StatelessWidget {
  final int minutes;

  const GeneralTimerView({super.key, required this.minutes});

  Color _getBackgroundColor(TimerState state) {
    if (state is TimerRunPause) return const Color(0xFFFFEB3B);
    if (state is TimerCountdown) return const Color(0xFFF44336);
    if (state is TimerRunComplete) return const Color(0xFF2196F3);
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
        title: const Text('General Timer'),
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
                    Text(
                      state is TimerRunPause ? 'PAUSED' : 'Time Remaining',
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${(state.duration ~/ 60).toString().padLeft(2, '0')}:${(state.duration % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 100, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ] else if (state is TimerRunComplete)
                    const Text(
                      'Timer Complete!',
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
