import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
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
  static const maxContentWidth = 600.0;

  final ScrollController _scrollController = ScrollController();
  bool _showDivider = false;

  @override
  void initState() {
    super.initState();
    _showDivider = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TopNavBar(title: "Payment", showBackButton: true),
            ),

            if (_showDivider)
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  color: AppColors.grey.withAlpha((0.5 * 255).toInt()),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withAlpha((0.6 * 255).toInt()),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: buildMainContainer(isSmallScreen, screenSize),
              ),
            ),
          ],
        ),
      ),
    );
  } 

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 20 : 40,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSuccessMsg(),
              buildHomeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSuccessMsg() {
    return Container(
      margin: const EdgeInsets.only(top: 150),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/success.svg',
            width: 110,
            height: 110,
          ),
          Text(
            'Payment successful!',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for paying!',
            textAlign: TextAlign.center,
            style: AppTextStyles.text.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget buildHomeButton() {
    return Container(
      margin: const EdgeInsets.only(top: 170),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // todo
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            'Back to home',
            style: AppTextStyles.bold.copyWith(fontSize: 16,color: Colors.white),
          ),
        )
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
  static const maxContentWidth = 600.0;

  final ScrollController _scrollController = ScrollController();
  bool _showDivider = false;

  @override
  void initState() {
    super.initState();
    _showDivider = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TopNavBar(title: "Payment", showBackButton: true),
            ),

            if (_showDivider)
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  color: AppColors.grey.withAlpha((0.5 * 255).toInt()),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withAlpha((0.6 * 255).toInt()),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: buildMainContainer(isSmallScreen, screenSize),
              ),
            ),
          ],
        ),
      ),
    );
  } 

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 20 : 40,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFailMsg(),
              buildHomeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFailMsg() {
    return Container(
      margin: const EdgeInsets.only(top: 150),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/fail.png',
            width: 110,
            height: 110,
          ),
          Text(
            'Payment failed!',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 8),
          Text(
            'Try making the payment again!',
            textAlign: TextAlign.center,
            style: AppTextStyles.text.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget buildHomeButton() {
    return Container(
      margin: const EdgeInsets.only(top: 170),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
           // todo
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            'Back to home',
            style: AppTextStyles.bold.copyWith(fontSize: 16,color: Colors.white),
          ),
        )
      ),
    );
  }
}

