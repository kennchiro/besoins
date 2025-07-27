
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/besoin.dart';
import '../domain/daily_budget.dart';
import '../domain/category.dart';
import '../domain/besoin_apart.dart';

class HiveService {
  Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(BesoinAdapter());
    Hive.registerAdapter(DailyBudgetAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(BesoinApartAdapter());

    // Open boxes
    await Hive.openBox<Besoin>('besoins');
    await Hive.openBox<DailyBudget>('dailyBudgets');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<BesoinApart>('besoinsApart');
  }

  Box<Besoin> get besoinsBox => Hive.box<Besoin>('besoins');
  Box<DailyBudget> get dailyBudgetsBox => Hive.box<DailyBudget>('dailyBudgets');
  Box<Category> get categoriesBox => Hive.box<Category>('categories');
  Box<BesoinApart> get besoinsApartBox => Hive.box<BesoinApart>('besoinsApart');
}
