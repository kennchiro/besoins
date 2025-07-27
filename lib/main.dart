
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:besoins/src/presentation/routing/app_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:besoins/src/application/initial_data_service.dart';
import 'package:besoins/src/application/hive_service.dart'; // Import HiveService

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  Intl.defaultLocale = 'fr_FR';

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.initHive();

  // Initialize Riverpod and then the initial data service
  final container = ProviderContainer();
  await container.read(initialDataServiceProvider).initializeCategories();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: appRouter,
    );
  }
}
