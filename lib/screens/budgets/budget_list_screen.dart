import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/budget_progress_bar.dart';
import '../../widgets/empty_state.dart';
import 'budget_form_screen.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: budgets.when(
        data: (list) {
          if (list.isEmpty) return const EmptyState(icon: Icons.pie_chart, message: 'No budgets set');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final b = list[i];
              return Card(
                child: ListTile(
                  title: Text(b.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: BudgetProgressBar(
                    label: '',
                    percentage: b.percentage,
                    spent: b.spentDouble,
                    limit: b.amountDouble,
                    color: Color(int.parse('FF${b.categoryColor.replaceFirst('#', '')}', radix: 16)),
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetFormScreen(budget: b))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Budget'),
                          content: const Text('Are you sure?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) ref.read(budgetListProvider.notifier).delete(b.id);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
