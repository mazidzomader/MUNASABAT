import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/event/event_screen.dart';
import '../../features/checklist/checklist_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/memories/memories_screen.dart';
import '../../features/memories/widgets/full_screen_image_viewer.dart';
import '../../models/memory_model.dart';
import '../../features/premium/premium_upgrade_screen.dart';
import '../../features/guest/guest_screen.dart';
import '../../features/invitations/invitation_screen.dart';
import '../../features/guest_portal/attending_screen.dart';
import '../../features/gifts/send_gift_screen.dart';
import '../../features/gifts/gift_wallet_screen.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/auth_provider.dart';

/// All named routes used throughout the app.
abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const eventsList = '/events';
  static const createEvent = '/event/create';
  static const editEvent = '/event/:eventId/edit';
  static const eventDetail = '/event/:eventId';
  static const eventChecklist = '/event/:eventId/checklist';
  static const eventBudget = '/event/:eventId/budget';
  static const eventGuests = '/event/:eventId/guests';
  static const eventInvitation = '/event/:eventId/invitation';
  static const eventAttending = '/event/:eventId/attending';
  static const sendGift = '/event/:eventId/gifts/send';
  static const giftWallet = '/event/:eventId/gifts/wallet';
  static const locationPicker = '/location-picker';
}

/// A refresh notifier to trigger GoRouter redirects when auth state changes.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) {
      notifyListeners();
    });
    _ref.listen(currentUserModelProvider, (_, _) {
      notifyListeners();
    });
  }
  final Ref _ref;
}

/// Provides the singleton [GoRouter] instance.
///
/// Route guard: unauthenticated users are always redirected to [AppRoutes.login].
/// Authenticated users are redirected to their role-appropriate home screen.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      
      if (authState.isLoading) return null;

      final User? user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isOnAuth) return AppRoutes.login;
      
      if (isLoggedIn && isOnAuth) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (ctx, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (ctx2, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.eventsList,
        builder: (ctx, _) => const EventListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createEvent,
        builder: (ctx, _) => const CreateEventScreen(),
      ),
      GoRoute(
        path: AppRoutes.editEvent,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return EditEventScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventDetail,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventChecklist,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return ChecklistScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventBudget,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return BudgetScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventGuests,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return GuestScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventInvitation,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return InvitationScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventAttending,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return AttendingScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.sendGift,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return SendGiftScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.giftWallet,
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return GiftWalletScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.locationPicker,
        builder: (context, state) {
          final initial = state.extra as LatLng?;
          return LocationPickerScreen(initialLocation: initial);
        },
      ),
      GoRoute(
        path: '/event/:eventId/premium',
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return PremiumUpgradeScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/event/:eventId/memories',
        builder: (ctx, state) {
          final eventId = state.pathParameters['eventId']!;
          return MemoriesScreen(eventId: eventId);
        },
        routes: [
          GoRoute(
            path: 'viewer',
            builder: (ctx, state) {
              final extra = state.extra as Map<String, dynamic>;
              final memories = extra['memories'] as List<MemoryModel>;
              final initialIndex = extra['initialIndex'] as int;
              return FullScreenImageViewer(
                memories: memories,
                initialIndex: initialIndex,
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
