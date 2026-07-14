class DebtPayment {
  final int id;
  final int debt;
  final String amount;
  final String date;
  final String notes;

  DebtPayment({
    required this.id,
    required this.debt,
    required this.amount,
    required this.date,
    required this.notes,
  });

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      id: json['id'],
      debt: json['debt'],
      amount: json['amount'].toString(),
      date: json['date'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  double get amountDouble => double.tryParse(amount) ?? 0;
}
