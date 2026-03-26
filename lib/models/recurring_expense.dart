import 'package:json_annotation/json_annotation.dart';

part 'recurring_expense.g.dart';

@JsonSerializable()
class RecurringExpense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String frequency;
  @JsonKey(name: 'next_due_date')
  final DateTime nextDueDate;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const RecurringExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
    required this.isActive,
    required this.createdAt,
  });

  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      _$RecurringExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$RecurringExpenseToJson(this);

  RecurringExpense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? frequency,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
