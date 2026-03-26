import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/viewmodels/expense_list_viewmodel.dart';
import 'package:expense_tracker/views/add_expense_screen.dart';

class _FakeExpenseList extends ExpenseList {
  @override
  Future<List<Expense>> build() async => [];
}

void main() {
  group('AddExpenseScreen', () {
    Widget buildScreen({String? expenseId}) {
      return ProviderScope(
        overrides: [
          expenseListProvider.overrideWith(_FakeExpenseList.new),
        ],
        child: MaterialApp(
          home: AddExpenseScreen(expenseId: expenseId),
        ),
      );
    }

    testWidgets('renders add mode with correct title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Add Expense'), findsWidgets);
    });

    testWidgets('has amount field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Amount'), findsOneWidget);
    });

    testWidgets('has title field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('has category chips', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Category'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('has date picker button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('has a form with text fields', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
}
