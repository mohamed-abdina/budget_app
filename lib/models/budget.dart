class Budget {
  final int id;
  final int category;
  final String categoryName;
  final String categoryColor;
  final String amount;
  final int month;
  final int year;
  final String spent;
  final String remaining;
  final double percentage;

  Budget({
    required this.id,
    required this.category,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.month,
    required this.year,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      categoryName: json['category_name'] ?? '',
      categoryColor: json['category_color'] ?? '#C2483F',
      amount: json['amount'].toString(),
      month: json['month'],
      year: json['year'],
      spent: json['spent'].toString(),
      remaining: json['remaining'].toString(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  double get amountDouble => double.tryParse(amount) ?? 0;
  double get spentDouble => double.tryParse(spent) ?? 0;
  double get remainingDouble => double.tryParse(remaining) ?? 0;
}
