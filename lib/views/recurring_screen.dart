import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/categories.dart';
import 'package:expense_tracker/models/recurring_expense.dart';
import 'package:expense_tracker/viewmodels/recurring_viewmodel.dart';
import 'package:expense_tracker/viewmodels/expense_list_viewmodel.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecurring = ref.watch(recurringListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Expenses')),
      body: asyncRecurring.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => items.isEmpty
            ? _EmptyRecurring(theme: theme)
            : _RecurringListBody(items: items, theme: theme),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recurring_fab',
        onPressed: () => context.push('/recurring/add'),
        tooltip: 'Add Recurring',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyRecurring extends StatelessWidget {
  final ThemeData theme;
  const _EmptyRecurring({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 80,
              color: theme.colorScheme.primary.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'No recurring expenses',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up expenses that repeat automatically',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurringListBody extends StatelessWidget {
  final List<RecurringExpense> items;
  final ThemeData theme;

  const _RecurringListBody({required this.items, required this.theme});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final currencyFormat = NumberFormat.simpleCurrency();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final catInfo = AppCategories.fromName(item.category);
        final isDue = item.nextDueDate.isBefore(DateTime.now()) && item.isActive;

        return _RecurringTile(
          item: item,
          catInfo: catInfo,
          isDue: isDue,
          dateFormat: dateFormat,
          currencyFormat: currencyFormat,
          theme: theme,
        );
      },
    );
  }
}

class _RecurringTile extends ConsumerWidget {
  final RecurringExpense item;
  final ExpenseCategory catInfo;
  final bool isDue;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final ThemeData theme;

  const _RecurringTile({
    required this.item,
    required this.catInfo,
    required this.isDue,
    required this.dateFormat,
    required this.currencyFormat,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isActive
              ? catInfo.color.withAlpha(30)
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            catInfo.icon,
            color: item.isActive ? catInfo.color : theme.colorScheme.outline,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          '${_frequencyLabel(item.frequency)} · Next: ${dateFormat.format(item.nextDueDate)}',
          style: TextStyle(
            color: isDue ? theme.colorScheme.error : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyFormat.format(item.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (action) => _handleAction(action, context, ref),
              itemBuilder: (_) => [
                if (isDue)
                  const PopupMenuItem(
                    value: 'trigger',
                    child: ListTile(
                      leading: Icon(Icons.play_arrow),
                      title: Text('Log Now'),
                      dense: true,
                    ),
                  ),
                PopupMenuItem(
                  value: 'toggle',
                  child: ListTile(
                    leading: Icon(
                      item.isActive ? Icons.pause : Icons.play_arrow,
                    ),
                    title: Text(item.isActive ? 'Pause' : 'Resume'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
      String action, BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(recurringListProvider.notifier);
    switch (action) {
      case 'trigger':
        await notifier.trigger(item.id);
        ref.invalidate(expenseListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged "${item.title}"')),
          );
        }
      case 'toggle':
        await notifier.toggleActive(item.id, !item.isActive);
      case 'delete':
        await notifier.remove(item.id);
    }
  }

  String _frequencyLabel(String freq) {
    switch (freq) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return freq;
    }
  }
}
