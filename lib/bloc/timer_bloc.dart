import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:audioplayers/audioplayers.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer();
  static const int _initialDuration = 60;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(const TimerInitial(_initialDuration)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    // 3-second countdown
    for (int i = 3; i > 0; i--) {
      emit(TimerCountdown(i));
      await _playSound('beep.mp3');
      await Future.delayed(const Duration(seconds: 1));
    }
    
    await _playSound('start.mp3');
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_initialDuration));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) async {
    if (event.duration > 0) {
      emit(TimerRunInProgress(event.duration));
    } else {
      await _playSound('end.mp3');
      emit(const TimerRunComplete());
    }
  }

  Future<void> _playSound(String sound) async {
    await _audioPlayer.play(AssetSource('sounds/$sound'));
  }
}
