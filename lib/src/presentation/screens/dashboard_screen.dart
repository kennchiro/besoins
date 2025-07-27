

import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../application/besoin_notifier.dart';
import '../../application/report_service.dart';
import '../../domain/besoin.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final besoinsState = ref.watch(besoinNotifierProvider);
    final reportService = ref.read(reportServiceProvider);

    return Scaffold(
      appBar: _buildAppBar(context, besoinsState, reportService),
      body: besoinsState.when(
        data: (besoins) => besoins.isEmpty
            ? const _EmptyState()
            : _DashboardContent(besoins: besoins),
        loading: () => const _LoadingState(),
        error: (error, stackTrace) => _ErrorState(error: error),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncValue<List<Besoin>> besoinsState,
    ReportService reportService,
  ) {
    return AppBar(
      title: const Text('Dashboard'),
      elevation: 0,
      actions: [
        _ExportButton(
          icon: Icons.picture_as_pdf,
          tooltip: 'Export PDF',
          onPressed: besoinsState.maybeWhen(
            data: (besoins) => () => _exportPdf(context, reportService, besoins),
            orElse: () => null,
          ),
        ),
        _ExportButton(
          icon: Icons.table_chart,
          tooltip: 'Export Excel',
          onPressed: besoinsState.maybeWhen(
            data: (besoins) => () => _exportExcel(context, reportService, besoins),
            orElse: () => null,
          ),
        ),
      ],
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    ReportService reportService,
    List<Besoin> besoins,
  ) async {
    try {
      await reportService.exportToPdf(besoins);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Rapport PDF exporté avec succès');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors de l\'export PDF: $e');
      }
    }
  }

  Future<void> _exportExcel(
    BuildContext context,
    ReportService reportService,
    List<Besoin> besoins,
  ) async {
    try {
      await reportService.exportToExcel(besoins);
      if (context.mounted) {
        _showSuccessSnackBar(context, 'Rapport Excel exporté avec succès');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors de l\'export Excel: $e');
      }
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Aucune donnée à afficher',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez des besoins pour voir les statistiques',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
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
          Text('Chargement des données...'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Trigger a refresh - you'll need to implement this
              // ref.refresh(besoinNotifierProvider);
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.besoins});

  final List<Besoin> besoins;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(dashboardAnalyticsProvider(besoins));
    
    return RefreshIndicator(
      onRefresh: () async {
        return ref.refresh(besoinNotifierProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BudgetProjectionsCard(analytics: analytics),
            const SizedBox(height: 24),
            _MonthlyComparisonChart(besoins: besoins),
            const SizedBox(height: 24),
            _DailySpendingChart(besoins: besoins),
            const SizedBox(height: 24),
            _CategorySpendingChart(besoins: besoins),
            const SizedBox(height: 24),
            _SpendingHeatmap(besoins: besoins),
          ],
        ),
      ),
    );
  }
}

class _BudgetProjectionsCard extends StatelessWidget {
  const _BudgetProjectionsCard({required this.analytics});

  final DashboardAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Projections Budgétaires',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProjectionTile(
                    title: '3 mois',
                    amount: analytics.threeMonthProjection,
                    icon: Icons.calendar_view_month,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProjectionTile(
                    title: '6 mois',
                    amount: analytics.sixMonthProjection,
                    icon: Icons.calendar_today,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Basé sur les tendances des ${analytics.dataPoints} derniers mois',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectionTile extends StatelessWidget {
  const _ProjectionTile({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat.currency(locale: 'fr_FR', symbol: 'MGA').format(amount)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.child,
    this.height = 200,
  });

  final String title;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: child,
            ),
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MonthlyComparisonChart extends StatelessWidget {
  const _MonthlyComparisonChart({required this.besoins});

  final List<Besoin> besoins;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Comparaisons Mensuelles',
      child: BarChart(_getMonthlyComparisonData()),
    );
  }

  BarChartData _getMonthlyComparisonData() {
    final monthlySpending = groupBy(besoins, (Besoin b) => DateFormat('MMM yyyy').format(b.date));
    final sortedMonths = monthlySpending.keys.toList()
      ..sort((a, b) => DateFormat('MMM yyyy').parse(a).compareTo(DateFormat('MMM yyyy').parse(b)));

    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      maxY: monthlySpending.values
          .map((besoins) => besoins.fold<double>(0, (prev, element) => prev + element.prix))
          .fold(0.0, max) * 1.1,
      barGroups: sortedMonths.asMap().entries.map((entry) {
        final index = entry.key;
        final month = entry.value;
        final total = monthlySpending[month]!.fold<double>(0, (prev, element) => prev + element.prix);
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: total,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= sortedMonths.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  sortedMonths[value.toInt()].split(' ')[0],
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
            reservedSize: 32,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                NumberFormat.compact(locale: 'fr_FR').format(value),
                style: const TextStyle(fontSize: 12),
              );
            },
            reservedSize: 60,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
    );
  }
}

class _DailySpendingChart extends StatelessWidget {
  const _DailySpendingChart({required this.besoins});

  final List<Besoin> besoins;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Dépenses des 7 derniers jours',
      child: LineChart(_getDailySpendingData()),
    );
  }

  LineChartData _getDailySpendingData() {
    final dailySpending = <DateTime, double>{};
    final today = DateTime.now();
    
    // Initialize last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day - i);
      dailySpending[date] = 0;
    }

    // Populate with actual data
    for (final besoin in besoins) {
      final date = DateTime(besoin.date.year, besoin.date.month, besoin.date.day);
      if (dailySpending.containsKey(date)) {
        dailySpending[date] = dailySpending[date]! + besoin.prix;
      }
    }

    final spots = dailySpending.entries
        .map((entry) => FlSpot(entry.key.day.toDouble(), entry.value))
        .toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              );
            },
            reservedSize: 32,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                NumberFormat.compact(locale: 'fr_FR').format(value),
                style: const TextStyle(fontSize: 12),
              );
            },
            reservedSize: 60,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.green.shade600,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.green.shade400.withOpacity(0.3),
                Colors.green.shade600.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategorySpendingChart extends StatelessWidget {
  const _CategorySpendingChart({required this.besoins});

  final List<Besoin> besoins;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Répartition par catégorie',
      child: PieChart(_getCategorySpendingData()),
    );
  }

  PieChartData _getCategorySpendingData() {
    final categorySpending = <String, double>{};
    for (final besoin in besoins) {
      // Use category name if available, otherwise fallback to titre
      final categoryName = besoin.category?.name ?? besoin.titre;
      categorySpending.update(
        categoryName,
        (value) => value + besoin.prix,
        ifAbsent: () => besoin.prix,
      );
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 60,
      sections: categorySpending.entries.map((entry) {
        final index = categorySpending.keys.toList().indexOf(entry.key);
        final color = colors[index % colors.length];
        final total = categorySpending.values.fold(0.0, (a, b) => a + b);
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        
        return PieChartSectionData(
          value: entry.value,
          title: '$percentage%',
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: color,
          radius: 80,
          badgeWidget: _Badge(
            entry.key,
            size: 40,
            borderColor: color,
          ),
          badgePositionPercentageOffset: 1.2,
        );
      }).toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });

  final String text;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          text.substring(0, min(text.length, 3)),
          style: TextStyle(
            color: borderColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SpendingHeatmap extends StatelessWidget {
  const _SpendingHeatmap({required this.besoins});

  final List<Besoin> besoins;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Heatmap des dépenses',
      height: 400,
      child: TableCalendar<Besoin>(
        firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
        lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.red.shade600),
          holidayTextStyle: TextStyle(color: Colors.red.shade600),
        ),
        calendarBuilders: CalendarBuilders<Besoin>(
          markerBuilder: (context, date, events) {
            final dailyTotal = besoins
                .where((b) => _isSameDay(b.date, date))
                .fold<double>(0, (prev, element) => prev + element.prix);
            
            if (dailyTotal <= 0) return null;
            
            final maxDaily = besoins.isNotEmpty
                ? besoins.map((b) => b.prix).reduce(max)
                : 1.0;
            final intensity = min(dailyTotal / maxDaily, 1.0);
            
            return Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(intensity),
                ),
                width: 16,
                height: 16,
                child: Center(
                  child: Text(
                    NumberFormat.compact(locale: 'fr_FR').format(dailyTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Analytics provider and data class
final dashboardAnalyticsProvider = Provider.family<DashboardAnalytics, List<Besoin>>((ref, besoins) {
  return DashboardAnalytics(besoins);
});

class DashboardAnalytics {
  DashboardAnalytics(this.besoins);

  final List<Besoin> besoins;

  late final Map<String, double> _monthlySpending = _calculateMonthlySpending();
  late final List<double> _predictions = _calculatePredictions();

  double get threeMonthProjection => _predictions.isNotEmpty ? _predictions[2] : 0.0;
  double get sixMonthProjection => _predictions.isNotEmpty ? _predictions[5] : 0.0;
  int get dataPoints => _monthlySpending.length;

  Map<String, double> _calculateMonthlySpending() {
    final monthlySpending = <String, double>{};
    for (final besoin in besoins) {
      final key = DateFormat('yyyy-MM').format(besoin.date);
      monthlySpending.update(key, (value) => value + besoin.prix, ifAbsent: () => besoin.prix);
    }
    return monthlySpending;
  }

  List<double> _calculatePredictions() {
    if (_monthlySpending.length < 2) return List.filled(6, 0.0);

    final entries = _monthlySpending.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final x = List.generate(entries.length, (i) => i.toDouble());
    final y = entries.map((e) => e.value).toList();

    final n = x.length.toDouble();
    final sumX = x.sum;
    final sumY = y.sum;
    final sumXY = x.mapIndexed((i, xi) => xi * y[i]).sum;
    final sumX2 = x.map((xi) => xi * xi).sum;

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return List.generate(6, (i) => max(0, slope * (x.length + i) + intercept));
  }
}

// Report service provider (you should add this to your providers)
final reportServiceProvider = Provider((ref) => ReportService());
