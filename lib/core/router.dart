import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/views/app_shell.dart';
import 'package:expense_tracker/views/home_screen.dart';
import 'package:expense_tracker/views/add_expense_screen.dart';
import 'package:expense_tracker/views/stats_screen.dart';
import 'package:expense_tracker/views/budget_screen.dart';
import 'package:expense_tracker/views/recurring_screen.dart';
import 'package:expense_tracker/views/add_recurring_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/recurring',
            builder: (context, state) => const RecurringScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddExpenseScreen(expenseId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recurring/add',
      builder: (context, state) => const AddRecurringScreen(),
    ),
  ],
);
