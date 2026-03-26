import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/core/env.dart';
import 'package:expense_tracker/models/stats.dart';
import 'package:expense_tracker/services/expense_service.dart';

class StatsService {
  final http.Client _client;
  final String _baseUrl;

  StatsService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = '${Env.apiBaseUrl}/api/stats';

  Future<MonthlyStats> getMonthlyStats(int year, int month) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/monthly?year=$year&month=$month'),
    );
    _check(response);
    return MonthlyStats.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<MonthlyTrend>> getTrend({int months = 6}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/trend?months=$months'),
    );
    _check(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => MonthlyTrend.fromJson(j as Map<String, dynamic>)).toList();
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
