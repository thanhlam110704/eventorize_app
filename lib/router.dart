import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/features/auth/view/login_page.dart';
import 'package:eventorize_app/features/auth/view/home_page.dart';
import 'package:eventorize_app/features/auth/view/register_page.dart';
import 'package:eventorize_app/features/auth/view/splashscreen_page.dart';
import 'package:eventorize_app/features/auth/view/verify_page.dart';
import 'package:eventorize_app/features/auth/view/account_page.dart';
import 'package:eventorize_app/features/auth/view/profile_detail_page.dart';
import 'package:eventorize_app/features/auth/view/favorite_page.dart';
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splashscreen',
    routes: [
      GoRoute(
        path: '/splashscreen',
        name: 'splashscreen',
        builder: (context, state) => const SplashScreenPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/detail-profile',
        name: 'detail-profile',
        builder: (context, state) => const ProfileDetailPage(),
      ),
      GoRoute(
        path: '/favorite',
        name: 'favorite',
        builder: (context, state) => const FavoritePage(),
      ),
      GoRoute(
      path: '/verify-code',
      name: 'verify-code',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String? ?? '';
        return VerificationCodePage(email: email);
        },
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