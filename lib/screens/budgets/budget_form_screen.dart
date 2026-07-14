import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/budget.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  final Budget? budget;
  const BudgetFormScreen({super.key, this.budget});

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _categoryId;
  int? _month;
  int? _year;
  bool _loading = false;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _amountController.text = widget.budget!.amount;
      _categoryId = widget.budget!.category;
      _month = widget.budget!.month;
      _year = widget.budget!.year;
    } else {
      final now = DateTime.now();
      _month = now.month;
      _year = now.year;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null || _month == null || _year == null) return;
    setState(() => _loading = true);

    final data = {
      'category': _categoryId,
      'amount': _amountController.text,
      'month': _month,
      'year': _year,
    };

    final notifier = ref.read(budgetListProvider.notifier);
    if (isEditing) {
      await notifier.update(widget.budget!.id, data);
    } else {
      await notifier.create(data);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Budget' : 'Add Budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            categories.when(
              data: (cats) => DropdownButtonFormField<int>(
                initialValue: _categoryId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                hint: const Text('Select a category'),
                items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly Limit', border: OutlineInputBorder(), prefixText: 'KES '),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _month,
              decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
              items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(DateTime(2024, i + 1).month.toString().padLeft(2, '0')))),
              onChanged: (v) => setState(() => _month = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _year,
              decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
              items: List.generate(5, (i) => DropdownMenuItem(value: 2023 + i, child: Text('${2023 + i}'))),
              onChanged: (v) => setState(() => _year = v),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEditing ? 'Update' : 'Add Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
