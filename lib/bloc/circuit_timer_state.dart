part of 'circuit_timer_bloc.dart';

abstract class CircuitTimerState extends Equatable {
  final int duration;
  final int currentRound;
  final int currentStation;
  final String currentState;

  const CircuitTimerState(this.duration, this.currentRound, this.currentStation, this.currentState);

  @override
  List<Object> get props => [duration, currentRound, currentStation, currentState];
}

class CircuitTimerInitial extends CircuitTimerState {
  const CircuitTimerInitial(int duration, int currentRound, int currentStation, String currentState) : super(duration, currentRound, currentStation, currentState);
}

class CircuitTimerInProgress extends CircuitTimerState {
  const CircuitTimerInProgress(int duration, int currentRound, int currentStation, String currentState) : super(duration, currentRound, currentStation, currentState);
}

class CircuitTimerPaused extends CircuitTimerState {
    const CircuitTimerPaused(int duration, int currentRound, int currentStation, String currentState) : super(duration, currentRound, currentStation, currentState);
}

class CircuitTimerComplete extends CircuitTimerState {
  const CircuitTimerComplete() : super(0, 0, 0, "Finished");
}
