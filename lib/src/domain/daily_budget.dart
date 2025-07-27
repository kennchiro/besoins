import 'package:hive/hive.dart';

part 'daily_budget.g.dart';

@HiveType(typeId: 1) // Unique typeId for DailyBudget
class DailyBudget extends HiveObject {
  @HiveField(0)
  late DateTime date;
  @HiveField(1)
  late double amount;
}