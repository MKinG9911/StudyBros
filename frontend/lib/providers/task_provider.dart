import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';

class TaskProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _hiveService.getTasks();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _hiveService.addTask(task);
      await fetchTasks(); // Refresh list
    } catch (e) {
      print(e);
    }
  }

  Future<void> addMultipleTasks(List<Task> tasks) async {
    try {
      for (var task in tasks) {
        await _hiveService.addTask(task);
      }
      await fetchTasks(); // Refresh list once after all adds
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      task.isCompleted = !task.isCompleted;
      await _hiveService.updateTask(task);
      notifyListeners();
    } catch (e) {
      print(e);
      await fetchTasks(); // Revert on error
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _hiveService.deleteTask(id);
      await fetchTasks();
    } catch (e) {
      print(e);
    }
  }
}
