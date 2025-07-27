import 'besoin_apart.dart';

abstract class BesoinApartRepository {
  Future<List<BesoinApart>> getAllBesoinsApart();
  Future<void> addBesoinApart(BesoinApart besoinApart);
  Future<void> updateBesoinApart(BesoinApart besoinApart);
  Future<void> deleteBesoinApart(dynamic key);
  Future<List<String>> getAllGroupTitles();
  Future<List<BesoinApart>> getBesoinsByGroupTitle(String groupTitle);
  Future<void> updateGroupBudget(String groupTitle, bool hasBudget, double? budgetAmount);
  Future<BesoinApart?> getGroupBudgetInfo(String groupTitle);
}
