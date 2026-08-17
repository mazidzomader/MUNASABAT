import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

final expensesProvider = StreamProvider.family<List<ExpenseModel>, String>((ref, eventId) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpenses(eventId);
});

final expenseControllerProvider = StateNotifierProvider.family<ExpenseController, AsyncValue<void>, String>((ref, eventId) {
  return ExpenseController(
    repository: ref.watch(expenseRepositoryProvider),
    eventId: eventId,
  );
});

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  final ExpenseRepository repository;
  final String eventId;

  ExpenseController({
    required this.repository,
    required this.eventId,
  }) : super(const AsyncData(null));

  Future<void> addExpense({
    required String label,
    required String category,
    required int amount,
  }) async {
    state = const AsyncLoading();
    try {
      final expense = ExpenseModel(
        id: '',
        label: label,
        category: category,
        amount: amount,
      );
      await repository.addExpense(eventId, expense);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await repository.deleteExpense(eventId, expenseId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
