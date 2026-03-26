import 'package:json_annotation/json_annotation.dart';

part 'stats.g.dart';

@JsonSerializable()
class CategoryStat {
  final String category;
  final double total;
  final int count;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.total,
    required this.count,
    required this.percentage,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) =>
      _$CategoryStatFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryStatToJson(this);
}

@JsonSerializable()
class MonthlyStats {
  final double total;
  final int count;
  final List<CategoryStat> categories;

  const MonthlyStats({
    required this.total,
    required this.count,
    required this.categories,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatsFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyStatsToJson(this);
}

@JsonSerializable()
class MonthlyTrend {
  final String month;
  final double total;

  const MonthlyTrend({required this.month, required this.total});

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) =>
      _$MonthlyTrendFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyTrendToJson(this);
}
