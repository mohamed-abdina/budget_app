import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/income/income_list_screen.dart';
import 'screens/expenses/expense_list_screen.dart';
import 'screens/budgets/budget_list_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/categories/category_list_screen.dart';
import 'screens/debts/debt_list_screen.dart';

class LedgerlineApp extends ConsumerWidget {
  const LedgerlineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);

    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final loggedIn = ref.read(authStateProvider);
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        if (!loggedIn && !isAuthRoute) return '/login';
        if (loggedIn && isAuthRoute) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
            GoRoute(path: '/income', builder: (context, state) => const IncomeListScreen()),
            GoRoute(path: '/expenses', builder: (context, state) => const ExpenseListScreen()),
            GoRoute(path: '/budgets', builder: (context, state) => const BudgetListScreen()),
            GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
            GoRoute(path: '/debts', builder: (context, state) => const DebtListScreen()),
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),
        GoRoute(path: '/categories', builder: (context, state) => const CategoryListScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'Ledgerline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1D8763),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1D8763),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/income')) return 1;
    if (location.startsWith('/expenses')) return 2;
    if (location.startsWith('/budgets')) return 3;
    if (location.startsWith('/reports')) return 4;
    if (location.startsWith('/debts')) return 5;
    if (location.startsWith('/profile')) return 6;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/dashboard');
            case 1: context.go('/income');
            case 2: context.go('/expenses');
            case 3: context.go('/budgets');
            case 4: context.go('/reports');
            case 5: context.go('/debts');
            case 6: context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.arrow_downward), label: 'Income'),
          NavigationDestination(icon: Icon(Icons.arrow_upward), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Debts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
