import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guest_model.dart';

final guestRepositoryProvider = Provider<GuestRepository>((ref) {
  return GuestRepository(FirebaseFirestore.instance);
});

class GuestRepository {
  final FirebaseFirestore _firestore;

  GuestRepository(this._firestore);

  Stream<List<GuestModel>> watchGuests(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GuestModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addGuest(String eventId, GuestModel guest) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .add(guest.toMap());
  }

  Future<void> updateGuest(String eventId, GuestModel guest) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .doc(guest.id)
        .update(guest.toMap());
  }

  Future<void> deleteGuest(String eventId, String guestId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .doc(guestId)
        .delete();
  }
}
