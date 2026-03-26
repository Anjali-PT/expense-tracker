import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:expense_tracker/models/stats.dart';
import 'package:expense_tracker/services/stats_service.dart';

part 'stats_viewmodel.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
StatsService statsService(StatsServiceRef ref) => StatsService();

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<MonthlyStats> monthlyStats(MonthlyStatsRef ref, int year, int month) async {
  final service = ref.read(statsServiceProvider);
  return service.getMonthlyStats(year, month);
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<MonthlyTrend>> spendingTrend(SpendingTrendRef ref) async {
  final service = ref.read(statsServiceProvider);
  return service.getTrend(months: 6);
}
