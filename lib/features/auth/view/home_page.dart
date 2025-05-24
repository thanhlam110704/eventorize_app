import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
import 'package:toastification/toastification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<SessionManager>().checkSession();
      }
    });
  }

  Future<void> _handleLogout(BuildContext context, SessionManager sessionManager) async {
    await sessionManager.logout();
    if (context.mounted) {
      ToastCustom.show(
        context: context,
        title: 'Logged out successfully!',
        type: ToastificationType.success,
      );
      context.pushReplacementNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Eventorize Home',
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Consumer<SessionManager>(
            builder: (context, sessionManager, child) {
              if (sessionManager.errorMessage != null && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ToastCustom.show(
                      context: context,
                      title: sessionManager.errorTitle ?? 'Error',
                      description: sessionManager.errorMessage!,
                      type: ToastificationType.error,
                    );
                    sessionManager.clearError();
                    if (!sessionManager.isLoading && sessionManager.user == null) {
                      context.pushReplacementNamed('login');
                    }
                  }
                });
              }
              if (sessionManager.isCheckingSession || sessionManager.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (sessionManager.user == null) {
                return const SizedBox.shrink();
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${sessionManager.user!.fullname}!',
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email: ${sessionManager.user!.email}',
                    style: AppTextStyles.text,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: screenSize.width * 0.8,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: sessionManager.isLoading ? null : () => _handleLogout(context, sessionManager),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Log Out',
                        style: AppTextStyles.text.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}