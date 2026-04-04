import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gym_timer/services/cast_service.dart';

part 'circuit_timer_event.dart';
part 'circuit_timer_state.dart';

class CircuitTimerBloc extends Bloc<CircuitTimerEvent, CircuitTimerState> {
  final Ticker _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final int stations;
  final int workTime;
  final int restTime;
  final int rounds;
  final int restBetweenRounds;

  StreamSubscription<int>? _tickerSubscription;

  CircuitTimerBloc({
    required Ticker ticker,
    required this.stations,
    required this.workTime,
    required this.restTime,
    required this.rounds,
    required this.restBetweenRounds,
  }) : _ticker = ticker,
       super(const CircuitTimerInitial(5, 1, 1, "Get Ready")) {
    on<CircuitTimerStarted>(_onStarted);
    on<CircuitTimerPause>(_onPaused);
    on<CircuitTimerResumed>(_onResumed);
    on<CircuitTimerReset>(_onReset);
    on<_CircuitTimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    _audioPlayer.dispose();
    CastService.instance.updateIdle();
    return super.close();
  }

  void _onStarted(CircuitTimerStarted event, Emitter<CircuitTimerState> emit) async {
    _updateCast(0, 1, 1, "Get Ready");
    _playSound('beep.mp3');
    for (int i = 3; i > 0; i--) {
      emit(CircuitTimerInitial(i, 1, 1, "Get Ready"));
      _updateCast(i, 1, 1, "Get Ready");
      if (i > 1) {
        await Future.delayed(const Duration(seconds: 1));
        _playSound('beep.mp3');
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    _playSound('start.mp3');
    _startNextSegment(emit, 1, 1, "Work", workTime);
  }

  void _onPaused(CircuitTimerPause event, Emitter<CircuitTimerState> emit) {
    if (state is CircuitTimerInProgress || state.currentState == "Get Ready") {
      _tickerSubscription?.pause();
      emit(CircuitTimerPaused(state.duration, state.currentRound, state.currentStation, state.currentState));
      _updateCast(state.duration, state.currentRound, state.currentStation, state.currentState, isPaused: true);
    }
  }

  void _onResumed(CircuitTimerResumed event, Emitter<CircuitTimerState> emit) {
    if (state is CircuitTimerPaused) {
      _tickerSubscription?.resume();
      emit(CircuitTimerInProgress(state.duration, state.currentRound, state.currentStation, state.currentState));
      _updateCast(state.duration, state.currentRound, state.currentStation, state.currentState);
    }
  }

  void _onReset(CircuitTimerReset event, Emitter<CircuitTimerState> emit) {
    _tickerSubscription?.cancel();
    add(const CircuitTimerStarted(duration: 0));
  }

  void _onTicked(_CircuitTimerTicked event, Emitter<CircuitTimerState> emit) async {
    if (event.duration > 0) {
      emit(CircuitTimerInProgress(event.duration, state.currentRound, state.currentStation, state.currentState));
      _updateCast(event.duration, state.currentRound, state.currentStation, state.currentState);
    } else {
      _playSound('end.mp3');
      await _determineNextState(emit);
    }
  }
  
  Future<void> _determineNextState(Emitter<CircuitTimerState> emit) async {
    if (state.currentState == "Work") {
      if (state.currentStation < stations) {
        _startNextSegment(emit, state.currentRound, state.currentStation + 1, "Rest", restTime);
      } else {
        if (state.currentRound < rounds) {
          _startNextSegment(emit, state.currentRound + 1, 1, "Round Rest", restBetweenRounds);
        } else {
          emit(const CircuitTimerComplete());
          _updateCast(0, rounds, stations, "Finished");
          await Future.delayed(const Duration(seconds: 30));
          emit(const CircuitTimerFinished());
        }
      }
    } else if (state.currentState == "Rest") {
      _startNextSegment(emit, state.currentRound, state.currentStation, "Work", workTime);
    } else if (state.currentState == "Round Rest") {
      _startNextSegment(emit, state.currentRound, 1, "Work", workTime);
    }
  }

  void _startNextSegment(Emitter<CircuitTimerState> emit, int round, int station, String currentState, int duration) {
    emit(CircuitTimerInProgress(duration, round, station, currentState));
    _updateCast(duration, round, station, currentState);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: duration).listen((d) => add(_CircuitTimerTicked(duration: d)));
  }

  void _updateCast(int duration, int round, int station, String currentState, {bool isPaused = false}) {
    String color;
    if (isPaused) {
      color = "#FFEB3B";
    } else {
      switch (currentState) {
        case "Work":
          color = "#90EE90";
          break;
        case "Rest":
        case "Round Rest":
        case "Get Ready":
          color = "#F44336";
          break;
        case "Finished":
        case "Done!":
          color = "#2196F3";
          break;
        default:
          color = "#40324B";
      }
    }

    String displayState = currentState;
    if (currentState == "Work") displayState = "Go!";
    if (isPaused) displayState = "Paused";

    final minutes = (duration / 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    final timeStr = '$minutes:$seconds';

    CastService.instance.updateWorkout(
      time: timeStr,
      state: "$displayState | Station $station/$stations",
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
