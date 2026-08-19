import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gift_model.dart';
import '../models/withdrawal_model.dart';
import '../providers/auth_provider.dart';

final giftRepositoryProvider = Provider<GiftRepository>((ref) {
  return GiftRepository(FirebaseFirestore.instance);
});

class GiftRepository {
  final FirebaseFirestore _firestore;

  GiftRepository(this._firestore);

  Future<void> sendGift(String eventId, GiftModel gift) async {
    final docRef = _firestore.collection('events').doc(eventId).collection('gifts').doc();
    
    final giftWithId = GiftModel(
      id: docRef.id,
      senderId: gift.senderId,
      displayName: gift.displayName,
      amount: gift.amount,
      currency: gift.currency,
      message: gift.message,
      isAnonymous: gift.isAnonymous,
      paymentStatus: gift.paymentStatus,
      stripePaymentIntentId: gift.stripePaymentIntentId,
      createdAt: gift.createdAt ?? DateTime.now(),
    );

    await docRef.set(giftWithId.toMap());
  }

  Future<void> withdrawFunds(String eventId, int amount) async {
    final docRef = _firestore.collection('events').doc(eventId).collection('withdrawals').doc();
    
    final withdrawal = WithdrawalModel(
      id: docRef.id,
      amount: amount,
      status: 'completed',
      createdAt: DateTime.now(),
    );

    await docRef.set(withdrawal.toMap());
  }

  Stream<List<GiftModel>> watchEventGifts(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GiftModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<WithdrawalModel>> watchEventWithdrawals(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('withdrawals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WithdrawalModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<GiftModel>> watchMySentGifts(String userId) {
    // Requires a collection group query or just querying all events?
    // For MVP, we might just query all events where we are a guest, then fetch gifts.
    // Since Firebase doesn't allow easy cross-collection querying without collectionGroup,
    // we'll just use a collectionGroup query. Note: Needs index in Firestore!
    return _firestore
        .collectionGroup('gifts')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GiftModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}

// Providers
final eventGiftsProvider = StreamProvider.family<List<GiftModel>, String>((ref, eventId) {
  final repository = ref.watch(giftRepositoryProvider);
  return repository.watchEventGifts(eventId);
});

final eventWithdrawalsProvider = StreamProvider.family<List<WithdrawalModel>, String>((ref, eventId) {
  final repository = ref.watch(giftRepositoryProvider);
  return repository.watchEventWithdrawals(eventId);
});

final mySentGiftsProvider = StreamProvider<List<GiftModel>>((ref) {
  final user = ref.watch(currentUserModelProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final repository = ref.watch(giftRepositoryProvider);
  return repository.watchMySentGifts(user.id);
});
