import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';

enum CategoryType { expense, income }

class CategoryFormScreen extends ConsumerStatefulWidget {
  final Category? category;
  final CategoryType type;

  const CategoryFormScreen({
    super.key,
    this.category,
    this.type = CategoryType.expense,
  });

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedColor = '#1D8763';
  bool _loading = false;

  bool get isEditing => widget.category != null;

  static const _presetColors = [
    '#1D8763',
    '#C2483F',
    '#B8862F',
    '#3F7FC2',
    '#8B5CF6',
    '#EC4899',
    '#F97316',
    '#14B8A6',
    '#6366F1',
    '#84CC16',
    '#EF4444',
    '#0EA5E9',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.category!.name;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _nameController.text.trim(),
      'color': _selectedColor,
      'icon': 'ti-cash',
    };

    try {
      if (widget.type == CategoryType.expense) {
        final notifier = ref.read(expenseCategoriesProvider.notifier);
        if (isEditing) {
          await notifier.update(widget.category!.id, data);
        } else {
          await notifier.create(data);
        }
      } else {
        final notifier = ref.read(incomeCategoriesProvider.notifier);
        if (isEditing) {
          await notifier.update(widget.category!.id, data);
        } else {
          await notifier.create(data);
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = widget.type == CategoryType.expense ? 'Expense' : 'Income';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit $typeLabel Category' : 'New $typeLabel Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                hintText: 'e.g. Groceries, Salary',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            const Text('Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presetColors.map((hex) {
                final color = _parseColor(hex);
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
