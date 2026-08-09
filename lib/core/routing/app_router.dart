import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/host_dashboard/screens/dashboard_screen.dart';
import '../../features/guest_portal/screens/guest_home_screen.dart';
import '../../providers/auth_provider.dart';

/// All named routes used throughout the app.
abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const guestHome = '/guest/home';
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
        final userModelAsync = ref.read(currentUserModelProvider);
        if (userModelAsync.isLoading) {
          // Wait on the current screen (e.g. splash or login) until role is fetched
          return null; 
        }
        
        final role = userModelAsync.valueOrNull?.role;
        if (role == 'guest') return AppRoutes.guestHome;
        return AppRoutes.dashboard; // Fallback
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
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
        path: AppRoutes.guestHome,
        builder: (ctx3, _) => const GuestHomeScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
