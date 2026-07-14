import 'package:flutter/material.dart';

class BudgetProgressBar extends StatelessWidget {
  final String label;
  final double percentage;
  final double spent;
  final double limit;
  final Color color;

  const BudgetProgressBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.spent,
    required this.limit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = percentage > 100
        ? Colors.red
        : percentage > 80
            ? Colors.orange
            : color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(color: barColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('KES ${spent.toStringAsFixed(0)} spent', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text('KES ${limit.toStringAsFixed(0)} limit', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
