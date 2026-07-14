import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/debt.dart';
import '../../models/debt_payment.dart';
import '../../providers/debt_provider.dart';
import 'debt_form_screen.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final Debt debt;
  const DebtDetailScreen({super.key, required this.debt});

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen> {
  late Debt _debt;

  @override
  void initState() {
    super.initState();
    _debt = widget.debt;
  }

  Color get _progressColor {
    if (_debt.percentagePaid >= 100) return const Color(0xFF1D8763);
    if (_debt.percentagePaid >= 50) return const Color(0xFFB8862F);
    return const Color(0xFFC2483F);
  }

  void _showRecordPaymentSheet() {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime paymentDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Record Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'KES ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Payment Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(paymentDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setSheetState(() => paymentDate = picked);
                },
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) return;
                    await ref.read(debtServiceProvider).createPayment(_debt.id, {
                      'amount': amountController.text,
                      'date': DateFormat('yyyy-MM-dd').format(paymentDate),
                      'notes': notesController.text,
                    });
                    ref.invalidate(debtPaymentsProvider(_debt.id));
                    ref.read(debtListProvider.notifier).load();
                    if (mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Record Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(debtPaymentsProvider(_debt.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(_debt.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => DebtFormScreen(debt: _debt)));
              ref.read(debtListProvider.notifier).load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Debt'),
                  content: Text('Delete "${_debt.name}"? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(debtListProvider.notifier).delete(_debt.id);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress ring + creditor
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: _debt.percentagePaid / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          color: _progressColor,
                        ),
                        Center(
                          child: Text(
                            '${_debt.percentagePaid.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_debt.creditor.isNotEmpty ? _debt.creditor : 'No creditor',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  if (_debt.isRecurring) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D8763).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Recurring', style: TextStyle(fontSize: 11, color: Color(0xFF1D8763))),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Metrics row
          Row(
            children: [
              _metricCard('Remaining', 'KES ${_debt.remainingDouble.toStringAsFixed(0)}', Icons.money, _debt.remainingDouble > 0 ? const Color(0xFFC2483F) : const Color(0xFF1D8763)),
              const SizedBox(width: 8),
              _metricCard('Paid', 'KES ${_debt.amountPaidDouble.toStringAsFixed(0)}', Icons.check_circle, const Color(0xFF1D8763)),
              const SizedBox(width: 8),
              _metricCard('Total', 'KES ${_debt.totalAmountDouble.toStringAsFixed(0)}', Icons.account_balance, Colors.blue),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _metricCard('Interest', '${_debt.interestRateDouble.toStringAsFixed(1)}%', Icons.percent, const Color(0xFFB8862F)),
              const SizedBox(width: 8),
              _metricCard('Min. Payment', 'KES ${_debt.minimumPaymentDouble.toStringAsFixed(0)}', Icons.payments, Colors.purple),
              const SizedBox(width: 8),
              _metricCard(
                'Due',
                _debt.dueDate.isNotEmpty ? DateFormat('MMM dd').format(DateTime.parse(_debt.dueDate)) : 'N/A',
                Icons.calendar_today,
                _debt.isOverdue ? const Color(0xFFC2483F) : const Color(0xFF1D8763),
              ),
            ],
          ),

          // Notes
          if (_debt.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(_debt.notes, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],

          // Payment history
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Payment History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _showRecordPaymentSheet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Record'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          payments.when(
            data: (list) {
              if (list.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long, size: 40, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('No payments yet', style: TextStyle(color: Colors.grey[500])),
                          const SizedBox(height: 4),
                          Text('Tap "Record" to add one', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Card(
                child: Column(
                  children: list.map((p) => _paymentTile(p)).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRecordPaymentSheet,
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(DebtPayment payment) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1D8763).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.check, color: Color(0xFF1D8763), size: 18),
      ),
      title: Text('KES ${payment.amountDouble.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        payment.date.isNotEmpty ? DateFormat('MMM dd, yyyy').format(DateTime.parse(payment.date)) : '',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey[400]),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Payment'),
              content: const Text('Remove this payment record?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(debtServiceProvider).deletePayment(_debt.id, payment.id);
            ref.invalidate(debtPaymentsProvider(_debt.id));
            ref.read(debtListProvider.notifier).load();
          }
        },
      ),
    );
  }
}
