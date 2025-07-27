
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../application/besoin_notifier.dart';
import '../../domain/besoin.dart';

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  ConsumerState<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final besoinsState = ref.watch(besoinNotifierProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: besoinsState.when(
        data: (besoins) => besoins.isEmpty
            ? const _EmptyState()
            : _MonthlySummaryContent(besoins: besoins, focusedMonth: _focusedMonth), // Pass focusedMonth
        loading: () => const _LoadingState(),
        error: (error, stackTrace) => _ErrorState(error: error), // Pass ref to _ErrorState
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(DateFormat('MMMM yyyy', 'fr_FR').format(_focusedMonth)), // Display current month
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtrer',
          onPressed: () {
            // TODO: Implement filter functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filtres à venir')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Trier',
          onPressed: () {
            // TODO: Implement sort functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tri à venir')),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun besoin pour le moment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des besoins pour voir le résumé mensuel',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement du résumé mensuel...'),
        ],
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget { // Changed to ConsumerWidget
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef ref
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
             return ref.refresh(besoinNotifierProvider); // Fixed refresh functionality
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _MonthlySummaryContent extends ConsumerWidget {
  const _MonthlySummaryContent({required this.besoins, required this.focusedMonth});

  final List<Besoin> besoins;
  final DateTime focusedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter besoins based on focusedMonth
    final filteredBesoins = besoins.where((besoin) =>
        besoin.date.year == focusedMonth.year &&
        besoin.date.month == focusedMonth.month).toList();

    final summaryData = ref.watch(monthlySummaryProvider(filteredBesoins));

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(besoinNotifierProvider);
      },
      child: Column(
        children: [
          _SummaryHeader(summaryData: summaryData),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: summaryData.monthlyData.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final monthData = summaryData.monthlyData[index];
                return _MonthlyCard(
                  monthData: monthData,
                  isHighestSpending: monthData.total == summaryData.highestMonthlySpending,
                  isLowestSpending: monthData.total == summaryData.lowestMonthlySpending,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.summaryData});

  final MonthlySummaryData summaryData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aperçu Général',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Global',
                  value: NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: 'MGA',
                    decimalDigits: 0,
                  ).format(summaryData.totalSpending),
                  icon: Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  label: 'Moyenne Mensuelle',
                  value: NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: 'MGA',
                    decimalDigits: 0,
                  ).format(summaryData.averageMonthlySpending),
                  icon: Icons.trending_up,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Mois Actuel',
                  value: NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: 'MGA',
                    decimalDigits: 0,
                  ).format(summaryData.currentMonthSpending),
                  icon: Icons.calendar_today,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  label: 'Nombre de Mois',
                  value: summaryData.monthlyData.length.toString(),
                  icon: Icons.date_range,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard({
    required this.monthData,
    required this.isHighestSpending,
    required this.isLowestSpending,
  });

  final MonthlyData monthData;
  final bool isHighestSpending;
  final bool isLowestSpending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isHighestSpending || isLowestSpending ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isHighestSpending
              ? Border.all(color: theme.colorScheme.error, width: 2)
              : isLowestSpending
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighestSpending
                  ? theme.colorScheme.errorContainer
                  : isLowestSpending
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_month,
              color: isHighestSpending
                  ? theme.colorScheme.onErrorContainer
                  : isLowestSpending
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
            ),
          ),
          title: Text(
            monthData.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${monthData.itemCount} besoin${monthData.itemCount > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'MGA',
                  decimalDigits: 0,
                ).format(monthData.total),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHighestSpending
                      ? theme.colorScheme.error
                      : isLowestSpending
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                ),
              ),
              if (isHighestSpending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0), // Changed vertical from 2 to 0
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Plus élevé',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10.0, // Reduced font size
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isLowestSpending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0), // Changed vertical from 2 to 0
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Plus bas',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10.0, // Reduced font size
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Détails du mois',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Dépense moyenne par besoin',
                    value: NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: 'MGA',
                      decimalDigits: 0,
                    ).format(monthData.averagePerItem),
                  ),
                  _DetailRow(
                    label: 'Dépense la plus élevée',
                    value: NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: 'MGA',
                      decimalDigits: 0,
                    ).format(monthData.highestExpense),
                  ),
                  _DetailRow(
                    label: 'Dépense la plus basse',
                    value: NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: 'MGA',
                      decimalDigits: 0,
                    ).format(monthData.lowestExpense),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Catégories principales',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...monthData.topCategories.take(3).map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.name,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'fr_FR',
                              symbol: 'MGA',
                              decimalDigits: 0,
                            ).format(category.total),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Data models and providers
class MonthlyData {
  const MonthlyData({
    required this.year,
    required this.month,
    required this.displayName,
    required this.total,
    required this.itemCount,
    required this.averagePerItem,
    required this.highestExpense,
    required this.lowestExpense,
    required this.topCategories,
    required this.besoins,
  });

  final int year;
  final int month;
  final String displayName;
  final double total;
  final int itemCount;
  final double averagePerItem;
  final double highestExpense;
  final double lowestExpense;
  final List<CategoryData> topCategories;
  final List<Besoin> besoins;
}

class CategoryData {
  const CategoryData({
    required this.name,
    required this.total,
    required this.count,
  });

  final String name;
  final double total;
  final int count;
}

class MonthlySummaryData {
  const MonthlySummaryData({
    required this.monthlyData,
    required this.totalSpending,
    required this.averageMonthlySpending,
    required this.currentMonthSpending,
    required this.highestMonthlySpending,
    required this.lowestMonthlySpending,
  });

  final List<MonthlyData> monthlyData;
  final double totalSpending;
  final double averageMonthlySpending;
  final double currentMonthSpending;
  final double lowestMonthlySpending;
  final double highestMonthlySpending;
}

/// Provider that calculates and provides monthly summary data based on a list of Besoins.
/// It groups expenses by month, calculates totals, averages, highest/lowest expenses,
/// and identifies top categories for each month.
final monthlySummaryProvider = Provider.family<MonthlySummaryData, List<Besoin>>((ref, List<Besoin> besoins) {
  if (besoins.isEmpty) {
    return const MonthlySummaryData(
      monthlyData: [],
      totalSpending: 0,
      averageMonthlySpending: 0,
      currentMonthSpending: 0,
      highestMonthlySpending: 0,
      lowestMonthlySpending: 0,
    );
  }

  final groupedBesoins = groupBy(besoins, (Besoin b) => '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}');
  final sortedKeys = groupedBesoins.keys.toList()..sort((a, b) => b.compareTo(a));

  final monthlyData = sortedKeys.map((key) {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final monthBesoins = groupedBesoins[key]!;

    final total = monthBesoins.fold<double>(0, (sum, b) => sum + b.prix);
    final prices = monthBesoins.map((b) => b.prix).toList();
    
    final categoryTotals = <String, double>{};
    for (final besoin in monthBesoins) {
      // Use category name if available, otherwise fallback to titre
      final categoryName = besoin.category?.name ?? besoin.titre; // Changed from .value?.name
      categoryTotals.update(categoryName, (value) => value + besoin.prix, ifAbsent: () => besoin.prix);
    }
    
    final topCategories = categoryTotals.entries
        .map((e) => CategoryData(name: e.key, total: e.value, count: monthBesoins.where((b) => (b.category?.name ?? b.titre) == e.key).length)) // Changed from .value?.name
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return MonthlyData(
      year: year,
      month: month,
      displayName: DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(year, month)),
      total: total,
      itemCount: monthBesoins.length,
      averagePerItem: total / monthBesoins.length,
      highestExpense: prices.isEmpty ? 0 : prices.reduce((a, b) => a > b ? a : b),
      lowestExpense: prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b),
      topCategories: topCategories,
      besoins: monthBesoins,
    );
  }).toList();

  final totalSpending = monthlyData.fold<double>(0, (sum, data) => sum + data.total);
  final averageMonthlySpending = monthlyData.isEmpty ? 0 : totalSpending / monthlyData.length;
  
  final currentMonth = DateTime.now();
  final currentMonthSpending = monthlyData
      .where((data) => data.year == currentMonth.year && data.month == currentMonth.month) // Corrected comparison
      .fold<double>(0, (sum, data) => sum + data.total);

  final monthlyTotals = monthlyData.map((data) => data.total).toList();
  final highestMonthlySpending = monthlyTotals.isEmpty ? 0 : monthlyTotals.reduce((a, b) => a > b ? a : b);
  final lowestMonthlySpending = monthlyTotals.isEmpty ? 0 : monthlyTotals.reduce((a, b) => a < b ? a : b);

  return MonthlySummaryData(
    monthlyData: monthlyData,
    totalSpending: totalSpending,
    averageMonthlySpending: averageMonthlySpending.toDouble(),
    currentMonthSpending: currentMonthSpending,
    highestMonthlySpending: highestMonthlySpending.toDouble(),
    lowestMonthlySpending: lowestMonthlySpending.toDouble(),
  );
});
