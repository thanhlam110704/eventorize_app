import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentSuccessfulPage extends StatefulWidget {
  const PaymentSuccessfulPage({super.key});

  @override
  State<PaymentSuccessfulPage> createState() => _PaymentSuccessfulPageState();
}

class _PaymentSuccessfulPageState extends State<PaymentSuccessfulPage> {
  static const smallScreenThreshold = 640.0;
  static const buttonHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;
    final isShortScreen = screenSize.height < 600;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isSmallScreen ? 16 : 24,
              isShortScreen ? 24 : isSmallScreen ? 40 : 80,
              isSmallScreen ? 16 : 24,
              0,
            ),
            child: const TopNavBar(title: "Thanh toán", showBackButton: true),
          ),
          Expanded(
            child: buildMainContainer(isSmallScreen, isShortScreen, screenSize),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isSmallScreen ? 16 : 24,
              right: isSmallScreen ? 16 : 24,
              bottom: isSmallScreen ? 24 : 32,
              top: screenSize.height * 0.05,
            ),
            child: buildHomeButton(isSmallScreen, screenSize),
          ),
        ],
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, bool isShortScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      height: screenSize.height - (isShortScreen ? 48 : isSmallScreen ? 80 : 160),
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 70 : 90, 
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildSuccessMsg(),
        ],
      ),
    );
  }

  Widget buildSuccessMsg() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/images/success.svg',
              width: 110,
              height: 110,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Thanh toán thành công!',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Cảm ơn vì đã đặt vé!',
            textAlign: TextAlign.center,
            style: AppTextStyles.text.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget buildHomeButton(bool isSmallScreen, Size screenSize) {
    return SizedBox(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          context.go('/home');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(
          'Trở về trang chủ',
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}

class PaymentFailedPage extends StatefulWidget {
  const PaymentFailedPage({super.key});

  @override
  State<PaymentFailedPage> createState() => _PaymentFailedPageState();
}

class _PaymentFailedPageState extends State<PaymentFailedPage> {
  static const smallScreenThreshold = 640.0;
  static const buttonHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;
    final isShortScreen = screenSize.height < 600;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isSmallScreen ? 16 : 24,
              isShortScreen ? 24 : isSmallScreen ? 40 : 80,
              isSmallScreen ? 16 : 24,
              0,
            ),
            child: const TopNavBar(title: "Thanh toán", showBackButton: true),
          ),
          Expanded(
            child: buildMainContainer(isSmallScreen, isShortScreen, screenSize),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isSmallScreen ? 16 : 24,
              right: isSmallScreen ? 16 : 24,
              bottom: isSmallScreen ? 24 : 32,
              top: screenSize.height * 0.05,
            ),
            child: buildHomeButton(isSmallScreen, screenSize),
          ),
        ],
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, bool isShortScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      height: screenSize.height - (isShortScreen ? 48 : isSmallScreen ? 80 : 160),
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 70 : 90, 
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildFailMsg(),
        ],
      ),
    );
  }

  Widget buildFailMsg() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/fail.png',
              width: 110,
              height: 110,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Thanh toán thất bại!',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Hãy thử đặt vé lại!',
            textAlign: TextAlign.center,
            style: AppTextStyles.text.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget buildHomeButton(bool isSmallScreen, Size screenSize) {
    return SizedBox(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          context.go('/home');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(
          'Trở về trang chủ',
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}