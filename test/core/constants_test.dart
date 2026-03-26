import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants.dart';

void main() {
  group('AppConstants', () {
    test('appName is set', () {
      expect(AppConstants.appName, 'Expense Tracker');
    });

    test('currency is USD', () {
      expect(AppConstants.currency, 'USD');
    });

    test('hiveBoxName is set', () {
      expect(AppConstants.hiveBoxName, isNotEmpty);
    });
  });
}
