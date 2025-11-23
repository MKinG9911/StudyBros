import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? profilePicturePath;

  @HiveField(2)
  String? institutionName;

  @HiveField(3)
  String? institutionId;

  @HiveField(4)
  String? department;

  User({
    this.name = 'Student',
    this.profilePicturePath,
    this.institutionName,
    this.institutionId,
    this.department,
  });
}
