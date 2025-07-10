import 'package:eventorize_app/features/auth/user_view/privacy_policy.dart';
import 'package:eventorize_app/features/auth/user_view/terms_of_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/features/auth/user_view/login_page.dart';
import 'package:eventorize_app/features/auth/user_view/home_page.dart';
import 'package:eventorize_app/features/auth/user_view/register_page.dart';
import 'package:eventorize_app/features/auth/user_view/splashscreen_page.dart';
import 'package:eventorize_app/features/auth/user_view/verify_page.dart';
import 'package:eventorize_app/features/auth/user_view/account_page.dart';
import 'package:eventorize_app/features/auth/user_view/event_detail_page.dart';
import 'package:eventorize_app/features/auth/user_view/profile_detail_page.dart';
import 'package:eventorize_app/features/auth/user_view/favorite_page.dart';
import 'package:eventorize_app/features/auth/user_view/checkout_page.dart';
import 'package:eventorize_app/features/auth/user_view/payment_page.dart';
import 'package:eventorize_app/features/auth/user_view/paymentstate_page.dart';
import 'package:eventorize_app/features/auth/user_view/tickets_page.dart';
import 'package:eventorize_app/features/auth/user_view/tickets_detail_page.dart';
import 'package:eventorize_app/features/auth/organization_view/create_org_page.dart';
import 'package:eventorize_app/features/auth/organization_view/event_list_page.dart';
import 'package:eventorize_app/features/auth/organization_view/ticket_list_page.dart';
import 'package:eventorize_app/features/auth/organization_view/order_list_page.dart';
import 'package:eventorize_app/features/auth/organization_view/create_event_page.dart';
import 'package:eventorize_app/features/auth/organization_view/create_ticket_page.dart';
import 'package:eventorize_app/features/auth/organization_view/edit_event_page.dart';
import 'package:eventorize_app/features/auth/organization_view/edit_ticket_page.dart';
import 'package:eventorize_app/features/auth/organization_view/org_info_page.dart';
import 'package:eventorize_app/features/auth/organization_view/select_org_page.dart';

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
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckOutPage(),
      ),
      GoRoute(
        path: '/orginfo',
        name: 'orginfo',
        builder: (context, state) => const OrgInfoPage(),
      ),
      GoRoute(
        path: '/selectorg',
        name: 'selectorg',
        builder: (context, state) => const SelectOrgPage(),
      ),
      GoRoute(
        path: '/eventlist/:organizerId',
        name: 'eventlist',
        builder: (context, state) {
          final organizerId = state.pathParameters['organizerId']!;
          return EventListPage(organizerId: organizerId);
        },
      ),
      GoRoute(
        path: '/orderlist',
        name: 'orderlist',
        builder: (context, state) => const OrderListPage(),
      ),
      GoRoute(
        path: '/createticket',
        name: 'createticket',
        builder: (context, state) => const CreateTicketPage(),
      ),
      GoRoute(
        path: '/editticket',
        name: 'editticket',
        builder: (context, state) => const EditTicketPage(),
      ),
      GoRoute(
        path: '/editevent',
        name: 'editevent',
        builder: (context, state) => const EditEventPage(),
      ),
      GoRoute(
        path: '/ticketlist',
        name: 'ticketlist',
        builder: (context, state) => const TicketListPage(),
      ),
      GoRoute(
        path: '/createorg',
        name: 'createorg',
        builder: (context, state) => const CreateOrgPage(),
      ),
      GoRoute(
        path: '/createevent/:organizerId',
        name: 'createevent',
        builder: (context, state) {
          final organizerId = state.pathParameters['organizerId']!;
          return CreateEventPage(organizerId: organizerId);
        },
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
      GoRoute(
        path: '/event/:id',
        name: 'event_detail',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailPage(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/detail-profile',
        name: 'detail-profile',
        builder: (context, state) => const ProfileDetailPage(),
      ),
      GoRoute(
        path: '/tos',
        name: 'tos',
        builder: (context, state) => const TOSPage(),
      ),
      GoRoute(
        path: '/privacypol',
        name: 'privacypol',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}