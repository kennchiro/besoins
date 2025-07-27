import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/besoin.dart';
import '../domain/besoin_repository.dart';

class BesoinNotifier extends StateNotifier<AsyncValue<List<Besoin>>> {
  BesoinNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadBesoins();
  }

  final Ref ref;

  Future<void> _loadBesoins() async {
    state = const AsyncValue.loading();
    try {
      final besoins = await ref.read(besoinRepositoryProvider).getAllBesoins();
      state = AsyncValue.data(besoins);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBesoin(Besoin besoin) async {
    await ref.read(besoinRepositoryProvider).addBesoin(besoin);
    _loadBesoins();
  }

  Future<void> deleteBesoin(int id) async {
    await ref.read(besoinRepositoryProvider).deleteBesoin(id);
    _loadBesoins();
  }

  Future<void> updateBesoin(Besoin besoin) async {
    await ref.read(besoinRepositoryProvider).updateBesoin(besoin);
    _loadBesoins();
  }

  Future<void> deleteAllBesoinsForDate(DateTime date) async {
    await ref.read(besoinRepositoryProvider).deleteAllBesoinsForDate(date);
    _loadBesoins();
  }
}

final besoinNotifierProvider = StateNotifierProvider<BesoinNotifier, AsyncValue<List<Besoin>>>((ref) {
  return BesoinNotifier(ref);
});