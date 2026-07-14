import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';
import '../../widgets/empty_state.dart';
import 'debt_form_screen.dart';
import 'debt_detail_screen.dart';

class DebtListScreen extends ConsumerWidget {
  const DebtListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: debts.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(icon: Icons.account_balance_wallet, message: 'No debts tracked');
          }

          final totalDebt = list.fold<double>(0, (s, d) => s + d.totalAmountDouble);
          final totalPaid = list.fold<double>(0, (s, d) => s + d.amountPaidDouble);
          final totalRemaining = totalDebt - totalPaid;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Debt Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _summaryItem('Total', 'KES ${totalDebt.toStringAsFixed(0)}', Colors.blue),
                          const SizedBox(width: 12),
                          _summaryItem('Paid', 'KES ${totalPaid.toStringAsFixed(0)}', const Color(0xFF1D8763)),
                          const SizedBox(width: 12),
                          _summaryItem('Remaining', 'KES ${totalRemaining.toStringAsFixed(0)}', const Color(0xFFC2483F)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: totalDebt > 0 ? (totalPaid / totalDebt).clamp(0.0, 1.0) : 0,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFF1D8763),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Debt list
              ...list.map((debt) => _debtCard(context, ref, debt)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _debtCard(BuildContext context, WidgetRef ref, Debt debt) {
    final color = debt.percentagePaid >= 100
        ? const Color(0xFF1D8763)
        : debt.percentagePaid >= 50
            ? const Color(0xFFB8862F)
            : const Color(0xFFC2483F);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DebtDetailScreen(debt: debt)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      debt.isRecurring ? Icons.autorenew : Icons.account_balance_wallet,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(debt.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text(debt.creditor.isNotEmpty ? debt.creditor : 'No creditor',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('KES ${debt.remainingDouble.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                      Text('remaining', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (debt.percentagePaid / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      color: color,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${debt.percentagePaid.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: debt.isOverdue ? const Color(0xFFC2483F) : Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    debt.dueDate.isNotEmpty
                        ? 'Due ${DateFormat('MMM dd').format(DateTime.parse(debt.dueDate))}${debt.isOverdue ? ' (overdue)' : ''}'
                        : 'No due date',
                    style: TextStyle(
                      fontSize: 11,
                      color: debt.isOverdue ? const Color(0xFFC2483F) : Colors.grey[500],
                      fontWeight: debt.isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (debt.interestRateDouble > 0)
                    Text('${debt.interestRateDouble.toStringAsFixed(1)}% interest',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
