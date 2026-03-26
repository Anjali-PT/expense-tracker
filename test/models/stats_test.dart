import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/stats.dart';

void main() {
  group('CategoryStat', () {
    test('deserializes from JSON', () {
      final json = {
        'category': 'Food & Dining',
        'total': 150.0,
        'count': 5,
        'percentage': 60.0,
      };
      final stat = CategoryStat.fromJson(json);
      expect(stat.category, 'Food & Dining');
      expect(stat.total, 150.0);
      expect(stat.count, 5);
      expect(stat.percentage, 60.0);
    });
  });

  group('MonthlyStats', () {
    test('deserializes from JSON with nested categories', () {
      final json = {
        'total': 250.0,
        'count': 10,
        'categories': [
          {'category': 'Food & Dining', 'total': 150.0, 'count': 5, 'percentage': 60.0},
          {'category': 'Transportation', 'total': 100.0, 'count': 5, 'percentage': 40.0},
        ],
      };
      final stats = MonthlyStats.fromJson(json);
      expect(stats.total, 250.0);
      expect(stats.count, 10);
      expect(stats.categories.length, 2);
      expect(stats.categories.first.category, 'Food & Dining');
    });
  });

  group('MonthlyTrend', () {
    test('deserializes from JSON', () {
      final json = {'month': '2026-03', 'total': 500.0};
      final trend = MonthlyTrend.fromJson(json);
      expect(trend.month, '2026-03');
      expect(trend.total, 500.0);
    });
  });
}
