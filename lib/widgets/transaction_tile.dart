import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final Color categoryColor;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: categoryColor.withValues(alpha: 0.15),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: categoryColor,
          size: 18,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Text(
        '${isIncome ? '+' : '-'}KES $amount',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
