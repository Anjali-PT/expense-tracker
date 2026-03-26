import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/categories.dart';
import 'package:expense_tracker/models/stats.dart';
import 'package:expense_tracker/viewmodels/stats_viewmodel.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _changeMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month > 12) {
        _month = 1;
        _year++;
      } else if (_month < 1) {
        _month = 12;
        _year--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = ref.watch(monthlyStatsProvider(_year, _month));
    final trend = ref.watch(spendingTrendProvider);
    final monthName = DateFormat.yMMMM().format(DateTime(_year, _month));

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(monthName, style: theme.textTheme.titleLarge),
                IconButton(
                  onPressed: _month == DateTime.now().month &&
                          _year == DateTime.now().year
                      ? null
                      : () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category breakdown
            stats.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) => _MonthlyBreakdown(stats: data, theme: theme),
            ),
            const SizedBox(height: 32),

            // Spending trend
            Text('6-Month Trend', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            trend.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) => _TrendChart(data: data, theme: theme),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBreakdown extends StatelessWidget {
  final MonthlyStats stats;
  final ThemeData theme;

  const _MonthlyBreakdown({required this.stats, required this.theme});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();

    if (stats.categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No expenses this month',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Total card
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Total',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(stats.total),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${stats.count} expenses',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Pie chart
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: stats.categories.map((cat) {
                final catInfo = AppCategories.fromName(cat.category);
                return PieChartSectionData(
                  value: cat.total,
                  color: catInfo.color,
                  title: '${cat.percentage.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  radius: 80,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Category list
        ...stats.categories.map((cat) {
          final catInfo = AppCategories.fromName(cat.category);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: catInfo.color.withAlpha(30),
              child: Icon(catInfo.icon, color: catInfo.color, size: 20),
            ),
            title: Text(cat.category),
            subtitle: Text('${cat.count} expense${cat.count == 1 ? '' : 's'}'),
            trailing: Text(
              currencyFormat.format(cat.total),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<MonthlyTrend> data;
  final ThemeData theme;

  const _TrendChart({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxVal = data.fold<double>(0, (m, t) => t.total > m ? t.total : m);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal > 0 ? maxVal * 1.2 : 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  NumberFormat.compactCurrency(symbol: '\$')
                      .format(rod.toY),
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final parts = data[idx].month.split('-');
                  final month = DateFormat.MMM()
                      .format(DateTime(int.parse(parts[0]), int.parse(parts[1])));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      month,
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.total,
                  color: theme.colorScheme.primary,
                  width: 24,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
