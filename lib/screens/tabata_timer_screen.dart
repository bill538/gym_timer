import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_timer/bloc/tabata_timer_bloc.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:gym_timer/services/cast_service.dart';
import 'package:numberpicker/numberpicker.dart';

class TabataSetupScreen extends StatefulWidget {
  const TabataSetupScreen({super.key});

  @override
  _TabataSetupScreenState createState() => _TabataSetupScreenState();
}

class _TabataSetupScreenState extends State<TabataSetupScreen> {
  int _workTime = 20;
  int _restTime = 10;
  int _rounds = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabata Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            _buildNumberPicker(
                "Work Time (s)", _workTime, 1, 300, (value) => setState(() => _workTime = value)),
            const SizedBox(height: 20),
            _buildNumberPicker(
                "Rest Time (s)", _restTime, 0, 300, (value) => setState(() => _restTime = value)),
            const SizedBox(height: 20),
            _buildNumberPicker("Rounds", _rounds, 1, 100, (value) => setState(() => _rounds = value)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TabataTimerScreen(
                      workTime: _workTime,
                      restTime: _restTime,
                      rounds: _rounds,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Workout', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPicker(
      String title, int currentValue, int minValue, int maxValue, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 150, child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        NumberPicker(
          value: currentValue,
          minValue: minValue,
          maxValue: maxValue,
          step: 1,
          itemHeight: 50,
          haptics: true,
          axis: Axis.vertical,
          onChanged: onChanged,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class TabataTimerScreen extends StatelessWidget {
  final int workTime;
  final int restTime;
  final int rounds;

  const TabataTimerScreen({
    super.key,
    required this.workTime,
    required this.restTime,
    required this.rounds,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TabataTimerBloc(
        ticker: const Ticker(),
        workTime: workTime,
        restTime: restTime,
        rounds: rounds,
      )..add(const TabataTimerStarted(duration: 0)),
      child: const TabataTimerView(),
    );
  }
}

class TabataTimerView extends StatelessWidget {
  const TabataTimerView({super.key});

  Color _getBackgroundColor(String currentState) {
    if (currentState == "Work") return Colors.green;
    if (currentState == "Rest") return Colors.orange;
    if (currentState == "Get Ready") return const Color(0xFF40324B);
    if (currentState == "Done!") return Colors.blue;
    return const Color(0xFF40324B);
  }

  @override
  Widget build(BuildContext context) {
    final rounds = context.select((TabataTimerBloc bloc) => bloc.rounds);
    
    return BlocListener<TabataTimerBloc, TabataTimerState>(
      listener: (context, state) {
        if (state is TabataTimerComplete) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabata Workout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Signal idle to Chromecast before popping
              CastService.instance.updateIdle();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocBuilder<TabataTimerBloc, TabataTimerState>(
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
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.currentState,
                      style: const TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${state.duration}',
                      style: const TextStyle(
                          fontSize: 150,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state is! TabataTimerComplete && state.currentState != "Done!")
                            IconButton(
                              icon: Icon(state is TabataTimerInProgress ? Icons.pause : Icons.play_arrow),
                              iconSize: 60,
                              color: Colors.white,
                              onPressed: () {
                                if (state is TabataTimerInProgress) {
                                  context.read<TabataTimerBloc>().add(const TabataTimerPause());
                                } else {
                                  context.read<TabataTimerBloc>().add(const TabataTimerResumed());
                                }
                              },
                            ),
                          const SizedBox(width: 40),
                          if (state.currentState != "Done!")
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            iconSize: 60,
                            color: Colors.white,
                            onPressed: () => context.read<TabataTimerBloc>().add(const TabataTimerReset()),
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
      ),
    );
  }
}
