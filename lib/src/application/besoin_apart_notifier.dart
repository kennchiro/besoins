import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/besoin_apart.dart';
import '../infrastructure/besoin_apart_repository_impl.dart';

class BesoinApartNotifier extends StateNotifier<AsyncValue<List<BesoinApart>>> {
  BesoinApartNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadBesoinsApart();
  }

  final Ref ref;

  Future<void> _loadBesoinsApart() async {
    state = const AsyncValue.loading();
    try {
      final besoinsApart = await ref.read(besoinApartRepositoryProvider).getAllBesoinsApart();
      state = AsyncValue.data(besoinsApart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBesoinApart(BesoinApart besoinApart) async {
    await ref.read(besoinApartRepositoryProvider).addBesoinApart(besoinApart);
    _loadBesoinsApart();
  }

  Future<void> deleteBesoinApart(dynamic key) async {
    await ref.read(besoinApartRepositoryProvider).deleteBesoinApart(key);
    _loadBesoinsApart();
  }

  Future<void> updateBesoinApart(BesoinApart besoinApart) async {
    await ref.read(besoinApartRepositoryProvider).updateBesoinApart(besoinApart);
    _loadBesoinsApart();
  }

  Future<List<String>> getAllGroupTitles() async {
    return await ref.read(besoinApartRepositoryProvider).getAllGroupTitles();
  }

  Future<List<BesoinApart>> getBesoinsByGroupTitle(String groupTitle) async {
    return await ref.read(besoinApartRepositoryProvider).getBesoinsByGroupTitle(groupTitle);
  }
}

final besoinApartNotifierProvider = StateNotifierProvider<BesoinApartNotifier, AsyncValue<List<BesoinApart>>>((ref) {
  return BesoinApartNotifier(ref);
});
