class ExpenseModel {
  final String id;
  final String label;
  final String category;
  final int amount; // Store as integer (smallest currency unit e.g. cents)
  final DateTime? createdAt;

  const ExpenseModel({
    required this.id,
    required this.label,
    required this.category,
    required this.amount,
    this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      label: map['label'] as String,
      category: map['category'] as String,
      amount: map['amount'] as int,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'category': category,
      'amount': amount,
      'createdAt': createdAt,
    };
  }
}
