import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/features/auth/view/login_page.dart';
import 'package:eventorize_app/features/auth/view/health_page.dart';
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/health-check',
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}