import 'package:hive/hive.dart';
import 'package:besoins/src/domain/category.dart';

part 'besoin_apart.g.dart';

@HiveType(typeId: 3) // Unique typeId for BesoinApart
class BesoinApart extends HiveObject {
  @HiveField(0)
  late String titre;
  
  @HiveField(1)
  String? description;
  
  @HiveField(2)
  late double prix;
  
  @HiveField(3)
  late DateTime dateCreated; // When it was added
  
  @HiveField(4) // Link to Category
  Category? category;
  
  @HiveField(5)
  late String groupTitle; // Title for grouping these needs
  
  @HiveField(6)
  bool isCompleted; // Whether this need has been fulfilled
  
  @HiveField(7)
  bool hasBudget; // Whether this group has a budget
  
  @HiveField(8)
  double? budgetAmount; // Budget amount for this group (only if hasBudget is true)
  
  BesoinApart() : isCompleted = false, hasBudget = false;
}
