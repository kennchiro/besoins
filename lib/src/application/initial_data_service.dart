import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import 'providers.dart'; // Import providers to get hiveServiceProvider

class InitialDataService {
  final Ref ref;

  InitialDataService(this.ref);

  Future<void> initializeCategories() async {
    final categoryRepository = ref.read(categoryRepositoryProvider);
    final existingCategories = await categoryRepository.getAllCategories();

    if (existingCategories.isEmpty) {
      final defaultCategories = [
        Category()..name = 'Alimentation',
        Category()..name = 'Transport',
        Category()..name = 'Santé',
        Category()..name = 'Éducation',
        Category()..name = 'Loisirs',
        Category()..name = 'Vêtements',
        Category()..name = 'Maison',
        Category()..name = 'Autre',
      ];

      for (var category in defaultCategories) {
        await categoryRepository.saveCategory(category);
      }
    }
  }
}

final initialDataServiceProvider = Provider((ref) => InitialDataService(ref));