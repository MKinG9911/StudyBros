import 'package:hive/hive.dart';

part 'class_routine_model.g.dart';

@HiveType(typeId: 5)
class ClassRoutine extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  String imagePath; // Local file path to the routine image

  @HiveField(3)
  DateTime uploadedAt;

  ClassRoutine({
    this.id,
    required this.userId,
    required this.imagePath,
    required this.uploadedAt,
  });

  factory ClassRoutine.fromJson(Map<String, dynamic> json) {
    return ClassRoutine(
      id: json['_id'],
      userId: json['userId'],
      imagePath: json['imagePath'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'imagePath': imagePath,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
