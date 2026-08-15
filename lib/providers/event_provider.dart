import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import 'auth_provider.dart';

final hostEventsProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  final userModel = ref.watch(currentUserModelProvider).valueOrNull;
  if (userModel == null) return const Stream.empty();

  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchHostEvents(userModel.id);
});

final attendingEventsProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  final userModel = ref.watch(currentUserModelProvider).valueOrNull;
  if (userModel == null || userModel.attendedEventIds.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchAttendingEvents(userModel.attendedEventIds);
});

final eventDetailProvider = StreamProvider.family
    .autoDispose<EventModel?, String>((ref, eventId) {
      final repository = ref.watch(eventRepositoryProvider);
      return repository.watchEvent(eventId);
    });

final eventControllerProvider =
    StateNotifierProvider<EventController, AsyncValue<void>>((ref) {
      return EventController(ref.watch(eventRepositoryProvider), ref);
    });

class EventController extends StateNotifier<AsyncValue<void>> {
  final EventRepository _repository;
  final Ref _ref;

  EventController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> createEvent({
    required String title,
    required DateTime date,
    required String venueName,
    String? description,
    String? coverImageUrl,
    Map<String, double>? venueLatLng,
  }) async {
    state = const AsyncLoading();

    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('User not logged in');

      final event = EventModel(
        id: '', // Will be assigned by Firestore
        hostId: user.uid,
        title: title,
        date: date,
        venueName: venueName,
        description: description,
        coverImageUrl: coverImageUrl,
        venueLatLng: venueLatLng,
        createdAt: DateTime.now(),
        privacy: 'private',
      );

      await _repository.createEvent(event);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateEvent(EventModel event) async {
    state = const AsyncLoading();
    try {
      await _repository.updateEvent(event);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    state = const AsyncLoading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('User not logged in');
      
      await _repository.deleteEvent(eventId, user.uid);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
