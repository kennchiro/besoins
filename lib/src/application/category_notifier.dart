import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  CategoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  final Ref ref;

  Future<void> _loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await ref.read(categoryRepositoryProvider).getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).saveCategory(category);
    _loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await ref.read(categoryRepositoryProvider).deleteCategory(id);
    _loadCategories();
  }
}

final categoryNotifierProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoryNotifier(ref);
});