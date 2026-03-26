import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/viewmodels/expense_list_viewmodel.dart';

void main() {
  testWidgets('App renders with title and FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseListProvider.overrideWith(() => _FakeExpenseList()),
        ],
        child: const ExpenseTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

class _FakeExpenseList extends ExpenseList {
  @override
  Future<List<Expense>> build() async => [];
}
