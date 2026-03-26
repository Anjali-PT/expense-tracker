import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/categories.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/viewmodels/budget_viewmodel.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBudgets = ref.watch(budgetListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: asyncBudgets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) => budgets.isEmpty
            ? _EmptyBudgets(theme: theme)
            : _BudgetListBody(budgets: budgets, theme: theme),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budget_fab',
        onPressed: () => _showAddBudgetDialog(context, ref),
        tooltip: 'Add Budget',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    String selectedCategory = AppCategories.all.first.name;
    final limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Set Monthly Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: AppCategories.all
                    .map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Row(
                            children: [
                              Icon(c.icon, color: c.color, size: 20),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: limitController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Limit',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final limit = double.tryParse(limitController.text);
                if (limit == null || limit <= 0) return;
                ref.read(budgetListProvider.notifier).add(
                      category: selectedCategory,
                      monthlyLimit: limit,
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBudgets extends StatelessWidget {
  final ThemeData theme;
  const _EmptyBudgets({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 80,
              color: theme.colorScheme.primary.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'No budgets set',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set monthly spending limits per category',
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

class _BudgetListBody extends StatelessWidget {
  final List<Budget> budgets;
  final ThemeData theme;

  const _BudgetListBody({required this.budgets, required this.theme});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        final catInfo = AppCategories.fromName(budget.category);
        final isOver = budget.percentageUsed >= 100;
        final isWarning = budget.percentageUsed >= 80 && !isOver;

        Color progressColor;
        if (isOver) {
          progressColor = theme.colorScheme.error;
        } else if (isWarning) {
          progressColor = Colors.orange;
        } else {
          progressColor = theme.colorScheme.primary;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: catInfo.color.withAlpha(30),
                      child:
                          Icon(catInfo.icon, color: catInfo.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        budget.category,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (isOver)
                      Chip(
                        label: const Text('Over Budget'),
                        backgroundColor:
                            theme.colorScheme.error.withAlpha(30),
                        labelStyle: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      )
                    else if (isWarning)
                      Chip(
                        label: const Text('Near Limit'),
                        backgroundColor: Colors.orange.withAlpha(30),
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (budget.percentageUsed / 100).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    color: progressColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currencyFormat.format(budget.spent)} spent',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${currencyFormat.format(budget.monthlyLimit)} limit',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
