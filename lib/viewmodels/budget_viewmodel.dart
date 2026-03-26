import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/services/budget_service.dart';

part 'budget_viewmodel.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
BudgetService budgetService(BudgetServiceRef ref) => BudgetService();

@riverpod
class BudgetList extends _$BudgetList {
  @override
  Future<List<Budget>> build() async {
    final service = ref.read(budgetServiceProvider);
    return service.getAll();
  }

  Future<void> add({required String category, required double monthlyLimit}) async {
    final service = ref.read(budgetServiceProvider);
    await service.create(category: category, monthlyLimit: monthlyLimit);
    ref.invalidateSelf();
  }

  Future<void> updateLimit(String id, double monthlyLimit) async {
    final service = ref.read(budgetServiceProvider);
    await service.updateLimit(id, monthlyLimit);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    final service = ref.read(budgetServiceProvider);
    await service.delete(id);
    ref.invalidateSelf();
  }
}
