import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/expense_service.dart';

void main() {
  group('ExpenseApiException', () {
    test('toString includes status code and message', () {
      const exception = ExpenseApiException(
        statusCode: 404,
        message: 'Not found',
      );
      expect(exception.toString(), contains('404'));
      expect(exception.toString(), contains('Not found'));
    });

    test('stores statusCode and message', () {
      const exception = ExpenseApiException(
        statusCode: 500,
        message: 'Server error',
      );
      expect(exception.statusCode, 500);
      expect(exception.message, 'Server error');
    });
  });

  group('ExpenseService', () {
    test('constructs with default base URL', () {
      final service = ExpenseService();
      expect(service, isNotNull);
    });
  });
}
