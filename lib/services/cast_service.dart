import 'dart:async';
import 'package:flutter/foundation.dart';

class CastService {
  final StreamController<bool> _connectionController = StreamController.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;
  bool isConnected = false;

  CastService() {
    // Placeholder implementation
  }

  void updateTimer(String timeLeft, double progress, String state, int currentRound, int totalRounds, String nextExercise) {
    debugPrint('CAST UPDATE: $timeLeft, $state, Round $currentRound/$totalRounds');
  }

  void dispose() {
    _connectionController.close();
  }
}
