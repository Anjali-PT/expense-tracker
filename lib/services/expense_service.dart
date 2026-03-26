import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/core/env.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseService {
  final http.Client _client;
  final String _baseUrl;

  ExpenseService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = '${Env.apiBaseUrl}/api/expenses';

  Future<List<Expense>> getAll() async {
    final response = await _client.get(Uri.parse(_baseUrl));
    _checkResponse(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Expense> create(Expense expense) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': expense.title,
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date.toIso8601String(),
      }),
    );
    _checkResponse(response);
    return Expense.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Expense> update(Expense expense) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/${expense.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': expense.title,
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date.toIso8601String(),
      }),
    );
    _checkResponse(response);
    return Expense.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      _checkResponse(response);
    }
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 400) {
      throw ExpenseApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

class ExpenseApiException implements Exception {
  final int statusCode;
  final String message;

  const ExpenseApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ExpenseApiException($statusCode): $message';
}
