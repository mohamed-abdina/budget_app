import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/income.dart';
import '../../providers/income_provider.dart';

class IncomeFormScreen extends ConsumerStatefulWidget {
  final Income? income;
  const IncomeFormScreen({super.key, this.income});

  @override
  ConsumerState<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends ConsumerState<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  int? _categoryId;
  DateTime _date = DateTime.now();
  bool _loading = false;

  bool get isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _amountController.text = widget.income!.amount;
      _descController.text = widget.income!.description;
      _categoryId = widget.income!.category;
      _date = DateTime.parse(widget.income!.date);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() => _loading = true);

    final data = {
      'category': _categoryId,
      'amount': _amountController.text,
      'description': _descController.text,
      'date': DateFormat('yyyy-MM-dd').format(_date),
    };

    final notifier = ref.read(incomeListProvider.notifier);
    if (isEditing) {
      await notifier.update(widget.income!.id, data);
    } else {
      await notifier.create(data);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(incomeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Income' : 'Add Income')),
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
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: 'KES '),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEditing ? 'Update' : 'Add Income'),
            ),
          ],
        ),
      ),
    );
  }
}
