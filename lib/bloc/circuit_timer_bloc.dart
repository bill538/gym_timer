import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:audioplayers/audioplayers.dart';

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
    return super.close();
  }

  void _onStarted(CircuitTimerStarted event, Emitter<CircuitTimerState> emit) async {
    for (int i = 3; i > 0; i--) {
      emit(CircuitTimerInitial(i, 1, 1, "Get Ready"));
      await _playSound('beep.mp3');
      await Future.delayed(const Duration(seconds: 1));
    }
    await _playSound('start.mp3');
    _startNextSegment(emit, 1, 1, "Work", workTime);
  }

  void _onPaused(CircuitTimerPause event, Emitter<CircuitTimerState> emit) {
    if (state is CircuitTimerInProgress) {
      _tickerSubscription?.pause();
      emit(CircuitTimerPaused(state.duration, state.currentRound, state.currentStation, state.currentState));
    }
  }

  void _onResumed(CircuitTimerResumed event, Emitter<CircuitTimerState> emit) {
    if (state is CircuitTimerPaused) {
      _tickerSubscription?.resume();
      emit(CircuitTimerInProgress(state.duration, state.currentRound, state.currentStation, state.currentState));
    }
  }

  void _onReset(CircuitTimerReset event, Emitter<CircuitTimerState> emit) {
    _tickerSubscription?.cancel();
    add(const CircuitTimerStarted(duration: 0));
  }

  void _onTicked(_CircuitTimerTicked event, Emitter<CircuitTimerState> emit) async {
    if (event.duration > 0) {
      emit(CircuitTimerInProgress(event.duration, state.currentRound, state.currentStation, state.currentState));
    } else {
      await _playSound('end.mp3');
      _determineNextState(emit);
    }
  }
  
  void _determineNextState(Emitter<CircuitTimerState> emit) {
    if (state.currentState == "Work") {
      if (state.currentStation < stations) {
        _startNextSegment(emit, state.currentRound, state.currentStation + 1, "Rest", restTime);
      } else {
        if (state.currentRound < rounds) {
          _startNextSegment(emit, state.currentRound + 1, 1, "Round Rest", restBetweenRounds);
        } else {
          emit(const CircuitTimerComplete());
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
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: duration).listen((d) => add(_CircuitTimerTicked(duration: d)));
  }

  Future<void> _playSound(String sound) async {
    await _audioPlayer.play(AssetSource('sounds/$sound'));
  }
}
