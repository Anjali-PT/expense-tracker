import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/viewmodels/budget_viewmodel.dart';
import 'package:expense_tracker/views/budget_screen.dart';

class _FakeBudgetList extends BudgetList {
  final List<Budget> _budgets;
  _FakeBudgetList(this._budgets);

  @override
  Future<List<Budget>> build() async => _budgets;
}

void main() {
  group('BudgetScreen', () {
    testWidgets('shows empty state when no budgets', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith(() => _FakeBudgetList([])),
          ],
          child: const MaterialApp(home: BudgetScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No budgets set'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
    });

    testWidgets('shows FAB for adding budget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith(() => _FakeBudgetList([])),
          ],
          child: const MaterialApp(home: BudgetScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays budget with progress bar', (tester) async {
      final budgets = [
        Budget(
          id: 'b1',
          category: 'Food & Dining',
          monthlyLimit: 200.0,
          spent: 150.0,
          remaining: 50.0,
          percentageUsed: 75.0,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith(() => _FakeBudgetList(budgets)),
          ],
          child: const MaterialApp(home: BudgetScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Over Budget chip when exceeded', (tester) async {
      final budgets = [
        Budget(
          id: 'b1',
          category: 'Food & Dining',
          monthlyLimit: 100.0,
          spent: 150.0,
          remaining: 0.0,
          percentageUsed: 150.0,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith(() => _FakeBudgetList(budgets)),
          ],
          child: const MaterialApp(home: BudgetScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Over Budget'), findsOneWidget);
    });
  });
}
