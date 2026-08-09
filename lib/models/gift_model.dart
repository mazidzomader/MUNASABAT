class GiftModel {
  final String id;
  final String senderId;
  final String? displayName; // null if anonymous
  final int amount;
  final String currency;
  final String? message;
  final bool isAnonymous;
  final String paymentStatus; // "pending" | "succeeded" | "failed"
  final String? sslcommerzTranId;
  final DateTime? createdAt;

  const GiftModel({
    required this.id,
    required this.senderId,
    this.displayName,
    required this.amount,
    required this.currency,
    this.message,
    this.isAnonymous = false,
    this.paymentStatus = 'pending',
    this.sslcommerzTranId,
    this.createdAt,
  });

  factory GiftModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GiftModel(
      id: documentId,
      senderId: map['senderId'] as String,
      displayName: map['displayName'] as String?,
      amount: map['amount'] as int,
      currency: map['currency'] as String,
      message: map['message'] as String?,
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      paymentStatus: map['paymentStatus'] as String? ?? 'pending',
      sslcommerzTranId: map['sslcommerzTranId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'displayName': displayName,
      'amount': amount,
      'currency': currency,
      'message': message,
      'isAnonymous': isAnonymous,
      'paymentStatus': paymentStatus,
      'sslcommerzTranId': sslcommerzTranId,
      'createdAt': createdAt,
    };
  }
}
