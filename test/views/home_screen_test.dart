import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/viewmodels/expense_list_viewmodel.dart';
import 'package:expense_tracker/views/home_screen.dart';

class _FakeExpenseList extends ExpenseList {
  final List<Expense> _expenses;
  _FakeExpenseList(this._expenses);

  @override
  Future<List<Expense>> build() async => _expenses;
}

Widget _wrapWithProviders(Widget child, {List<Expense> expenses = const []}) {
  return ProviderScope(
    overrides: [
      expenseListProvider.overrideWith(() => _FakeExpenseList(expenses)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows empty state when no expenses', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No expenses yet'), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SearchBar), findsOneWidget);
    });

    testWidgets('shows FAB with Add Expense label', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows category filter chips', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('displays expense list with items', (tester) async {
      final expenses = [
        Expense(
          id: '1',
          title: 'Coffee',
          amount: 4.50,
          category: 'Food & Dining',
          date: DateTime.now(),
        ),
        Expense(
          id: '2',
          title: 'Bus ticket',
          amount: 2.00,
          category: 'Transportation',
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(_wrapWithProviders(
        const HomeScreen(),
        expenses: expenses,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Bus ticket'), findsOneWidget);
      expect(find.text('Total Spending'), findsOneWidget);
    });

    testWidgets('shows summary card with total', (tester) async {
      final expenses = [
        Expense(
          id: '1',
          title: 'Coffee',
          amount: 4.50,
          category: 'Food & Dining',
          date: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(_wrapWithProviders(
        const HomeScreen(),
        expenses: expenses,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Total Spending'), findsOneWidget);
      expect(find.text('1 expense'), findsOneWidget);
    });
  });
}
