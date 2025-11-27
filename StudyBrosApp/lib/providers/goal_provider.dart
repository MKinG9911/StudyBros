import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/hive_service.dart';

class GoalProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> fetchGoals() async {
    _isLoading = true;
    notifyListeners();
    try {
      _goals = await _hiveService.getGoals();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      await _hiveService.addGoal(goal);
      await fetchGoals();
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleGoalCompletion(Goal goal) async {
    try {
      goal.isCompleted = !goal.isCompleted;
      await _hiveService.updateGoal(goal);
      notifyListeners();
    } catch (e) {
      print(e);
      await fetchGoals();
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await _hiveService.updateGoal(goal);
      notifyListeners();
    } catch (e) {
      print(e);
      await fetchGoals();
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _hiveService.deleteGoal(id);
      await fetchGoals();
    } catch (e) {
      print(e);
    }
  }
}
