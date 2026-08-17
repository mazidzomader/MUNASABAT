import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_item_model.dart';

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return ChecklistRepository();
});

class ChecklistRepository {
  final FirebaseFirestore _firestore;

  ChecklistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addChecklistItem(String eventId, ChecklistItemModel item) async {
    final docRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('checklist')
        .doc();
    
    final itemData = item.toMap();
    itemData['createdAt'] = FieldValue.serverTimestamp();
    
    await docRef.set(itemData);
  }

  Future<void> updateChecklistItem(String eventId, ChecklistItemModel item) async {
    final itemData = item.toMap();
    itemData.remove('createdAt'); // Do not overwrite creation time
    
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('checklist')
        .doc(item.id)
        .update(itemData);
  }

  Future<void> deleteChecklistItem(String eventId, String itemId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('checklist')
        .doc(itemId)
        .delete();
  }

  Stream<List<ChecklistItemModel>> watchChecklist(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('checklist')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChecklistItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
