import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gym_timer/services/cast_service.dart';

part 'tabata_timer_event.dart';
part 'tabata_timer_state.dart';

class TabataTimerBloc extends Bloc<TabataTimerEvent, TabataTimerState> {
  final Ticker _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final int workTime;
  final int restTime;
  final int rounds;

  StreamSubscription<int>? _tickerSubscription;

  TabataTimerBloc({
    required Ticker ticker,
    required this.workTime,
    required this.restTime,
    required this.rounds,
  }) : _ticker = ticker,
       super(const TabataTimerInitial(5, 1, "Get Ready")) {
    on<TabataTimerStarted>(_onStarted);
    on<TabataTimerPause>(_onPaused);
    on<TabataTimerResumed>(_onResumed);
    on<TabataTimerReset>(_onReset);
    on<_TabataTimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _audioPlayer.dispose();
    CastService.instance.stopWorkout();
    return super.close();
  }

  void _onStarted(TabataTimerStarted event, Emitter<TabataTimerState> emit) async {
    _updateCast(0, 1, "Get Ready");
    _playSound('beep.mp3');
    for (int i = 3; i > 0; i--) {
      emit(TabataTimerInitial(i, 1, "Get Ready"));
      _updateCast(i, 1, "Get Ready");
      if (i > 1) {
        await Future.delayed(const Duration(seconds: 1));
        _playSound('beep.mp3');
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    _playSound('start.mp3');
    _startNextSegment(emit, 1, "Work", workTime);
  }

  void _onPaused(TabataTimerPause event, Emitter<TabataTimerState> emit) {
    if (state is TabataTimerInProgress || state.currentState == "Get Ready") {
      _tickerSubscription?.pause();
      emit(TabataTimerPaused(state.duration, state.currentRound, state.currentState));
      _updateCast(state.duration, state.currentRound, state.currentState, isPaused: true);
    }
  }

  void _onResumed(TabataTimerResumed event, Emitter<TabataTimerState> emit) {
    if (state is TabataTimerPaused) {
      _tickerSubscription?.resume();
      emit(TabataTimerInProgress(state.duration, state.currentRound, state.currentState));
      _updateCast(state.duration, state.currentRound, state.currentState);
    }
  }

  void _onReset(TabataTimerReset event, Emitter<TabataTimerState> emit) {
    _tickerSubscription?.cancel();
    add(const TabataTimerStarted(duration: 0));
  }

  void _onTicked(_TabataTimerTicked event, Emitter<TabataTimerState> emit) async {
    if (event.duration > 0) {
      emit(TabataTimerInProgress(event.duration, state.currentRound, state.currentState));
      _updateCast(event.duration, state.currentRound, state.currentState);
    } else {
      _playSound('end.mp3');
      await _determineNextState(emit);
    }
  }
  
  Future<void> _determineNextState(Emitter<TabataTimerState> emit) async {
    if (state.currentState == "Work") {
      if (state.currentRound < rounds) {
        _startNextSegment(emit, state.currentRound, "Rest", restTime);
      } else {
        emit(const TabataTimerFinished());
        _updateCast(0, rounds, "Finished");
        await Future.delayed(const Duration(seconds: 30));
        emit(const TabataTimerComplete());
      }
    } else if (state.currentState == "Rest") {
      _startNextSegment(emit, state.currentRound + 1, "Work", workTime);
    }
  }

  void _startNextSegment(Emitter<TabataTimerState> emit, int round, String currentState, int duration) {
    emit(TabataTimerInProgress(duration, round, currentState));
    _updateCast(duration, round, currentState);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: duration).listen((d) => add(_TabataTimerTicked(duration: d)));
  }

  void _updateCast(int duration, int round, String currentState, {bool isPaused = false}) {
    String color;
    if (isPaused) {
      color = "#FFEB3B"; // Yellow for pause
    } else {
      switch (currentState) {
        case "Work":
          color = "#90EE90"; // Light Green
          break;
        case "Rest":
        case "Get Ready":
          color = "#F44336"; // Red
          break;
        case "Finished":
        case "Done!":
          color = "#2196F3"; // Blue
          break;
        default:
          color = "#40324B"; // Primary
      }
    }

    final minutes = (duration / 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    final timeStr = '$minutes:$seconds';

    CastService.instance.updateWorkout(
      time: timeStr,
      state: isPaused ? "Paused" : currentState,
      round: round,
      totalRounds: rounds,
      backgroundColor: color,
    );
  }

  Future<void> _playSound(String sound) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$sound'));
    } catch (e) {
      // Ignore
    }
  }
}
