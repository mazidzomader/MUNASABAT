import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory_model.dart';
import '../models/user_model.dart';

final memoryRepositoryProvider = Provider((ref) => MemoryRepository());

final eventMemoriesProvider = StreamProvider.family<List<MemoryModel>, String>((ref, eventId) {
  final repo = ref.watch(memoryRepositoryProvider);
  return repo.watchEventMemories(eventId);
});

class MemoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MemoryModel>> watchEventMemories(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('memories')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MemoryModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> uploadMemory(String base64Data, String eventId, UserModel uploader) async {
    // Save directly to Firestore as Base64
    final docRef = _firestore.collection('events').doc(eventId).collection('memories').doc();
    final memory = MemoryModel(
      id: docRef.id,
      eventId: eventId,
      uploaderId: uploader.id,
      uploaderName: uploader.name ?? 'Guest',
      base64Data: base64Data,
      timestamp: DateTime.now(),
    );

    await docRef.set(memory.toMap());
  }

  Future<void> deleteMemory(String eventId, String memoryId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('memories')
        .doc(memoryId)
        .delete();
  }
}
