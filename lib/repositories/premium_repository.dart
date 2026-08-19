import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/premium_model.dart';

final premiumRepositoryProvider = Provider((ref) => PremiumRepository());

final eventPremiumProvider = StreamProvider.family<PremiumModel, String>((ref, eventId) {
  final repository = ref.watch(premiumRepositoryProvider);
  return repository.watchPremiumStatus(eventId);
});

class PremiumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<PremiumModel> watchPremiumStatus(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('premium_status')
        .doc('status')
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return PremiumModel(eventId: eventId); // Default 5 images, no unlimited guests
      }
      return PremiumModel.fromMap(doc.data()!, eventId);
    });
  }

  Future<void> purchaseUnlimitedGuests(String eventId, String paymentIntentId) async {
    final docRef = _firestore.collection('events').doc(eventId).collection('premium_status').doc('status');
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        final newModel = PremiumModel(
          eventId: eventId,
          isPremium: true,
          purchasedAt: DateTime.now(),
          stripePaymentIntentId: paymentIntentId,
          unlockedFeatures: ['unlimited_guests'],
        );
        transaction.set(docRef, newModel.toMap());
      } else {
        final data = doc.data()!;
        List<String> features = List<String>.from(data['unlockedFeatures'] ?? []);
        if (!features.contains('unlimited_guests')) {
          features.add('unlimited_guests');
        }
        transaction.update(docRef, {
          'isPremium': true,
          'unlockedFeatures': features,
          'purchasedAt': FieldValue.serverTimestamp(),
          'stripePaymentIntentId': paymentIntentId,
        });
      }
    });
  }

  Future<void> purchaseImagePack(String eventId, String paymentIntentId) async {
    final docRef = _firestore.collection('events').doc(eventId).collection('premium_status').doc('status');
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        final newModel = PremiumModel(
          eventId: eventId,
          isPremium: true,
          purchasedAt: DateTime.now(),
          stripePaymentIntentId: paymentIntentId,
          imageLimit: 105, // 5 default + 100
        );
        transaction.set(docRef, newModel.toMap());
      } else {
        final data = doc.data()!;
        final currentLimit = data['imageLimit'] as int? ?? 5;
        transaction.update(docRef, {
          'isPremium': true,
          'imageLimit': currentLimit + 100,
          'purchasedAt': FieldValue.serverTimestamp(),
          'stripePaymentIntentId': paymentIntentId,
        });
      }
    });
  }
}
