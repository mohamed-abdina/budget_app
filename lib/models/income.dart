class Income {
  final int id;
  final int category;
  final String categoryName;
  final String categoryColor;
  final String amount;
  final String description;
  final String date;

  Income({
    required this.id,
    required this.category,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      category: json['category'],
      categoryName: json['category_name'] ?? '',
      categoryColor: json['category_color'] ?? '#1D8763',
      amount: json['amount'].toString(),
      description: json['description'],
      date: json['date'],
    );
  }

  double get amountDouble => double.tryParse(amount) ?? 0;
}
