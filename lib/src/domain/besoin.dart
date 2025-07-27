
import 'package:hive/hive.dart';
import 'package:besoins/src/domain/category.dart';

part 'besoin.g.dart';

@HiveType(typeId: 0) // Unique typeId for Besoin
class Besoin extends HiveObject {
  @HiveField(0)
  late String titre;
  @HiveField(1)
  String? description;
  @HiveField(2)
  late double prix;
  @HiveField(3)
  late DateTime date;
  
  @HiveField(4) // Link to Category
  Category? category;
}
