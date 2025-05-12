import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
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
        context.read<HomeViewModel>().checkSession();
      }
    });
  }

  Future<void> _handleLogout(BuildContext context, HomeViewModel viewModel) async {
    await viewModel.logout();
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
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.errorMessage != null && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ToastCustom.show(
                      context: context,
                      title: 'Error',
                      description: viewModel.errorMessage!,
                      type: ToastificationType.error,
                    );
                    viewModel.clearError();
                    if (!viewModel.isLoggingOut && viewModel.user == null) {
                      context.pushReplacementNamed('login');
                    }
                  }
                });
              }
              if (viewModel.isCheckingSession || viewModel.isLoading || viewModel.isLoggingOut) {
                return const Center(child: CircularProgressIndicator());
              }
              if (viewModel.user == null) {
                return const SizedBox.shrink(); // Không chuyển hướng ở đây
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${viewModel.user!.fullname}!',
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email: ${viewModel.user!.email}',
                    style: AppTextStyles.text,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: screenSize.width * 0.8,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : () => _handleLogout(context, viewModel),
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