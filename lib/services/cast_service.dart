import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

class CastService {
  static const _appId = 'CC1AD845'; // Default Media Receiver
  static const _namespace = 'urn:x-cast:com.gymtimer.data';

  final ChromeCastController _controller = ChromeCastController();
  final StreamController<bool> _connectionController = StreamController.broadcast();
  
  Stream<bool> get connectionStream => _connectionController.stream;
  bool isConnected = false;

  CastService() {
    _controller.onSessionStarted = () {
      debugPrint('CAST SESSION STARTED');
      _connectionController.add(true);
      isConnected = true;
    };
    
    _controller.onSessionEnded = () {
      debugPrint('CAST SESSION ENDED');
      _connectionController.add(false);
      isConnected = false;
    };

    _controller.onMessageReceived = (message) {
      debugPrint('CAST MESSAGE RECEIVED: $message');
      // Handle incoming messages if needed
    };
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    if (!isConnected) {
      debugPrint('Error: Not connected to a Cast device.');
      return;
    }
    
    final messageString = jsonEncode(message);
    
    try {
      await _controller.sendMessage(
        nameSpace: _namespace,
        message: messageString,
      );
      debugPrint('Sent message: $messageString');
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void updateTimer(String timeLeft, double progress, String state, int currentRound, int totalRounds, String nextExercise) {
    final payload = {
      'command': 'UPDATE_TIMER',
      'data': {
        'timeLeft': timeLeft,
        'progress': progress,
        'state': state,
        'currentRound': currentRound,
        'totalRounds': totalRounds,
        'nextExercise': nextExercise,
      }
    };
    _sendMessage(payload);
  }

  void dispose() {
    _connectionController.close();
  }
}
