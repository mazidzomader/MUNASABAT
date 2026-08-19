import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guest_model.dart';
import '../repositories/guest_repository.dart';
import 'auth_provider.dart';
import '../repositories/event_repository.dart';

final guestsProvider = StreamProvider.family<List<GuestModel>, String>((ref, eventId) {
  final repository = ref.watch(guestRepositoryProvider);
  return repository.watchGuests(eventId);
});

final currentGuestStatusProvider = StreamProvider.family<GuestModel?, String>((ref, eventId) {
  final user = ref.watch(currentUserModelProvider).valueOrNull;
  if (user == null) return Stream.value(null);

  final repository = ref.watch(guestRepositoryProvider);
  return repository.watchGuests(eventId).map(
    (guests) => guests.cast<GuestModel?>().firstWhere(
      (g) => g?.id == user.id,
      orElse: () => null,
    )
  );
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

final joinEventControllerProvider = StateNotifierProvider<JoinEventController, AsyncValue<void>>((ref) {
  return JoinEventController(ref);
});

class JoinEventController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  JoinEventController(this.ref) : super(const AsyncData(null));

  Future<void> joinEvent(String eventCode) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(currentUserModelProvider).valueOrNull;
      if (user == null) throw Exception('User not logged in');

      final eventRepository = ref.read(eventRepositoryProvider);
      final event = await eventRepository.getEventByCode(eventCode);

      if (event == null) {
        throw Exception('Invalid event code. Please check and try again.');
      }

      if (user.attendedEventIds.contains(event.id) || user.hostedEventIds.contains(event.id)) {
         throw Exception('You are already part of this event.');
      }

      final guestRepository = ref.read(guestRepositoryProvider);
      await guestRepository.requestToJoinEvent(event.id, user);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
