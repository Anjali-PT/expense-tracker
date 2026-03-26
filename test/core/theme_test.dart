import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses Material 3', () {
      expect(AppTheme.light.useMaterial3, true);
    });

    test('dark theme uses Material 3', () {
      expect(AppTheme.dark.useMaterial3, true);
    });

    test('dark theme has dark brightness', () {
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    });

    test('light theme has light brightness', () {
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
    });
  });
}
