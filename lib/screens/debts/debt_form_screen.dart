import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';

class DebtFormScreen extends ConsumerStatefulWidget {
  final Debt? debt;
  const DebtFormScreen({super.key, this.debt});

  @override
  ConsumerState<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends ConsumerState<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _creditorController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  final _minimumPaymentController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isRecurring = false;
  bool _loading = false;

  bool get isEditing => widget.debt != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.debt!.name;
      _creditorController.text = widget.debt!.creditor;
      _amountController.text = widget.debt!.totalAmount;
      _interestController.text = widget.debt!.interestRate;
      _minimumPaymentController.text = widget.debt!.minimumPayment;
      _notesController.text = widget.debt!.notes;
      _isRecurring = widget.debt!.isRecurring;
      if (widget.debt!.dueDate.isNotEmpty) {
        _dueDate = DateTime.parse(widget.debt!.dueDate);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditorController.dispose();
    _amountController.dispose();
    _interestController.dispose();
    _minimumPaymentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _nameController.text,
      'creditor': _creditorController.text,
      'total_amount': _amountController.text,
      'interest_rate': _interestController.text.isEmpty ? '0' : _interestController.text,
      'minimum_payment': _minimumPaymentController.text.isEmpty ? '0' : _minimumPaymentController.text,
      'due_date': DateFormat('yyyy-MM-dd').format(_dueDate),
      'is_recurring': _isRecurring,
      'notes': _notesController.text,
    };

    final notifier = ref.read(debtListProvider.notifier);
    if (isEditing) {
      await notifier.update(widget.debt!.id, data);
    } else {
      await notifier.create(data);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Debt' : 'Add Debt')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Debt Name',
                hintText: 'e.g., Home Loan, Credit Card',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _creditorController,
              decoration: const InputDecoration(
                labelText: 'Creditor',
                hintText: 'e.g., KCB Bank, M-Pesa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Total Amount',
                hintText: '0',
                prefixText: 'KES ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _interestController,
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%)',
                hintText: '0',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minimumPaymentController,
              decoration: const InputDecoration(
                labelText: 'Minimum Monthly Payment',
                hintText: '0',
                prefixText: 'KES ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recurring Monthly'),
              subtitle: const Text('Auto-reminder each month'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEditing ? 'Update Debt' : 'Add Debt'),
            ),
          ],
        ),
      ),
    );
  }
}
