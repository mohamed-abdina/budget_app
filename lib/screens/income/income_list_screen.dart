import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/income_provider.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import 'income_form_screen.dart';

class IncomeListScreen extends ConsumerWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomes = ref.watch(incomeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Income')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: incomes.when(
        data: (list) {
          if (list.isEmpty) return const EmptyState(icon: Icons.arrow_downward, message: 'No income recorded');
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];
              return TransactionTile(
                title: item.description,
                subtitle: '${item.categoryName} - ${item.date}',
                amount: item.amountDouble.toStringAsFixed(0),
                isIncome: true,
                categoryColor: Color(int.parse('FF${item.categoryColor.replaceFirst('#', '')}', radix: 16)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncomeFormScreen(income: item))),
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
