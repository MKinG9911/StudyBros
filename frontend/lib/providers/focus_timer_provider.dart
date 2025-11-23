import 'dart:async';
import 'package:flutter/material.dart';
// import '../services/notification_service.dart'; // Temporarily disabled

class FocusTimerProvider with ChangeNotifier {
  int durationMinutes = 25; // Default Pomodoro duration
  int _remainingSeconds = 1500; // 25 minutes in seconds
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  String get displayTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    final totalSeconds = durationMinutes * 60;
    return (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _isPaused = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeTimer();
      }
    });
  }

  void pauseTimer() {
    if (!_isRunning) return;

    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = durationMinutes * 60;
    notifyListeners();
  }

  void setDuration(int minutes) {
    if (_isRunning) return; // Can't change duration while running

    durationMinutes = minutes;
    _remainingSeconds = minutes * 60;
    notifyListeners();
  }

  void _completeTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;

    // Show notification - TEMPORARILY DISABLED
    // NotificationService.showTimerComplete();

    // Reset for next session
    _remainingSeconds = durationMinutes * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
