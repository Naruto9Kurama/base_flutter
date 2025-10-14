import 'package:hive_ce/hive.dart';

part 'test_user.g.dart';
///仅用于生成hive_registrar.g.dart文件
@HiveType(typeId: 0)
class TestUser extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  TestUser({required this.name, required this.age});
}
