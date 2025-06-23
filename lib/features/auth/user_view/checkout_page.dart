import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  CheckOutPageState createState() => CheckOutPageState();
}

class CheckOutPageState extends State<CheckOutPage>{
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final ScrollController _scrollController = ScrollController();
  bool _showDivider = false;

  int _selectedMethod = 0;

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
              child: TopNavBar(title: "Checkout", showBackButton: true),
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
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32, 
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBillingInfo(),
              const SizedBox(height: 24),
              buildOrderSummary(),
              const SizedBox(height: 24),
              buildPaymentMethods(),
              const SizedBox(height: 24),
              buildPriceSection(),
              const SizedBox(height: 24),
              buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBillingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing information', style: AppTextStyles.bold.copyWith(fontSize: 20)),
        const SizedBox(height: 12),
        buildLabeledInput('Fullname', 'Lâm Tuấn Thành'),
        buildLabeledInput('Email address', 'ltthanh1107@gmail.com'),
        buildLabeledInput('Phone number', '0901734198'),
      ],
    );
  }

  Widget buildLabeledInput(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.black),
              children: [
                if (label.contains("Fullname") || label.contains("Email"))
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: hint,
            readOnly: true,
            style: const TextStyle(
              color: Color(0xFF9B9B9B),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF9B9B9B  )),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }



  Widget buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order summary', style: AppTextStyles.bold.copyWith(fontSize: 20)),
        const SizedBox(height: 12),
        buildSummaryRow('2x Ticket price', '300.000 VND'),
        buildSummaryRow('Fees', '30.000 VND'),
        const Divider(height: 24, thickness: 1),
      
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.bold.copyWith(fontSize: 16)),
              Text('330.000 VND', style: AppTextStyles.bold.copyWith(fontSize: 16,)),
            ],
          ),
        )
      ],
    );
  }

  Widget buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.medium.copyWith(fontSize: 13)),
          Text(value, style: AppTextStyles.medium.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment method', style: AppTextStyles.bold.copyWith(fontSize: 20)),
        const SizedBox(height: 12),
        buildPaymentOption(0, 'Credit/Debit card', 'assets/icons/credit_logo.png'),
        const SizedBox(height: 8),
        buildPaymentOption(1, 'Paypal', 'assets/icons/paypal_logo.png'),
      ],
    );
  }

  Widget buildPaymentOption(int index, String label, String assetPath) {
    return InkWell(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Image.asset(
              assetPath,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.text),
            ),
            Radio<int>(
              value: index,
              groupValue: _selectedMethod,
              activeColor: Colors.blue,
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Price',
              style: AppTextStyles.bold.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text('330.000 VND', style: AppTextStyles.medium.copyWith(fontSize: 13),),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFEC0303),
            padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            // Handle place order
          },
          child: Text(
            'Place order',style: AppTextStyles.bold.copyWith(fontSize: 16,color: Colors.white)
          )
        ),
      ],
    );
  }

  Widget buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 1),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: 'Powered by ',
            style: AppTextStyles.text.copyWith(fontSize: 13),
            children: [
              TextSpan(
                text: 'eventorize',
                style: AppTextStyles.bold.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
