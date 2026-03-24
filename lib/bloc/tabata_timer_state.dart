part of 'tabata_timer_bloc.dart';

abstract class TabataTimerState extends Equatable {
  final int duration;
  final int currentRound;
  final String currentState;

  const TabataTimerState(this.duration, this.currentRound, this.currentState);

  @override
  List<Object> get props => [duration, currentRound, currentState];
}

class TabataTimerInitial extends TabataTimerState {
  const TabataTimerInitial(int duration, int currentRound, String currentState) : super(duration, currentRound, currentState);
}

class TabataTimerInProgress extends TabataTimerState {
  const TabataTimerInProgress(int duration, int currentRound, String currentState) : super(duration, currentRound, currentState);
}

class TabataTimerPaused extends TabataTimerState {
  const TabataTimerPaused(int duration, int currentRound, String currentState) : super(duration, currentRound, currentState);
}

class TabataTimerComplete extends TabataTimerState {
  const TabataTimerComplete() : super(0, 0, "Finished");
}
