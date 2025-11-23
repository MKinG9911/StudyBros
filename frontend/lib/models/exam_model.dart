import 'package:hive/hive.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 3)
class Exam extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  String subject;

  @HiveField(3)
  DateTime examDate;

  @HiveField(4)
  List<SyllabusTopic> syllabus;

  @HiveField(5)
  bool notificationsEnabled;

  Exam({
    this.id,
    required this.userId,
    required this.subject,
    required this.examDate,
    List<SyllabusTopic>? syllabus,
    this.notificationsEnabled = true,
  }) : syllabus = syllabus ?? [];

  // Days remaining until exam
  int get daysRemaining {
    final now = DateTime.now();
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return examDay.difference(today).inDays;
  }

  // Completion percentage of syllabus
  double get completionPercentage {
    if (syllabus.isEmpty) return 0;
    final completed = syllabus.where((topic) => topic.isCompleted).length;
    return (completed / syllabus.length) * 100;
  }

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['_id'],
      userId: json['userId'],
      subject: json['subject'],
      examDate: DateTime.parse(json['examDate']),
      syllabus: (json['syllabus'] as List?)
          ?.map((e) => SyllabusTopic.fromJson(e))
          .toList(),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'subject': subject,
      'examDate': examDate.toIso8601String(),
      'syllabus': syllabus.map((e) => e.toJson()).toList(),
      'notificationsEnabled': notificationsEnabled,
    };
  }
}

@HiveType(typeId: 30)
class SyllabusTopic {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  SyllabusTopic({required this.title, this.isCompleted = false});

  factory SyllabusTopic.fromJson(Map<String, dynamic> json) {
    return SyllabusTopic(
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isCompleted': isCompleted};
  }
}
