import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/features/auth/view/login_page.dart';
import 'package:eventorize_app/features/auth/view/health_page.dart';
import 'package:eventorize_app/features/auth/view/home_page.dart';
import 'package:eventorize_app/features/auth/view/signup_page.dart';
import 'package:eventorize_app/features/auth/view/splashscreen_page.dart';
import 'package:eventorize_app/features/auth/view/verify_page.dart';
import 'package:eventorize_app/features/auth/view/account_page.dart';
import 'package:eventorize_app/features/auth/view/detailprofile_page.dart';
import 'package:eventorize_app/data/api/shared_preferences_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/splashscreen',
        name: 'splashscreen',
        builder: (context, state) => const SplashScreenPage(),
      ),
      GoRoute(
        path: '/detailprof',
        name: 'detailprof',
        builder: (context, state) => const DetailprofilePage(),
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/verify-code',
        name: 'verify-code',
        builder: (context, state) => const VerificationCodePage(),
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
        
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}