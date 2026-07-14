import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: expenses.when(
        data: (list) {
          if (list.isEmpty) return const EmptyState(icon: Icons.arrow_upward, message: 'No expenses recorded');
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];
              return TransactionTile(
                title: item.description,
                subtitle: '${item.categoryName} - ${item.date}',
                amount: item.amountDouble.toStringAsFixed(0),
                isIncome: false,
                categoryColor: Color(int.parse('FF${item.categoryColor.replaceFirst('#', '')}', radix: 16)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: item))),
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
