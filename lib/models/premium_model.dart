class PremiumModel {
  final String eventId; // Use eventId as documentId
  final bool isPremium;
  final String? plan; // "unlimited_guests" | "extra_storage" | "hd_gallery" | "bundle"
  final DateTime? purchasedAt;
  final String? sslcommerzTranId;
  final List<String> unlockedFeatures;

  const PremiumModel({
    required this.eventId,
    this.isPremium = false,
    this.plan,
    this.purchasedAt,
    this.sslcommerzTranId,
    this.unlockedFeatures = const [],
  });

  factory PremiumModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PremiumModel(
      eventId: documentId,
      isPremium: map['isPremium'] as bool? ?? false,
      plan: map['plan'] as String?,
      purchasedAt: map['purchasedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['purchasedAt'].millisecondsSinceEpoch)
          : null,
      sslcommerzTranId: map['sslcommerzTranId'] as String?,
      unlockedFeatures: List<String>.from(map['unlockedFeatures'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPremium': isPremium,
      'plan': plan,
      'purchasedAt': purchasedAt,
      'sslcommerzTranId': sslcommerzTranId,
      'unlockedFeatures': unlockedFeatures,
    };
  }
}
