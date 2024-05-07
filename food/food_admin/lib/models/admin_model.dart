import 'package:hive_flutter/hive_flutter.dart';

part 'admin_model.g.dart';

@HiveType(typeId: 0)
class AdminModel {
  AdminModel({
    required this.username,
    required this.password,
  });

  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;
}
