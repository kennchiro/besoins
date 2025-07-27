import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2) // Unique typeId for Category
class Category extends HiveObject {
  @HiveField(0)
  late String name;
}