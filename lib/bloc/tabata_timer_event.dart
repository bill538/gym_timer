part of 'tabata_timer_bloc.dart';

abstract class TabataTimerEvent extends Equatable {
  const TabataTimerEvent();

  @override
  List<Object> get props => [];
}

class TabataTimerStarted extends TabataTimerEvent {
  const TabataTimerStarted({required this.duration});
  final int duration;
}

class TabataTimerPause extends TabataTimerEvent {
  const TabataTimerPause();
}

class TabataTimerResumed extends TabataTimerEvent {
  const TabataTimerResumed();
}

class TabataTimerReset extends TabataTimerEvent {
  const TabataTimerReset();
}

class _TabataTimerTicked extends TabataTimerEvent {
  const _TabataTimerTicked({required this.duration});
  final int duration;
}
