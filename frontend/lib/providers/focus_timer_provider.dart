import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusTimerProvider with ChangeNotifier {
  int durationMinutes = 25; // Default Pomodoro duration
  int _remainingSeconds = 1500; // 25 minutes in seconds
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;

  // New features
  String _focusText = "Stay focused no matter what brings you down";
  bool _isScreenOn = false;

  FocusTimerProvider() {
    _loadPreferences();
  }

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  String get focusText => _focusText;
  bool get isScreenOn => _isScreenOn;

  String get displayTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    final totalSeconds = durationMinutes * 60;
    return (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  int get elapsedSeconds {
    return (durationMinutes * 60) - _remainingSeconds;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _focusText =
        prefs.getString('focus_text') ??
        "Stay focused no matter what brings you down";
    notifyListeners();
  }

  Future<void> updateFocusText(String newText) async {
    if (newText.length > 100) return;
    _focusText = newText;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('focus_text', newText);
    notifyListeners();
  }

  void toggleScreenOn() {
    _isScreenOn = !_isScreenOn;
    if (_isScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    notifyListeners();
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _isPaused = false;
    if (_isScreenOn)
      WakelockPlus.enable(); // Ensure wake lock is active if enabled
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
    WakelockPlus.disable(); // Disable wake lock when paused to save battery
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = durationMinutes * 60;
    WakelockPlus.disable();
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
    WakelockPlus.disable();

    // Show notification - TEMPORARILY DISABLED
    // NotificationService.showTimerComplete();

    // Reset for next session
    _remainingSeconds = durationMinutes * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}
