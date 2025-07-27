import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';
import '../application/providers.dart';
import '../domain/besoin_apart.dart';
import '../domain/besoin_apart_repository.dart';
import '../domain/category.dart';

class BesoinApartRepositoryImpl implements BesoinApartRepository {
  BesoinApartRepositoryImpl(this.ref);

  final Ref ref;

  Box<BesoinApart> get _besoinsApartBox => ref.read(hiveServiceProvider).besoinsApartBox;
  Box<Category> get _categoriesBox => ref.read(hiveServiceProvider).categoriesBox;

  @override
  Future<List<BesoinApart>> getAllBesoinsApart() async {
    return _besoinsApartBox.values.toList();
  }

  @override
  Future<void> addBesoinApart(BesoinApart besoinApart) async {
    // Ensure category is linked by ID if it's a new category or not yet in the box
    if (besoinApart.category != null && !besoinApart.category!.isInBox) {
      final existingCategory = _categoriesBox.values.firstWhereOrNull((cat) => cat.name == besoinApart.category!.name);
      if (existingCategory != null) {
        besoinApart.category = existingCategory; // Link to existing category object
      } else {
        await _categoriesBox.add(besoinApart.category!); // Add new category to box
      }
    }
    await _besoinsApartBox.add(besoinApart);
  }

  @override
  Future<void> deleteBesoinApart(dynamic key) async {
    await _besoinsApartBox.delete(key);
  }

  @override
  Future<void> updateBesoinApart(BesoinApart besoinApart) async {
    // Ensure category is linked by ID if it's a new category or not yet in the box
    if (besoinApart.category != null && !besoinApart.category!.isInBox) {
      final existingCategory = _categoriesBox.values.firstWhereOrNull((cat) => cat.name == besoinApart.category!.name);
      if (existingCategory != null) {
        besoinApart.category = existingCategory; // Link to existing category object
      } else {
        await _categoriesBox.add(besoinApart.category!); // Add new category to box
      }
    }
    await besoinApart.save(); // Save changes to the existing object
  }

  @override
  Future<List<String>> getAllGroupTitles() async {
    final allBesoins = await getAllBesoinsApart();
    return allBesoins.map((b) => b.groupTitle).toSet().toList()..sort();
  }

  @override
  Future<List<BesoinApart>> getBesoinsByGroupTitle(String groupTitle) async {
    final allBesoins = await getAllBesoinsApart();
    return allBesoins.where((b) => b.groupTitle == groupTitle).toList();
  }

  @override
  Future<void> updateGroupBudget(String groupTitle, bool hasBudget, double? budgetAmount) async {
    final groupBesoins = await getBesoinsByGroupTitle(groupTitle);
    for (final besoin in groupBesoins) {
      besoin.hasBudget = hasBudget;
      besoin.budgetAmount = budgetAmount;
      await besoin.save();
    }
  }

  @override
  Future<BesoinApart?> getGroupBudgetInfo(String groupTitle) async {
    final groupBesoins = await getBesoinsByGroupTitle(groupTitle);
    return groupBesoins.isNotEmpty ? groupBesoins.first : null;
  }
}

final besoinApartRepositoryProvider = Provider<BesoinApartRepository>((ref) => BesoinApartRepositoryImpl(ref));
