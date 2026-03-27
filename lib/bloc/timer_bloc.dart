import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gym_timer/services/cast_service.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer();
  static const int _initialDuration = 60;

  // Added for Cast
  final String? workoutType; // "EMOM" or "AMRAP"
  final int? totalRounds;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker, this.workoutType, this.totalRounds})
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
    CastService.instance.updateIdle();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    // 3-second countdown
    for (int i = 3; i > 0; i--) {
      emit(TimerCountdown(i));
      _updateCast(i, "Get Ready");
      _playSound('beep.mp3'); // Fire and forget
      await Future.delayed(const Duration(seconds: 1));
    }
    
    _playSound('start.mp3'); // Fire and forget
    emit(TimerRunInProgress(event.duration));
    _updateCast(event.duration, "Go!");
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress || state is TimerCountdown) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
      _updateCast(state.duration, "Paused", isPaused: true);
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
      _updateCast(state.duration, "Go!");
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_initialDuration));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) async {
    if (event.duration > 0) {
      emit(TimerRunInProgress(event.duration));
      _updateCast(event.duration, "Go!");
    } else {
      _playSound('end.mp3');
      emit(const TimerRunComplete());
      _updateCast(0, "Finished");
      await Future.delayed(const Duration(seconds: 30));
      emit(const TimerRunFinished());
    }
  }

  void _updateCast(int duration, String status, {bool isPaused = false}) {
    String color;
    if (isPaused) {
      color = "#FFEB3B";
    } else if (status == "Get Ready") {
      color = "#F44336";
    } else if (status == "Finished") {
      color = "#2196F3";
    } else {
      color = "#90EE90";
    }

    int currentRound = 1;
    int total = totalRounds ?? 1;

    if (workoutType == "EMOM" && totalRounds != null) {
      currentRound = (totalRounds! * 60 - duration) ~/ 60 + 1;
      if (currentRound > totalRounds!) currentRound = totalRounds!;
    }

    String timeStr;
    if (workoutType == "AMRAP") {
      final minutes = (duration / 60).floor().toString().padLeft(2, '0');
      final remainingSeconds = (duration % 60).toString().padLeft(2, '0');
      timeStr = '$minutes:$remainingSeconds';
    } else {
      timeStr = duration.toString();
    }

    CastService.instance.updateWorkout(
      time: timeStr,
      state: isPaused ? "Paused" : status,
      round: currentRound,
      totalRounds: total,
      backgroundColor: color,
    );
  }

  Future<void> _playSound(String sound) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$sound'));
    } catch (e) {
      print('Error playing sound $sound: $e');
    }
  }
}
