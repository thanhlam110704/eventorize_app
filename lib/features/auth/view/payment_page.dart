import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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
              buildQRCodeCard(),
              const SizedBox(height: 60),
              buildDownloadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQRCodeCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/qr_code.png',
            width: 300,
            height: 300,
          ),
          Text(
            'Scans to pay for an order',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 8),
          Text(
            'The QR code will expire after\n5:00',
            textAlign: TextAlign.center,
            style: AppTextStyles.text.copyWith(fontSize: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildDownloadButton() {
    return SizedBox(
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
          'Download QR code',
          style: AppTextStyles.bold.copyWith(fontSize: 16,color: Colors.white),
        ),
      ),
    );
  }
}
