import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/data/api/shared_preferences_service.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              final user = viewModel.user;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user != null
                        ? 'Welcome, ${user.fullname}!'
                        : 'Welcome to Eventorize!',
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user != null ? 'Email: ${user.email}' : 'Guest User',
                    style: AppTextStyles.text,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: screenSize.width * 0.8,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Xóa token và chuyển hướng về LoginPage
                        await SharedPreferencesService.clear();
                        viewModel.clearError(); // Xóa trạng thái lỗi nếu có
                        Navigator.pushReplacementNamed(context, '/login');
                      },
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