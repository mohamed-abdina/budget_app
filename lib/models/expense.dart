class Expense {
  final int id;
  final int category;
  final String categoryName;
  final String categoryColor;
  final String amount;
  final String description;
  final String date;

  Expense({
    required this.id,
    required this.category,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      category: json['category'],
      categoryName: json['category_name'] ?? '',
      categoryColor: json['category_color'] ?? '#C2483F',
      amount: json['amount'].toString(),
      description: json['description'],
      date: json['date'],
    );
  }

  double get amountDouble => double.tryParse(amount) ?? 0;
}
