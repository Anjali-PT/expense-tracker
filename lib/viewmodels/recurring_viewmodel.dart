import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:expense_tracker/models/recurring_expense.dart';
import 'package:expense_tracker/services/recurring_service.dart';

part 'recurring_viewmodel.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
RecurringService recurringService(RecurringServiceRef ref) => RecurringService();

@riverpod
class RecurringList extends _$RecurringList {
  @override
  Future<List<RecurringExpense>> build() async {
    final service = ref.read(recurringServiceProvider);
    return service.getAll();
  }

  Future<void> add(RecurringExpense item) async {
    final service = ref.read(recurringServiceProvider);
    await service.create(item);
    ref.invalidateSelf();
  }

  Future<void> trigger(String id) async {
    final service = ref.read(recurringServiceProvider);
    await service.trigger(id);
    ref.invalidateSelf();
  }

  Future<void> toggleActive(String id, bool active) async {
    final service = ref.read(recurringServiceProvider);
    await service.toggleActive(id, active);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    final service = ref.read(recurringServiceProvider);
    await service.delete(id);
    ref.invalidateSelf();
  }
}
