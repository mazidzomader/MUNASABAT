import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<EventModel> createEvent(EventModel event) async {
    final batch = _firestore.batch();
    
    final eventRef = _firestore.collection('events').doc();
    batch.set(eventRef, event.toMap());
    
    final userRef = _firestore.collection('users').doc(event.hostId);
    batch.update(userRef, {
      'hostedEventIds': FieldValue.arrayUnion([eventRef.id])
    });

    await batch.commit();
    return EventModel.fromMap(event.toMap(), eventRef.id);
  }

  Stream<List<EventModel>> watchHostEvents(String hostId) {
    return _firestore
        .collection('events')
        .where('hostId', isEqualTo: hostId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<EventModel>> watchAttendingEvents(List<String> eventIds) {
    if (eventIds.isEmpty) return Stream.value([]);
    
    // Note: Firestore whereIn is limited to 10 items.
    // For MVP, this handles up to 10 events.
    final limitedIds = eventIds.take(10).toList();
    
    return _firestore
        .collection('events')
        .where(FieldPath.documentId, whereIn: limitedIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<EventModel?> watchEvent(String eventId) {
    return _firestore.collection('events').doc(eventId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return EventModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> updateEvent(EventModel event) async {
    final eventData = event.toMap();
    // Don't overwrite createdAt if it's already set
    eventData.remove('createdAt');
    await _firestore.collection('events').doc(event.id).update(eventData);
  }

  Future<void> deleteEvent(String eventId, String hostId) async {
    final batch = _firestore.batch();
    
    final eventRef = _firestore.collection('events').doc(eventId);
    batch.delete(eventRef);
    
    final userRef = _firestore.collection('users').doc(hostId);
    batch.update(userRef, {
      'hostedEventIds': FieldValue.arrayRemove([eventId])
    });

    await batch.commit();
  }
}
