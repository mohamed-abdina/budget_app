class Debt {
  final int id;
  final String name;
  final String creditor;
  final String totalAmount;
  final String amountPaid;
  final String interestRate;
  final String minimumPayment;
  final String dueDate;
  final bool isRecurring;
  final String notes;
  final String dateCreated;

  Debt({
    required this.id,
    required this.name,
    required this.creditor,
    required this.totalAmount,
    required this.amountPaid,
    required this.interestRate,
    required this.minimumPayment,
    required this.dueDate,
    required this.isRecurring,
    required this.notes,
    required this.dateCreated,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      name: json['name'] ?? '',
      creditor: json['creditor'] ?? '',
      totalAmount: json['total_amount'].toString(),
      amountPaid: (json['amount_paid'] ?? 0).toString(),
      interestRate: (json['interest_rate'] ?? 0).toString(),
      minimumPayment: (json['minimum_payment'] ?? 0).toString(),
      dueDate: json['due_date'] ?? '',
      isRecurring: json['is_recurring'] ?? false,
      notes: json['notes'] ?? '',
      dateCreated: json['date_created'] ?? '',
    );
  }

  double get totalAmountDouble => double.tryParse(totalAmount) ?? 0;
  double get amountPaidDouble => double.tryParse(amountPaid) ?? 0;
  double get remainingDouble => totalAmountDouble - amountPaidDouble;
  double get minimumPaymentDouble => double.tryParse(minimumPayment) ?? 0;
  double get interestRateDouble => double.tryParse(interestRate) ?? 0;
  double get percentagePaid => totalAmountDouble > 0 ? (amountPaidDouble / totalAmountDouble * 100).clamp(0, 100) : 0;

  bool get isOverdue {
    if (dueDate.isEmpty) return false;
    try {
      final due = DateTime.parse(dueDate);
      return due.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
