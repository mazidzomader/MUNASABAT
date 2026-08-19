class WithdrawalModel {
  final String id;
  final int amount;
  final String status;
  final DateTime createdAt;

  const WithdrawalModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory WithdrawalModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WithdrawalModel(
      id: documentId,
      amount: map['amount'] as int,
      status: map['status'] as String? ?? 'completed',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
