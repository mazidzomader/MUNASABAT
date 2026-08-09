import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// ── Repository Provider ────────────────────────────────────────────────────

/// Provides the singleton [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ── Auth State Stream ──────────────────────────────────────────────────────

/// Streams the current Firebase [User], or null when signed out.
///
/// Widgets can watch this to reactively respond to sign-in/out events.
/// Route guard in [AppRouter] watches this to redirect to /login.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ── Current UserModel ──────────────────────────────────────────────────────

/// Fetches the [UserModel] for the current user from Firestore.
///
/// Returns null if not signed in or no Firestore record exists yet.
final currentUserModelProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(authRepositoryProvider).getUserModel(user.uid);
});

// ── Auth Notifier ──────────────────────────────────────────────────────────

/// Drives the UI state for all auth operations.
///
/// All async auth calls go through this notifier, which surfaces
/// loading/error/success via [AsyncValue] — no manual `isLoading` booleans.
class AuthNotifier extends AsyncNotifier<void> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Register with email/password and an optional phone number.
  /// The phone is stored as a profile field — no OTP verification required.
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.registerWithEmail(
          email: email,
          password: password,
          name: name,
          phone: phone,
        ));
  }

  /// Login with email/password.
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.loginWithEmail(
          email: email,
          password: password,
        ));
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.sendPasswordResetEmail(email));
  }

  /// Sign out.
  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.logout());
  }
}

/// The primary auth notifier provider used by all auth screens.
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
