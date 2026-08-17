import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

class ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addExpense(String eventId, ExpenseModel expense) async {
    final docRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .doc();
    
    final data = expense.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    
    await docRef.set(data);
  }

  Future<void> deleteExpense(String eventId, String expenseId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Stream<List<ExpenseModel>> watchExpenses(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
