import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/views/login_connector.dart';
import '../../features/auth/views/register_connector.dart';
import '../../features/counter/views/counter_connector.dart';
import '../../shared/widgets/home_connector.dart';
import '../store/app_state.dart';
import 'auth_notifier.dart';

class AppRouter {
  static GoRouter createRouter(Store<AppState> store) {
    final authNotifier = AuthNotifier(store);

    return GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final isLoggedIn = store.state.auth.isLoggedIn;
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/login/register';

        // If not logged in and not going to auth pages, redirect to login
        if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
          return '/login';
        }

        // If logged in and going to auth pages, redirect to home
        if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
          return '/home';
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => _buildPageWithTransition(context, state, const LoginConnector(), 'Login'),
          routes: [
            // Register as a subroute of login
            GoRoute(
              path: 'register',
              name: 'register',
              pageBuilder: (context, state) =>
                  _buildPageWithTransition(context, state, const RegisterConnector(), 'Register'),
            ),
          ],
        ),

        // Main App Routes
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => _buildPageWithTransition(context, state, const HomeConnector(), 'Home'),
          routes: [
            // Nested routes under home
            GoRoute(
              path: 'counter',
              name: 'counter',
              pageBuilder: (context, state) =>
                  _buildPageWithTransition(context, state, const CounterConnector(), 'Counter'),
            ),
          ],
        ),

        // Direct counter route (for web URLs)
        GoRoute(path: '/counter', redirect: (context, state) => '/home/counter'),
      ],

      // Error page for unknown routes
      errorPageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Page not found: ${state.uri.path}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Go Home')),
              ],
            ),
          ),
        ),
        'Error',
      ),
    );
  }

  // Helper method to build pages with transitions
  static Page<dynamic> _buildPageWithTransition(BuildContext context, GoRouterState state, Widget child, String name) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      name: name,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use different transitions for web vs mobile
        if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
          // Mobile: Slide transition
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        } else {
          // Web/Desktop: Fade transition
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          );
        }
      },
    );
  }
}

// Extension for easy navigation
extension AppRouterExtension on BuildContext {
  void goToLogin() => go('/login');
  void goToRegister() => go('/login/register');
  void goToHome() => go('/home');
  void goToCounter() => go('/home/counter');

  void pushLogin() => push('/login');
  void pushRegister() => push('/login/register');
  void pushHome() => push('/home');
  void pushCounter() => push('/home/counter');

  void goToTestFeature() => go('/test-feature');
  void pushTestFeature() => push('/test-feature');
}
