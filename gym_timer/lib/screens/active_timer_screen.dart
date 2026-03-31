
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_timer/bloc/timer_bloc.dart';
import 'package:gym_timer/bloc/timer_event.dart';
import 'package:gym_timer/bloc/timer_state.dart';
import 'package:gym_timer/models/workout.dart';

class ActiveTimerScreen extends StatelessWidget {
  final Workout workout;

  const ActiveTimerScreen({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerBloc(workout: workout, ticker: Ticker())..add(TimerStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Active Timer'),
        ),
        body: Center(
          child: BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) {
              if (state is TimerInitial) {
                return Text(
                  '${state.duration}',
                  style: Theme.of(context).textTheme.headline1,
                );
              }
              if (state is TimerRunInProgress) {
                return Text(
                  '${state.duration}',
                  style: Theme.of(context).textTheme.headline1,
                );
              }
              if (state is TimerRunComplete) {
                return Text(
                  'Finished!',
                  style: Theme.of(context).textTheme.headline1,
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
