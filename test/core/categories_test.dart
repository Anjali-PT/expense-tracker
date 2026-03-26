import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/categories.dart';

void main() {
  group('AppCategories', () {
    test('has 8 predefined categories', () {
      expect(AppCategories.all.length, 8);
    });

    test('each category has name, icon, and color', () {
      for (final cat in AppCategories.all) {
        expect(cat.name, isNotEmpty);
        expect(cat.icon, isA<IconData>());
        expect(cat.color, isA<Color>());
      }
    });

    test('fromName returns correct category', () {
      final food = AppCategories.fromName('Food & Dining');
      expect(food.name, 'Food & Dining');
      expect(food.icon, Icons.restaurant);
    });

    test('fromName returns Other for unknown category', () {
      final unknown = AppCategories.fromName('Nonexistent');
      expect(unknown.name, 'Other');
    });

    test('all category names are unique', () {
      final names = AppCategories.all.map((c) => c.name).toSet();
      expect(names.length, AppCategories.all.length);
    });
  });
}
