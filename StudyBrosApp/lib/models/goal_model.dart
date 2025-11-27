import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 2)
class Goal extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  final DateTime weekStartDate;

  @HiveField(5)
  String day; // e.g., "Saturday", "Sunday"

  Goal({
    this.id,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    required this.weekStartDate,
    required this.day,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      weekStartDate: DateTime.parse(json['weekStartDate']),
      day: json['day'] ?? 'Saturday',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'isCompleted': isCompleted,
      'weekStartDate': weekStartDate.toIso8601String(),
      'day': day,
    };
  }
}
