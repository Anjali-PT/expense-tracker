import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/expense_service.dart';

part 'expense_list_viewmodel.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
ExpenseService expenseService(ExpenseServiceRef ref) => ExpenseService();

@riverpod
class ExpenseList extends _$ExpenseList {
  @override
  Future<List<Expense>> build() async {
    final service = ref.read(expenseServiceProvider);
    return service.getAll();
  }

  Future<void> add(Expense expense) async {
    final service = ref.read(expenseServiceProvider);
    await service.create(expense);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    final service = ref.read(expenseServiceProvider);
    await service.delete(id);
    ref.invalidateSelf();
  }

  Future<void> updateExpense(Expense expense) async {
    final service = ref.read(expenseServiceProvider);
    await service.update(expense);
    ref.invalidateSelf();
  }
}
