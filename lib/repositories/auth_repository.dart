import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

/// Abstracts all Firebase Authentication and user-profile operations.
///
/// This is the **only** layer in the app allowed to import and call
/// [FirebaseAuth] directly (per Architecture.md). All auth state and
/// operations flow through this repository; providers and widgets never
/// call FirebaseAuth or Firestore directly.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ── Auth State ─────────────────────────────────────────────────────────────

  /// Live stream of the currently signed-in [User], or null when signed out.
  /// Used by [authStateProvider] for session persistence.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  // ── Email / Password ───────────────────────────────────────────────────────

  /// Registers a new host account with email and password.
  ///
  /// Creates the Firebase Auth user, then writes a `users/{uid}` Firestore
  /// document with [role] = "host". An optional [phone] number is stored
  /// as a profile field with no OTP verification.
  /// Throws [FirebaseAuthException] on failure.
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(name);
    await _createUserDocument(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      role: 'host',
    );
  }

  /// Signs in an existing user with email and password.
  ///
  /// Throws [FirebaseAuthException] on wrong credentials.
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sends a password-reset email to [email].
  ///
  /// Throws [FirebaseAuthException] if the email is not registered.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  /// Signs out the current user.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── User Profile ───────────────────────────────────────────────────────────

  /// Returns the [UserModel] for [uid] from Firestore, or null if not found.
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  Future<void> _createUserDocument({
    required String uid,
    String? name,
    String? email,
    String? phone,
    required String role,
  }) async {
    final model = UserModel(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(uid).set(model.toMap());
  }

  /// Converts a [FirebaseAuthException] code to a plain-language message
  /// per Rules.md §5.
  static String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with that email already exists. Try logging in instead.';
      case 'user-not-found':
        return 'No account found with that email. Check the address or register.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'That doesn\'t look like a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and retry.';
      default:
        debugPrint('[AuthRepository] unhandled error: ${e.code} – ${e.message}');
        return 'Something went wrong. Please try again. (${e.code})';
    }
  }
}

/// Public helper — accessible to any layer that catches a [FirebaseAuthException].
String mapFirebaseAuthError(FirebaseAuthException e) =>
    AuthRepository._mapAuthError(e);
