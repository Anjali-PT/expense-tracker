import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/budget.dart';

void main() {
  group('Budget', () {
    test('deserializes from JSON with snake_case keys', () {
      final json = {
        'id': 'b1',
        'category': 'Food & Dining',
        'monthly_limit': 200.0,
        'spent': 50.0,
        'remaining': 150.0,
        'percentage_used': 25.0,
        'created_at': '2026-03-01T00:00:00.000',
      };
      final budget = Budget.fromJson(json);
      expect(budget.id, 'b1');
      expect(budget.category, 'Food & Dining');
      expect(budget.monthlyLimit, 200.0);
      expect(budget.spent, 50.0);
      expect(budget.remaining, 150.0);
      expect(budget.percentageUsed, 25.0);
    });

    test('serializes to JSON', () {
      final budget = Budget(
        id: 'b2',
        category: 'Transportation',
        monthlyLimit: 100.0,
        spent: 80.0,
        remaining: 20.0,
        percentageUsed: 80.0,
        createdAt: DateTime(2026, 3, 1),
      );
      final json = budget.toJson();
      expect(json['monthly_limit'], 100.0);
      expect(json['percentage_used'], 80.0);
    });
  });
}
