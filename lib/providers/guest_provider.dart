import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guest_model.dart';
import '../repositories/guest_repository.dart';

final guestsProvider = StreamProvider.family<List<GuestModel>, String>((ref, eventId) {
  final repository = ref.watch(guestRepositoryProvider);
  return repository.watchGuests(eventId);
});

final guestControllerProvider = StateNotifierProvider.family<GuestController, AsyncValue<void>, String>((ref, eventId) {
  return GuestController(
    repository: ref.watch(guestRepositoryProvider),
    eventId: eventId,
  );
});

class GuestController extends StateNotifier<AsyncValue<void>> {
  final GuestRepository repository;
  final String eventId;

  GuestController({
    required this.repository,
    required this.eventId,
  }) : super(const AsyncData(null));

  Future<void> addGuest({
    required String name,
    String? phone,
    String? email,
  }) async {
    state = const AsyncLoading();
    try {
      final guest = GuestModel(
        id: '',
        name: name,
        phone: phone,
        email: email,
      );
      await repository.addGuest(eventId, guest);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateGuest(GuestModel guest) async {
    state = const AsyncLoading();
    try {
      await repository.updateGuest(eventId, guest);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteGuest(String guestId) async {
    try {
      await repository.deleteGuest(eventId, guestId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
