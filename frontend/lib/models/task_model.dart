import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  final DateTime date;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    required this.date,
  });

  // Keep fromJson and toJson for compatibility if needed
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isCompleted: json['isCompleted'] ?? false,
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
    };
  }
}
