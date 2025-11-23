import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  final DateTime? createdAt;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  List<String> imagePaths;

  @HiveField(8)
  List<String> pdfPaths;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.createdAt,
    this.colorValue = 0xFFFFFFFF,
    this.isFavorite = false,
    this.imagePaths = const [],
    this.pdfPaths = const [],
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'title': title, 'content': content};
  }
}
