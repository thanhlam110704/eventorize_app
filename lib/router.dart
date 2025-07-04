import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/features/auth/view/login_page.dart';
import 'package:eventorize_app/features/auth/view/home_page.dart';
import 'package:eventorize_app/features/auth/view/checkout_page.dart';
import 'package:eventorize_app/features/auth/view/register_page.dart';
import 'package:eventorize_app/features/auth/view/splashscreen_page.dart';
import 'package:eventorize_app/features/auth/view/verify_page.dart';
import 'package:eventorize_app/features/auth/view/account_page.dart';
import 'package:eventorize_app/features/auth/view/profile_detail_page.dart';
import 'package:eventorize_app/features/auth/view/favorite_page.dart';
import 'package:eventorize_app/features/auth/view/event_detail_page.dart';
import 'package:eventorize_app/features/auth/view/payment_page.dart';
import 'package:eventorize_app/features/auth/view/payment_state_page.dart';

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
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        name: 'checkout',
        path: '/checkout/:orderId',
        builder: (context, state) => CheckOutPage(
          orderId: state.pathParameters['orderId']!,
        ),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/event/:id',
        name: 'event_detail',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailPage(eventId: eventId);
        },
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/detail-profile',
        name: 'detail-profile',
        builder: (context, state) => const ProfileDetailPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        name: 'payment',
        path: '/payment/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final extra = state.extra as Map<String, dynamic>;
          return PaymentPage(
            orderId: orderId,
            qrCode: extra['qrCode'] ?? '',
            qrDataUrl: extra['qrDataUrl'] ?? '',
            orderCode: extra['orderCode']?.toString() ?? '',
          );
        },
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/payment-success',
        name: 'payment-success',
        builder: (context, state) => const PaymentSuccessfulPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/payment-failed',
        name: 'payment-failed',
        builder: (context, state) => const PaymentFailedPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/favorite',
        name: 'favorite',
        builder: (context, state) => const FavoritePage(),
        redirect: (context, state) => _authGuard(context),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );

  static String? _authGuard(BuildContext context) {
    final sessionManager = context.read<SessionManager>();
    if (sessionManager.user == null && !sessionManager.isCheckingSession) {
      return '/login';
    }
    return null;
  }
}