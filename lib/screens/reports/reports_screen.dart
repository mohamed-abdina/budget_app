import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/report_provider.dart';
import '../../widgets/metric_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(reportSummaryProvider((month: _month, year: _year)));
    final monthly = ref.watch(reportMonthlyProvider(6));
    final categories = ref.watch(reportCategoriesProvider((month: _month, year: _year)));

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _month,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(DateTime(2024, i + 1).month.toString().padLeft(2, '0')))),
                  onChanged: (v) => setState(() => _month = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _year,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: List.generate(5, (i) => DropdownMenuItem(value: 2023 + i, child: Text('${2023 + i}'))),
                  onChanged: (v) => setState(() => _year = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          summary.when(
            data: (data) => Row(
              children: [
                Expanded(child: MetricCard(title: 'Income', value: 'KES ${(data['income'] ?? 0).toStringAsFixed(0)}', icon: Icons.arrow_downward, color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: MetricCard(title: 'Expenses', value: 'KES ${(data['expenses'] ?? 0).toStringAsFixed(0)}', icon: Icons.arrow_upward, color: Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: MetricCard(title: 'Balance', value: 'KES ${(data['balance'] ?? 0).toStringAsFixed(0)}', icon: Icons.account_balance, color: const Color(0xFF1D8763))),
              ],
            ),
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Income vs Expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: monthly.when(
                      data: (data) => BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: data.isEmpty ? 100 : data.map((e) => (e['income'] ?? 0) as num).reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= 0 && idx < data.length) {
                                  final m = data[idx]['month'] as int;
                                  return Text(DateTime(2024, m).month.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 10));
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
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expense Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  categories.when(
                    data: (data) {
                      if (data.isEmpty) return const SizedBox(height: 60, child: Center(child: Text('No expenses')));
                      return Column(
                        children: data.map((e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _parseColor(e['category__color']),
                            radius: 8,
                          ),
                          title: Text(e['category__name']),
                          trailing: Text('KES ${(e['total'] ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        )).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
