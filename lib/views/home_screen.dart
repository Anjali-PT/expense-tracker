import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/categories.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/viewmodels/expense_list_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    var filtered = expenses;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((e) => e.title.toLowerCase().contains(query)).toList();
    }
    if (_selectedCategory != null) {
      filtered =
          filtered.where((e) => e.category == _selectedCategory).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final asyncExpenses = ref.watch(expenseListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: asyncExpenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          error: error,
          onRetry: () => ref.invalidate(expenseListProvider),
          theme: theme,
        ),
        data: (expenses) {
          final filtered = _filterExpenses(expenses);
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search expenses...',
                  leading: const Icon(Icons.search, size: 20),
                  trailing: _searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        ]
                      : null,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  ),
                ),
              ),

              // Category filter chips
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: _selectedCategory == null,
                        label: const Text('All'),
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                        showCheckmark: false,
                      ),
                    ),
                    ...AppCategories.all.map((cat) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            selected: _selectedCategory == cat.name,
                            label: Text(cat.name),
                            avatar:
                                Icon(cat.icon, size: 16, color: cat.color),
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory =
                                    _selectedCategory == cat.name
                                        ? null
                                        : cat.name;
                              });
                            },
                            selectedColor: cat.color.withAlpha(40),
                            showCheckmark: false,
                          ),
                        )),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          expenses.isEmpty
                              ? 'No expenses yet'
                              : 'No matching expenses',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : _ExpenseListBody(
                        expenses: filtered,
                        allExpenses: expenses,
                        theme: theme,
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final ThemeData theme;

  const _ErrorState({
    required this.error,
    required this.onRetry,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: theme.colorScheme.error.withAlpha(150),
            ),
            const SizedBox(height: 16),
            Text('Could not load expenses',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListBody extends StatelessWidget {
  final List<Expense> expenses;
  final List<Expense> allExpenses;
  final ThemeData theme;

  const _ExpenseListBody({
    required this.expenses,
    required this.allExpenses,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();
    final total = allExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    final sorted = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _SummaryCard(
            total: total,
            count: allExpenses.length,
            currencyFormat: currencyFormat,
            theme: theme,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 80),
          sliver: SliverList.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final expense = sorted[index];
              final showDateHeader = index == 0 ||
                  !_isSameDay(sorted[index - 1].date, expense.date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDateHeader)
                    _DateHeader(date: expense.date, theme: theme),
                  _ExpenseTile(
                    expense: expense,
                    currencyFormat: currencyFormat,
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SummaryCard extends StatelessWidget {
  final double total;
  final int count;
  final NumberFormat currencyFormat;
  final ThemeData theme;

  const _SummaryCard({
    required this.total,
    required this.count,
    required this.currencyFormat,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Spending',
                style: theme.textTheme.titleSmall?.copyWith(
                  color:
                      theme.colorScheme.onPrimaryContainer.withAlpha(180),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(total),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count expense${count == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onPrimaryContainer.withAlpha(160),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final ThemeData theme;

  const _DateHeader({required this.date, required this.theme});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    String label;
    if (dateDay == today) {
      label = 'Today';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      label = 'Yesterday';
    } else {
      label = DateFormat.yMMMd().format(date);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  final Expense expense;
  final NumberFormat currencyFormat;
  final ThemeData theme;

  const _ExpenseTile({
    required this.expense,
    required this.currencyFormat,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = AppCategories.fromName(expense.category);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        ref.read(expenseListProvider.notifier).remove(expense.id);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withAlpha(30),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(category.name),
        trailing: Text(
          currencyFormat.format(expense.amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => context.push('/edit/${expense.id}'),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
