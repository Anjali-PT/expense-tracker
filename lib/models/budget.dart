import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget {
  final String id;
  final String category;
  @JsonKey(name: 'monthly_limit')
  final double monthlyLimit;
  final double spent;
  final double remaining;
  @JsonKey(name: 'percentage_used')
  final double percentageUsed;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
    required this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
