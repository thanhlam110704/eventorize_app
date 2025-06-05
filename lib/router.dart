import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/features/auth/view/login_page.dart';
import 'package:eventorize_app/features/auth/view/home_page.dart';
import 'package:eventorize_app/features/auth/view/register_page.dart';
import 'package:eventorize_app/features/auth/view/splashscreen_page.dart';
import 'package:eventorize_app/features/auth/view/verify_page.dart';
import 'package:eventorize_app/features/auth/view/account_page.dart';
import 'package:eventorize_app/features/auth/view/eventdetail_page.dart';
import 'package:eventorize_app/features/auth/view/detail_profile_page.dart';
import 'package:eventorize_app/features/auth/view/favorite_page.dart';
import 'package:eventorize_app/features/auth/view/checkout_page.dart';
import 'package:eventorize_app/features/auth/view/payment_page.dart';
import 'package:eventorize_app/features/auth/view/paymentstate_page.dart';
import 'package:eventorize_app/features/auth/view/tickets_page.dart';
import 'package:eventorize_app/features/auth/view/tickets_detail_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/tickets-detail',
    routes: [
      GoRoute(
        path: '/splashscreen',
        name: 'splashscreen',
        builder: (context, state) => const SplashScreenPage(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckOutPage(),
      ),
      GoRoute(
        path: '/tickets-detail',
        name: 'tickets-detail',
        builder: (context, state) => const TicketsDetailPage(),
      ),
      GoRoute(
        path: '/tickets',
        name: 'tickets',
        builder: (context, state) => const TicketsPage(),
      ),
      GoRoute(
        path: '/paymentsuccess',
        name: 'paymentsucess',
        builder: (context, state) => const PaymentSuccessfulPage(),
      ),
      GoRoute(
        path: '/paymentfail',
        name: 'paymentfail',
        builder: (context, state) => const PaymentFailedPage(),
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentPage(),
      ),
      GoRoute(
        path: '/favorite',
        name: 'favorite',
        builder: (context, state) => const FavoritePage(),
      ),
      GoRoute(
        path: '/event-detail',
        name: 'event-detail',
        builder: (context, state) => const EventDetailPage(),
      ),
      GoRoute(
        path: '/detailprof',
        name: 'detailprof',
        builder: (context, state) => const DetailProfilePage(),
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
        builder: (context, state) => const RegisterPage(),
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