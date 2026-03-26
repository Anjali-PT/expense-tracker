import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/recurring_expense.dart';
import 'package:expense_tracker/viewmodels/recurring_viewmodel.dart';
import 'package:expense_tracker/views/recurring_screen.dart';

class _FakeRecurringList extends RecurringList {
  final List<RecurringExpense> _items;
  _FakeRecurringList(this._items);

  @override
  Future<List<RecurringExpense>> build() async => _items;
}

void main() {
  group('RecurringScreen', () {
    testWidgets('shows empty state when no recurring expenses', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringListProvider.overrideWith(() => _FakeRecurringList([])),
          ],
          child: const MaterialApp(home: RecurringScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No recurring expenses'), findsOneWidget);
    });

    testWidgets('shows FAB for adding recurring', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringListProvider.overrideWith(() => _FakeRecurringList([])),
          ],
          child: const MaterialApp(home: RecurringScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays recurring expense item', (tester) async {
      final items = [
        RecurringExpense(
          id: 'r1',
          title: 'Netflix',
          amount: 15.99,
          category: 'Entertainment',
          frequency: 'monthly',
          nextDueDate: DateTime(2026, 4, 1),
          isActive: true,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringListProvider.overrideWith(() => _FakeRecurringList(items)),
          ],
          child: const MaterialApp(home: RecurringScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Netflix'), findsOneWidget);
      expect(find.textContaining('Monthly'), findsOneWidget);
    });
  });
}
