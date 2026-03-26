import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  group('Expense', () {
    final testDate = DateTime(2026, 3, 26);
    final expense = Expense(
      id: '1',
      title: 'Coffee',
      amount: 4.50,
      category: 'Food & Dining',
      date: testDate,
    );

    test('creates instance with required fields', () {
      expect(expense.id, '1');
      expect(expense.title, 'Coffee');
      expect(expense.amount, 4.50);
      expect(expense.category, 'Food & Dining');
      expect(expense.date, testDate);
    });

    test('serializes to JSON', () {
      final json = expense.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Coffee');
      expect(json['amount'], 4.50);
      expect(json['category'], 'Food & Dining');
      expect(json['date'], testDate.toIso8601String());
    });

    test('deserializes from JSON', () {
      final json = {
        'id': '2',
        'title': 'Lunch',
        'amount': 12.00,
        'category': 'Food & Dining',
        'date': '2026-03-26T12:00:00.000',
      };
      final parsed = Expense.fromJson(json);
      expect(parsed.id, '2');
      expect(parsed.title, 'Lunch');
      expect(parsed.amount, 12.00);
    });

    test('copyWith creates modified copy', () {
      final updated = expense.copyWith(title: 'Latte', amount: 5.50);
      expect(updated.title, 'Latte');
      expect(updated.amount, 5.50);
      expect(updated.id, expense.id);
      expect(updated.category, expense.category);
      expect(updated.date, expense.date);
    });

    test('copyWith with no changes returns equivalent object', () {
      final copy = expense.copyWith();
      expect(copy.id, expense.id);
      expect(copy.title, expense.title);
      expect(copy.amount, expense.amount);
    });
  });
}
