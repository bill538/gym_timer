part of 'circuit_timer_bloc.dart';

abstract class CircuitTimerEvent extends Equatable {
  const CircuitTimerEvent();

  @override
  List<Object> get props => [];
}

class CircuitTimerStarted extends CircuitTimerEvent {
  const CircuitTimerStarted({required this.duration});
  final int duration;
}

class CircuitTimerPause extends CircuitTimerEvent {
  const CircuitTimerPause();
}

class CircuitTimerResumed extends CircuitTimerEvent {
  const CircuitTimerResumed();
}

class CircuitTimerReset extends CircuitTimerEvent {
  const CircuitTimerReset();
}

class _CircuitTimerTicked extends CircuitTimerEvent {
  const _CircuitTimerTicked({required this.duration});
  final int duration;
}
