
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import '../application/providers.dart';
import 'daily_budget.dart';

class DailyBudgetRepository {
  DailyBudgetRepository(this.ref);

  final Ref ref;

  Box<DailyBudget> get _dailyBudgetsBox => ref.read(hiveServiceProvider).dailyBudgetsBox;

  Future<DailyBudget?> getDailyBudget(DateTime date) async {
    // Hive doesn't have direct unique index query like Isar
    // We need to iterate and find by date (normalized to midnight)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _dailyBudgetsBox.values.firstWhereOrNull(
        (budget) => DateTime(budget.date.year, budget.date.month, budget.date.day) == normalizedDate);
  }

  Future<void> saveDailyBudget(DailyBudget budget) async {
    // If the budget already has a key, it means it's an existing object, so save it.
    // Otherwise, add it.
    if (budget.key != null) {
      await budget.save();
    } else {
      await _dailyBudgetsBox.add(budget);
    }
  }
}

final dailyBudgetRepositoryProvider = Provider((ref) => DailyBudgetRepository(ref));
