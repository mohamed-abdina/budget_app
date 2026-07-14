import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_data_provider.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';
import '../debts/debt_list_screen.dart';
import '../../widgets/metric_card.dart';
import '../income/income_form_screen.dart';
import '../expenses/expense_form_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth--;
      if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth++;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      }
    });
  }

  ({int month, int year}) get _current => (month: _selectedMonth, year: _selectedYear);

  ({int month, int year}) get _lastMonth {
    int m = _selectedMonth - 1;
    int y = _selectedYear;
    if (m < 1) { m = 12; y--; }
    return (month: m, year: y);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final daysLeft = _selectedYear == now.year && _selectedMonth == now.month
        ? daysInMonth - now.day
        : (_selectedYear > now.year || (_selectedYear == now.year && _selectedMonth > now.month) ? daysInMonth : 0);
    final daysPassed = _selectedYear == now.year && _selectedMonth == now.month ? now.day : daysInMonth;

    final summary = ref.watch(reportSummaryProvider(_current));
    final monthly = ref.watch(reportMonthlyProvider(6));
    final categories = ref.watch(reportCategoriesProvider(_current));
    final incomes = ref.watch(dashboardIncomesProvider(_current));
    final expenses = ref.watch(dashboardExpensesProvider(_current));
    final budgets = ref.watch(dashboardBudgetsProvider(_current));
    final lastIncomes = ref.watch(lastMonthIncomesProvider(_lastMonth));
    final lastExpenses = ref.watch(lastMonthExpensesProvider(_lastMonth));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reportSummaryProvider);
          ref.invalidate(reportMonthlyProvider);
          ref.invalidate(reportCategoriesProvider);
          ref.invalidate(dashboardIncomesProvider);
          ref.invalidate(dashboardExpensesProvider);
          ref.invalidate(dashboardBudgetsProvider);
          ref.invalidate(lastMonthIncomesProvider);
          ref.invalidate(lastMonthExpensesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Month navigator
            SliverAppBar(
              pinned: true,
              title: const Text('Dashboard'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month selector
                    _buildMonthSelector(),
                    const SizedBox(height: 16),

                    // Metric cards
                    summary.when(
                      data: (data) {
                        final income = (data['income'] ?? 0).toDouble();
                        final expenses = (data['expenses'] ?? 0).toDouble();
                        final balance = (data['balance'] ?? 0).toDouble();
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: MetricCard(title: 'Income', value: 'KES ${income.toStringAsFixed(0)}', icon: Icons.arrow_downward, color: Colors.green)),
                                const SizedBox(width: 8),
                                Expanded(child: MetricCard(title: 'Expenses', value: 'KES ${expenses.toStringAsFixed(0)}', icon: Icons.arrow_upward, color: Colors.red)),
                                const SizedBox(width: 8),
                                Expanded(child: MetricCard(title: 'Balance', value: 'KES ${balance.toStringAsFixed(0)}', icon: Icons.account_balance, color: const Color(0xFF1D8763))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Savings rate + days left
                            _buildSavingsAndDaysRow(income, expenses, daysLeft, daysPassed, daysInMonth),
                          ],
                        );
                      },
                      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    // Month-over-month comparison
                    const SizedBox(height: 16),
                    _buildComparisonCard(incomes, expenses, lastIncomes, lastExpenses),

                    // Budget status
                    const SizedBox(height: 16),
                    _buildBudgetSection(budgets),

                    // Debt overview
                    const SizedBox(height: 16),
                    _buildDebtSection(ref),

                    // Recent transactions
                    const SizedBox(height: 16),
                    _buildRecentTransactions(incomes, expenses),

                    // Charts
                    const SizedBox(height: 16),
                    _buildChartCard(monthly),

                    // Expense breakdown
                    const SizedBox(height: 16),
                    _buildExpenseBreakdown(categories),

                    // Top spending category
                    const SizedBox(height: 16),
                    _buildTopCategory(categories),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_income',
            backgroundColor: const Color(0xFF1D8763),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeFormScreen())),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'add_expense',
            backgroundColor: const Color(0xFFC2483F),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseFormScreen())),
            child: const Icon(Icons.remove, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _prevMonth,
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _selectedYear == DateTime.now().year && _selectedMonth == DateTime.now().month ? null : _nextMonth,
        ),
      ],
    );
  }

  Widget _buildSavingsAndDaysRow(double income, double expenses, int daysLeft, int daysPassed, int daysInMonth) {
    final savingsRate = income > 0 ? ((income - expenses) / income * 100).clamp(0, 100) : 0.0;
    final burnRate = daysPassed > 0 ? expenses / daysPassed : 0.0;
    final dailyBudget = daysLeft > 0 && income > expenses ? (income - expenses) / daysLeft : 0.0;

    return Row(
      children: [
        // Savings rate
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: savingsRate / 100,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[200],
                          color: savingsRate >= 20 ? const Color(0xFF1D8763) : savingsRate >= 0 ? const Color(0xFFB8862F) : const Color(0xFFC2483F),
                        ),
                        Center(
                          child: Text(
                            '${savingsRate.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Savings Rate', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Days left + burn rate
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Icon(Icons.calendar_today, size: 28, color: daysLeft > 7 ? const Color(0xFF1D8763) : daysLeft > 3 ? const Color(0xFFB8862F) : const Color(0xFFC2483F)),
                  const SizedBox(height: 6),
                  Text('$daysLeft days left', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Burn: KES ${burnRate.toStringAsFixed(0)}/day', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Daily budget
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Icon(Icons.speed, size: 28, color: dailyBudget > 0 ? const Color(0xFF1D8763) : const Color(0xFFC2483F)),
                  const SizedBox(height: 6),
                  Text('KES ${dailyBudget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Daily budget', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(AsyncValue<List<dynamic>> incomes, AsyncValue<List<dynamic>> expenses,
      AsyncValue<List<dynamic>> lastIncomes, AsyncValue<List<dynamic>> lastExpenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Month over Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _comparisonItem(
                    'Income',
                    incomes.when(data: (d) => d.fold<double>(0, (s, e) => s + (e.amountDouble)), loading: () => 0, error: (_, __) => 0),
                    lastIncomes.when(data: (d) => d.fold<double>(0, (s, e) => s + (e.amountDouble)), loading: () => 0, error: (_, __) => 0),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _comparisonItem(
                    'Expenses',
                    expenses.when(data: (d) => d.fold<double>(0, (s, e) => s + (e.amountDouble)), loading: () => 0, error: (_, __) => 0),
                    lastExpenses.when(data: (d) => d.fold<double>(0, (s, e) => s + (e.amountDouble)), loading: () => 0, error: (_, __) => 0),
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonItem(String label, double current, double previous, Color color) {
    final diff = previous > 0 ? ((current - previous) / previous * 100) : 0.0;
    final isUp = diff > 0;

    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text('KES ${current.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        if (previous > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 14, color: isUp ? Colors.green : Colors.red),
              const SizedBox(width: 2),
              Text('${diff.abs().toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, color: isUp ? Colors.green : Colors.red)),
            ],
          )
        else
          Text('No prev data', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildBudgetSection(AsyncValue<List<dynamic>> budgets) {
    return budgets.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Budget Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${data.length} active', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.take(5).map((b) {
                  final pct = b.percentage;
                  final color = pct >= 100 ? const Color(0xFFC2483F) : pct >= 80 ? const Color(0xFFB8862F) : const Color(0xFF1D8763);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(b.categoryName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Text('KES ${b.spentDouble.toStringAsFixed(0)} / KES ${b.amountDouble.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            const SizedBox(width: 6),
                            Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          color: color,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentTransactions(AsyncValue<List<dynamic>> incomes, AsyncValue<List<dynamic>> expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            // Combine and sort
            Builder(builder: (context) {
              final allIncomes = incomes.when(data: (d) => d, loading: () => <dynamic>[], error: (_, __) => <dynamic>[]);
              final allExpenses = expenses.when(data: (d) => d, loading: () => <dynamic>[], error: (_, __) => <dynamic>[]);
              final all = <Map<String, dynamic>>[];
              for (final i in allIncomes) {
                all.add({'type': 'income', 'data': i, 'date': i.date});
              }
              for (final e in allExpenses) {
                all.add({'type': 'expense', 'data': e, 'date': e.date});
              }
              all.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));
              final recent = all.take(5).toList();

              if (recent.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 40, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text('No transactions yet', style: TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text('Tap + to add your first one', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: recent.map((item) {
                  final data = item['data'];
                  final isIncome = item['type'] == 'income';
                  final color = _parseColor(data.categoryColor);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                        size: 18,
                      ),
                    ),
                    title: Text(data.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(data.categoryName, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${isIncome ? '+' : '-'}KES ${data.amountDouble.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isIncome ? Colors.green : Colors.red),
                        ),
                        Text(data.date.toString().substring(0, 10), style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(AsyncValue<List<Map<String, dynamic>>> monthly) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Income vs Expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: monthly.when(
                data: (data) {
                  if (data.isEmpty) return const Center(child: Text('No data yet'));
                  final maxY = data.map((e) => [(e['income'] ?? 0) as num, (e['expense'] ?? 0) as num]).expand((e) => e).fold<num>(0, (a, b) => a > b ? a : b).toDouble() * 1.2;
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY > 0 ? maxY : 100,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < data.length) {
                              final m = data[idx]['month'] as int;
                              return Text(DateFormat('MMM').format(DateTime(2024, m)), style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: List.generate(data.length, (i) {
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(toY: (data[i]['income'] ?? 0).toDouble(), color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4)),
                          BarChartRodData(toY: (data[i]['expense'] ?? 0).toDouble(), color: Colors.red, width: 12, borderRadius: BorderRadius.circular(4)),
                        ]);
                      }),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdown(AsyncValue<List<Map<String, dynamic>>> categories) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expense Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            categories.when(
              data: (data) {
                if (data.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_outline, size: 40, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('No expenses yet', style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  );
                }
                final total = data.fold<double>(0, (sum, e) => sum + (e['total'] ?? 0).toDouble());
                return Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: data.map((e) => PieChartSectionData(
                            value: (e['total'] ?? 0).toDouble(),
                            title: '${((e['total'] ?? 0).toDouble() / total * 100).toStringAsFixed(0)}%',
                            color: _parseColor(e['category__color']),
                            radius: 70,
                            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          )).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...data.take(5).map((e) {
                      final pct = total > 0 ? (e['total'] ?? 0).toDouble() / total * 100 : 0.0;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: _parseColor(e['category__color']), shape: BoxShape.circle),
                        ),
                        title: Text(e['category__name'] ?? '', style: const TextStyle(fontSize: 13)),
                        trailing: Text('KES ${(e['total'] ?? 0).toDouble().toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategory(AsyncValue<List<Map<String, dynamic>>> categories) {
    return categories.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();
        final top = data.first;
        final total = data.fold<double>(0, (sum, e) => sum + (e['total'] ?? 0).toDouble());
        final pct = total > 0 ? (top['total'] ?? 0).toDouble() / total * 100 : 0.0;

        return Card(
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _parseColor(top['category__color']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.whatshot, color: _parseColor(top['category__color'])),
            ),
            title: const Text('Top Spending', style: TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(top['category__name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('KES ${(top['total'] ?? 0).toDouble().toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('${pct.toStringAsFixed(0)}% of total', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Widget _buildDebtSection(WidgetRef ref) {
    final debts = ref.watch(debtListProvider);

    return debts.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();

        final totalDebt = list.fold<double>(0, (s, d) => s + d.totalAmountDouble);
        final totalPaid = list.fold<double>(0, (s, d) => s + d.amountPaidDouble);
        final totalRemaining = totalDebt - totalPaid;

        // Find next due debt
        Debt? nextDue;
        for (final d in list) {
          if (d.dueDate.isEmpty) continue;
          try {
            final due = DateTime.parse(d.dueDate);
            if (due.isAfter(DateTime.now())) {
              if (nextDue == null || due.isBefore(DateTime.parse(nextDue.dueDate))) {
                nextDue = d;
              }
            }
          } catch (_) {}
        }

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtListScreen())),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Debt Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KES ${totalRemaining.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFC2483F))),
                            Text('remaining', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                      if (nextDue != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Next: ${nextDue.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            Text('KES ${nextDue.minimumPaymentDouble.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFFB8862F))),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: totalDebt > 0 ? (totalPaid / totalDebt).clamp(0.0, 1.0) : 0,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF1D8763),
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
