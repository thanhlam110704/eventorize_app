import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/network/dio_client.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  SplashScreenPageState createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      context.goNamed('login'); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return MultiProvider(
      providers: [
        Provider<UserRepository>(
          create: (_) => UserRepository(UserApi(DioClient())),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.primary, 
        body: SafeArea(
          child: SingleChildScrollView(
            child: buildMainContainer(isSmallScreen, screenSize),
          ),
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
    padding: const EdgeInsets.only(bottom: 50), // 👈 padding bottom 20px
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
