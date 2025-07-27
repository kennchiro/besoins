import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/daily_budget.dart';
import '../domain/daily_budget_repository.dart';

class DailyBudgetNotifier extends StateNotifier<AsyncValue<DailyBudget?>> {
  DailyBudgetNotifier(this.ref, DateTime date) : super(const AsyncValue.loading()) {
    _loadDailyBudget(date);
  }

  final Ref ref;

  Future<void> _loadDailyBudget(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final budget = await ref.read(dailyBudgetRepositoryProvider).getDailyBudget(date);
      state = AsyncValue.data(budget);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveDailyBudget(DailyBudget newBudget) async {
    try {
      final existingBudget = await ref.read(dailyBudgetRepositoryProvider).getDailyBudget(newBudget.date);
      if (existingBudget != null) {
        // Update existing budget
        existingBudget.amount = newBudget.amount;
        await ref.read(dailyBudgetRepositoryProvider).saveDailyBudget(existingBudget);
      } else {
        // Save new budget
        await ref.read(dailyBudgetRepositoryProvider).saveDailyBudget(newBudget);
      }
      _loadDailyBudget(newBudget.date);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dailyBudgetNotifierProvider = StateNotifierProvider.family<DailyBudgetNotifier, AsyncValue<DailyBudget?>, DateTime>((ref, date) {
  return DailyBudgetNotifier(ref, date);
});