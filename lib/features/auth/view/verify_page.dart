import 'package:eventorize_app/common/widgets/custom_field_input.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key});
  
  @override
  VerificationCodePageState createState() => VerificationCodePageState();
}
class VerificationCodePageState extends State<VerificationCodePage>{
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;

  final codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final codeInputKey = GlobalKey<CustomFieldInputState>();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void handleVerify() {
    bool isValid = true;
    if (codeInputKey.currentState != null) {
      isValid &= codeInputKey.currentState!.validate();
    }
    if (isValid) {
      // verify logic
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.background,
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
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLogo(),
                const SizedBox(height: 8), // space between logo and title
                buildTitle(),
                const SizedBox(height: 8), // space between title and red warning
                buildWarningText(),
                const SizedBox(height: 24), // space before image
                buildImage(),
                const SizedBox(height: 24), // space before pin input
                buildPinInput(),
                const SizedBox(height: 16), // space before resend code
                buildResendCodeButton(),
                const SizedBox(height: 16), // space before submit button
                buildSubmitButton(isSmallScreen, screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 40),
      child: Text(
        'eventorize',
        style: AppTextStyles.logo.copyWith(
          fontWeight: FontWeight.w900
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Text(
        'Verification code',
        style: AppTextStyles.title,
      ),
    );
  }

  Widget buildWarningText() {
  return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Text(
        'Check code on inbox in your email',
        style: AppTextStyles.text.copyWith(
          fontSize: 18,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildImage() {
    return Center(
      child: Image.asset(
        'assets/icons/verify.png', // replace with your image path
        width: 353,
        height: 248,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildPinInput() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            width: 48, 
            height: 48, 
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2), 
              borderRadius: BorderRadius.circular(8), 
            ),
            child: const Center(
              child: Text(
                '', 
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),  
          );
        }),
      ),
    );
  }


  Widget buildResendCodeButton() {
    return Center(
      child: TextButton(
        onPressed: () {
        // handle resend
        },
        child: Text(
          'Resend code',
          style: AppTextStyles.link.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton(bool isSmallScreen, Size screenSize) {
    return Container(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: () {
        // handle submit
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Submit',
          style: AppTextStyles.text.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}