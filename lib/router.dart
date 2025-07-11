import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/features/auth/user_view/login_page.dart';
import 'package:eventorize_app/features/auth/user_view/home_page.dart';
import 'package:eventorize_app/features/auth/user_view/checkout_page.dart';
import 'package:eventorize_app/features/auth/user_view/register_page.dart';
import 'package:eventorize_app/features/auth/user_view/splashscreen_page.dart';
import 'package:eventorize_app/features/auth/user_view/verify_page.dart';
import 'package:eventorize_app/features/auth/user_view/account_page.dart';
import 'package:eventorize_app/features/auth/user_view/profile_detail_page.dart';
import 'package:eventorize_app/features/auth/user_view/favorite_page.dart';
import 'package:eventorize_app/features/auth/user_view/event_detail_page.dart';
import 'package:eventorize_app/features/auth/user_view/payment_page.dart';
import 'package:eventorize_app/features/auth/user_view/payment_state_page.dart';
import 'package:eventorize_app/features/auth/user_view/ticket_page.dart';
import 'package:eventorize_app/features/auth/user_view/ticket_detail_page.dart';
import 'package:eventorize_app/features/auth/user_view/privacy_policy_page.dart';
import 'package:eventorize_app/features/auth/user_view/terms_of_service_page.dart';
import 'package:eventorize_app/features/auth/organization_view/select_org_page.dart';
import 'package:eventorize_app/features/auth/organization_view/org_info_page.dart';
import 'package:eventorize_app/features/auth/organization_view/ticket_list_page.dart';
import 'package:eventorize_app/features/auth/organization_view/event_list_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splashscreen',
    routes: [
      GoRoute(
        path: '/splashscreen',
        name: 'splashScreen',
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
        name: 'verifyCode',
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
        name: 'eventDetail',
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
        path: '/profile-detail',
        name: 'profileDetail',
        builder: (context, state) => const ProfileDetailPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/payment/:orderId',
        name: 'payment',
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
        name: 'paymentSuccess',
        builder: (context, state) => const PaymentSuccessfulPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/payment-failed',
        name: 'paymentFailed',
        builder: (context, state) => const PaymentFailedPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/favorite',
        name: 'favorite',
        builder: (context, state) => const FavoritePage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/ticket',
        name: 'ticket',
        builder: (context, state) => const TicketPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/ticket/:orderId',
        name: 'ticketDetail',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return TicketDetailPage(orderId: orderId);
        },
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'termsOfService',
        builder: (context, state) => const TOSPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/select-org',
        name: 'selectOrg',
        builder: (context, state) => const SelectOrgPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/org-info',
        name: 'orgInfo',
        builder: (context, state) => const OrgInfoPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/event-list',
        name: 'eventList',
        builder: (context, state) => const EventListPage(),
        redirect: (context, state) => _authGuard(context),
      ),
      GoRoute(
        path: '/ticket-list',
        name: 'ticketList',
        builder: (context, state) => const TicketListPage(),
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