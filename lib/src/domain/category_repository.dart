
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../application/providers.dart';
import 'category.dart';

class CategoryRepository {
  CategoryRepository(this.ref);

  final Ref ref;

  Box<Category> get _categoriesBox => ref.read(hiveServiceProvider).categoriesBox;

  Future<List<Category>> getAllCategories() async {
    return _categoriesBox.values.toList();
  }

  Future<void> saveCategory(Category category) async {
    // If the category already has a key, it means it's an existing object, so save it.
    // Otherwise, add it.
    if (category.key != null) {
      await category.save();
    } else {
      await _categoriesBox.add(category);
    }
  }

  Future<void> deleteCategory(int id) async {
    await _categoriesBox.delete(id);
  }
}

final categoryRepositoryProvider = Provider((ref) => CategoryRepository(ref));
