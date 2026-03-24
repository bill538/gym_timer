import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gym_timer/ticker/ticker.dart';
import 'package:audioplayers/audioplayers.dart';

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
    return super.close();
  }

  void _onStarted(TabataTimerStarted event, Emitter<TabataTimerState> emit) async {
    for (int i = 3; i > 0; i--) {
      emit(TabataTimerInitial(i, 1, "Get Ready"));
      await _playSound('beep.mp3');
      await Future.delayed(const Duration(seconds: 1));
    }
    await _playSound('start.mp3');
    _startNextSegment(emit, 1, "Work", workTime);
  }

  void _onPaused(TabataTimerPause event, Emitter<TabataTimerState> emit) {
    if (state is TabataTimerInProgress) {
      _tickerSubscription?.pause();
      emit(TabataTimerPaused(state.duration, state.currentRound, state.currentState));
    }
  }

  void _onResumed(TabataTimerResumed event, Emitter<TabataTimerState> emit) {
    if (state is TabataTimerPaused) {
      _tickerSubscription?.resume();
      emit(TabataTimerInProgress(state.duration, state.currentRound, state.currentState));
    }
  }

  void _onReset(TabataTimerReset event, Emitter<TabataTimerState> emit) {
    _tickerSubscription?.cancel();
    add(const TabataTimerStarted(duration: 0));
  }

  void _onTicked(_TabataTimerTicked event, Emitter<TabataTimerState> emit) async {
    if (event.duration > 0) {
      emit(TabataTimerInProgress(event.duration, state.currentRound, state.currentState));
    } else {
      await _playSound('end.mp3');
      _determineNextState(emit);
    }
  }
  
  void _determineNextState(Emitter<TabataTimerState> emit) {
    if (state.currentState == "Work") {
      if (state.currentRound < rounds) {
        _startNextSegment(emit, state.currentRound, "Rest", restTime);
      } else {
        emit(const TabataTimerComplete());
      }
    } else if (state.currentState == "Rest") {
      _startNextSegment(emit, state.currentRound + 1, "Work", workTime);
    }
  }

  void _startNextSegment(Emitter<TabataTimerState> emit, int round, String currentState, int duration) {
    emit(TabataTimerInProgress(duration, round, currentState));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: duration).listen((d) => add(_TabataTimerTicked(duration: d)));
  }

  Future<void> _playSound(String sound) async {
    await _audioPlayer.play(AssetSource('sounds/$sound'));
  }
}
