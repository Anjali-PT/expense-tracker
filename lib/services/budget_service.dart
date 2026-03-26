import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/core/env.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/services/expense_service.dart';

class BudgetService {
  final http.Client _client;
  final String _baseUrl;

  BudgetService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = '${Env.apiBaseUrl}/api/budgets';

  Future<List<Budget>> getAll() async {
    final response = await _client.get(Uri.parse(_baseUrl));
    _check(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => Budget.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Budget> create({required String category, required double monthlyLimit}) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': category, 'monthly_limit': monthlyLimit}),
    );
    _check(response);
    return Budget.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Budget> updateLimit(String id, double monthlyLimit) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'monthly_limit': monthlyLimit}),
    );
    _check(response);
    return Budget.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
