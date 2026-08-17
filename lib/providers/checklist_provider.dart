import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checklist_item_model.dart';
import '../repositories/checklist_repository.dart';

final checklistProvider = StreamProvider.family<List<ChecklistItemModel>, String>((ref, eventId) {
  final repository = ref.watch(checklistRepositoryProvider);
  return repository.watchChecklist(eventId);
});

final checklistControllerProvider = StateNotifierProvider.family<ChecklistController, AsyncValue<void>, String>((ref, eventId) {
  return ChecklistController(
    repository: ref.watch(checklistRepositoryProvider),
    eventId: eventId,
  );
});

class ChecklistController extends StateNotifier<AsyncValue<void>> {
  final ChecklistRepository repository;
  final String eventId;

  ChecklistController({
    required this.repository,
    required this.eventId,
  }) : super(const AsyncData(null));

  Future<void> addItem(String title) async {
    state = const AsyncLoading();
    try {
      final item = ChecklistItemModel(id: '', title: title);
      await repository.addChecklistItem(eventId, item);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleItemCompletion(ChecklistItemModel item) async {
    // We don't set to loading to avoid full UI rebuilds for a simple toggle.
    // We update it optimistically in the UI usually, or wait for firestore snapshot.
    try {
      final updatedItem = ChecklistItemModel(
        id: item.id,
        title: item.title,
        isCompleted: !item.isCompleted,
        createdAt: item.createdAt,
      );
      await repository.updateChecklistItem(eventId, updatedItem);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await repository.deleteChecklistItem(eventId, itemId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
