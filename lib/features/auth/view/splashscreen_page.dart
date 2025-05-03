import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/data/api/secure_storage_service.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';
import 'package:get_it/get_it.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  SplashScreenPageState createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  final getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _checkSession(context);
  }

  Future<void> _checkSession(BuildContext context) async {
    final viewModel = context.read<LoginViewModel>();
    final token = await SecureStorageService.getToken();

    if (token != null) {
      try {
        await viewModel.checkSession();
        if (viewModel.user != null && context.mounted) {
          context.pushReplacementNamed('home');
          return;
        } 
      } catch (e) {
        if (e.toString().contains('401')) {
          await SecureStorageService.clearToken();
          await SecureStorageService.clearEmail();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session expired. Please log in again.')),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to connect. Please check your network.')),
            );
          }
        }
      }
    } 

    if (context.mounted) {
      context.pushReplacementNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: buildMainContainer(isSmallScreen, screenSize),
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildLogo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Text(
        'eventorize',
        style: AppTextStyles.logo.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}