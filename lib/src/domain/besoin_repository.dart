
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import '../application/providers.dart';
import 'besoin.dart';
import 'category.dart';

class BesoinRepository {
  BesoinRepository(this.ref);

  final Ref ref;

  Box<Besoin> get _besoinsBox => ref.read(hiveServiceProvider).besoinsBox;
  Box<Category> get _categoriesBox => ref.read(hiveServiceProvider).categoriesBox;

  Future<List<Besoin>> getAllBesoins() async {
    return _besoinsBox.values.toList();
  }

  Future<void> addBesoin(Besoin besoin) async {
    // Ensure category is linked by ID if it's a new category or not yet in the box
    if (besoin.category != null && !besoin.category!.isInBox) {
      final existingCategory = _categoriesBox.values.firstWhereOrNull((cat) => cat.name == besoin.category!.name);
      if (existingCategory != null) {
        besoin.category = existingCategory; // Link to existing category object
      } else {
        await _categoriesBox.add(besoin.category!); // Add new category to box
      }
    }
    await _besoinsBox.add(besoin);
  }

  Future<void> deleteBesoin(int id) async {
    await _besoinsBox.delete(id);
  }

  Future<void> updateBesoin(Besoin besoin) async {
    // Ensure category is linked by ID if it's a new category or not yet in the box
    if (besoin.category != null && !besoin.category!.isInBox) {
      final existingCategory = _categoriesBox.values.firstWhereOrNull((cat) => cat.name == besoin.category!.name);
      if (existingCategory != null) {
        besoin.category = existingCategory; // Link to existing category object
      } else {
        await _categoriesBox.add(besoin.category!); // Add new category to box
      }
    }
    await besoin.save(); // Save changes to the existing object
  }

  Future<void> deleteAllBesoinsForDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final besoinsToDelete = _besoinsBox.values.where(
        (besoin) => DateTime(besoin.date.year, besoin.date.month, besoin.date.day) == normalizedDate
    ).toList();

    for (var besoin in besoinsToDelete) {
      await besoin.delete(); // Delete each Besoin object
    }
  }
}

final besoinRepositoryProvider = Provider((ref) => BesoinRepository(ref));
