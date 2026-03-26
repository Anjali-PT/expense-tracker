import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/core/env.dart';
import 'package:expense_tracker/models/recurring_expense.dart';
import 'package:expense_tracker/services/expense_service.dart';

class RecurringService {
  final http.Client _client;
  final String _baseUrl;

  RecurringService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = '${Env.apiBaseUrl}/api/recurring';

  Future<List<RecurringExpense>> getAll() async {
    final response = await _client.get(Uri.parse(_baseUrl));
    _check(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => RecurringExpense.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<RecurringExpense> create(RecurringExpense item) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': item.title,
        'amount': item.amount,
        'category': item.category,
        'frequency': item.frequency,
        'next_due_date': item.nextDueDate.toIso8601String(),
      }),
    );
    _check(response);
    return RecurringExpense.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> trigger(String id) async {
    final response = await _client.post(Uri.parse('$_baseUrl/$id/trigger'));
    _check(response);
  }

  Future<void> toggleActive(String id, bool active) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'is_active': active}),
    );
    _check(response);
  }

  Future<void> delete(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) _check(response);
  }

  void _check(http.Response response) {
    if (response.statusCode >= 400) {
      throw ExpenseApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}
