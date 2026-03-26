import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/stats.dart';
import 'package:expense_tracker/viewmodels/stats_viewmodel.dart';
import 'package:expense_tracker/views/stats_screen.dart';

ProviderScope _buildStatsScreen() {
  final now = DateTime.now();
  return ProviderScope(
    overrides: [
      monthlyStatsProvider(now.year, now.month).overrideWith(
        (ref) async => const MonthlyStats(
          total: 100.0,
          count: 3,
          categories: [
            CategoryStat(
              category: 'Food & Dining',
              total: 100.0,
              count: 3,
              percentage: 100.0,
            ),
          ],
        ),
      ),
      spendingTrendProvider.overrideWith(
        (ref) async => [
          const MonthlyTrend(month: '2026-01', total: 50.0),
          const MonthlyTrend(month: '2026-02', total: 75.0),
          const MonthlyTrend(month: '2026-03', total: 100.0),
        ],
      ),
    ],
    child: const MaterialApp(home: StatsScreen()),
  );
}

void main() {
  group('StatsScreen', () {
    testWidgets('renders with Statistics title', (tester) async {
      await tester.pumpWidget(_buildStatsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('shows month navigation left arrow', (tester) async {
      await tester.pumpWidget(_buildStatsScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows 6-Month Trend section', (tester) async {
      await tester.pumpWidget(_buildStatsScreen());
      await tester.pumpAndSettle();

      expect(find.text('6-Month Trend'), findsOneWidget);
    });
  });
}
