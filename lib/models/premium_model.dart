class PremiumModel {
  final String eventId; // Use eventId as documentId
  final bool isPremium;
  final String? plan; // "unlimited_guests" | "extra_storage" | "hd_gallery" | "bundle"
  final DateTime? purchasedAt;
  final String? stripePaymentIntentId;
  final List<String> unlockedFeatures;
  final int imageLimit;

  const PremiumModel({
    required this.eventId,
    this.isPremium = false,
    this.plan,
    this.purchasedAt,
    this.stripePaymentIntentId,
    this.unlockedFeatures = const [],
    this.imageLimit = 5,
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
      stripePaymentIntentId: map['stripePaymentIntentId'] as String?,
      unlockedFeatures: List<String>.from(map['unlockedFeatures'] ?? []),
      imageLimit: map['imageLimit'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPremium': isPremium,
      'plan': plan,
      'purchasedAt': purchasedAt,
      'stripePaymentIntentId': stripePaymentIntentId,
      'unlockedFeatures': unlockedFeatures,
      'imageLimit': imageLimit,
    };
  }
}
