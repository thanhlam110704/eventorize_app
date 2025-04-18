import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/features/auth/view/login_page.dart';
import 'package:eventorize_app/features/auth/view/health_page.dart';
import 'package:eventorize_app/features/auth/view/home_page.dart';
import 'package:eventorize_app/data/api/shared_preferences_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/health-check',
        name: 'health-check',
        builder: (context, state) => const HealthCheckPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
        redirect: (BuildContext context, GoRouterState state) async {
          final token = await SharedPreferencesService.getToken();
          if (token == null) {
            return '/login';
          }
          return null;
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}