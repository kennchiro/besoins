
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'hive_service.dart'; // Import HiveService
import '../domain/daily_budget_repository.dart';
import 'report_service.dart';

// No need for part 'providers.g.dart'; as we removed riverpod_generator

final hiveServiceProvider = Provider((ref) => HiveService());

final dailyBudgetRepositoryProvider = Provider((ref) => DailyBudgetRepository(ref));

final reportServiceProvider = Provider((ref) => ReportService());
