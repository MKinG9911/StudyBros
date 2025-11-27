import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/note_model.dart';
import '../models/goal_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web/Windows
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://localhost:5000/api';
  }

  // Tasks
  Future<List<Task>> getTasks(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Task.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(String id, Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  // Notes
  Future<List<Note>> getNotes(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/notes/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Note.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<Note> createNote(Note note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(note.toJson()),
    );
    if (response.statusCode == 200) {
      return Note.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create note');
    }
  }

  // Goals
  Future<List<Goal>> getGoals(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/goals/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Goal.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load goals');
    }
  }

  Future<Goal> createGoal(Goal goal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(goal.toJson()),
    );
    if (response.statusCode == 200) {
      return Goal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create goal');
    }
  }

  Future<Goal> updateGoal(String id, Goal goal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/goals/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(goal.toJson()),
    );
    if (response.statusCode == 200) {
      return Goal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update goal');
    }
  }

  Future<void> deleteGoal(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/goals/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete goal');
    }
  }
}
