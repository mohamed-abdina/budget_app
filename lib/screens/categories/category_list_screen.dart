import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../widgets/empty_state.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryTab(
            categoriesProvider: expenseCategoriesProvider,
            onDelete: (id) => ref.read(expenseCategoriesProvider.notifier).delete(id),
          ),
          _CategoryTab(
            categoriesProvider: incomeCategoriesProvider,
            onDelete: (id) => ref.read(incomeCategoriesProvider.notifier).delete(id),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends ConsumerWidget {
  final StateNotifierProvider<dynamic, AsyncValue<List<Category>>> categoriesProvider;
  final Future<void> Function(int id) onDelete;

  const _CategoryTab({
    required this.categoriesProvider,
    required this.onDelete,
  });

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return categories.when(
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.category,
            message: 'No categories yet',
          );
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final cat = list[i];
            final color = _parseColor(cat.color);
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.label, color: color, size: 20),
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(cat.color, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Category'),
                      content: Text('Delete "${cat.name}"? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) await onDelete(cat.id);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryFormScreen(
                      category: cat,
                      type: categoriesProvider == expenseCategoriesProvider
                          ? CategoryType.expense
                          : CategoryType.income,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
