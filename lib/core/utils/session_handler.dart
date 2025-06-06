import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';

class SessionHandler extends StatelessWidget {
  final Widget child;
  final bool requiresAuth;

  const SessionHandler({
    super.key,
    required this.child,
    this.requiresAuth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, sessionManager, _) {
        if (sessionManager.errorMessage != null && sessionManager.errorTitle != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ToastCustom.show(
              context: context,
              title: sessionManager.errorTitle!,
              description: sessionManager.errorMessage!,
              type: ToastificationType.error,
            );
            sessionManager.clearError();
          });
        }

        if (sessionManager.isCheckingSession) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (requiresAuth && sessionManager.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goNamed('login');
          });
          return const SizedBox.shrink();
        }

        return child;
      },
    );
  }
}