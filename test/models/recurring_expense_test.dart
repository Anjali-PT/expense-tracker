import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/recurring_expense.dart';

void main() {
  group('RecurringExpense', () {
    final item = RecurringExpense(
      id: 'r1',
      title: 'Netflix',
      amount: 15.99,
      category: 'Entertainment',
      frequency: 'monthly',
      nextDueDate: DateTime(2026, 4, 1),
      isActive: true,
      createdAt: DateTime(2026, 3, 1),
    );

    test('creates instance with all fields', () {
      expect(item.id, 'r1');
      expect(item.title, 'Netflix');
      expect(item.amount, 15.99);
      expect(item.frequency, 'monthly');
      expect(item.isActive, true);
    });

    test('serializes to JSON with snake_case', () {
      final json = item.toJson();
      expect(json['next_due_date'], isNotNull);
      expect(json['is_active'], true);
      expect(json['created_at'], isNotNull);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'r2',
        'title': 'Spotify',
        'amount': 9.99,
        'category': 'Entertainment',
        'frequency': 'monthly',
        'next_due_date': '2026-04-01T00:00:00.000',
        'is_active': false,
        'created_at': '2026-03-01T00:00:00.000',
      };
      final parsed = RecurringExpense.fromJson(json);
      expect(parsed.title, 'Spotify');
      expect(parsed.isActive, false);
    });

    test('copyWith modifies specified fields', () {
      final paused = item.copyWith(isActive: false);
      expect(paused.isActive, false);
      expect(paused.title, item.title);
      expect(paused.amount, item.amount);
    });
  });
}
