import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/recurring_expense.dart';
import 'package:expense_tracker/viewmodels/recurring_viewmodel.dart';
import 'package:expense_tracker/views/add_recurring_screen.dart';

class _FakeRecurringList extends RecurringList {
  @override
  Future<List<RecurringExpense>> build() async => [];
}

void main() {
  group('AddRecurringScreen', () {
    Widget buildScreen() {
      return ProviderScope(
        overrides: [
          recurringListProvider.overrideWith(_FakeRecurringList.new),
        ],
        child: const MaterialApp(home: AddRecurringScreen()),
      );
    }

    testWidgets('renders with correct title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Add Recurring Expense'), findsWidgets);
    });

    testWidgets('has amount and title fields', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('has frequency dropdown', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Frequency'), findsOneWidget);
    });

    testWidgets('has category chips', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Category'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });
  });
}
