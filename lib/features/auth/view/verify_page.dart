import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/features/auth/widgets/otp_field_input.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
import 'package:eventorize_app/features/auth/view_model/verify_view_model.dart';

class VerificationCodePage extends StatefulWidget {
  final String email;

  const VerificationCodePage({
    super.key,
    required this.email,
  });

  @override
  VerificationCodePageState createState() => VerificationCodePageState();
}

class VerificationCodePageState extends State<VerificationCodePage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;
  static const countdownDuration = Duration(minutes: 3);

  final List<TextEditingController> codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<GlobalKey<State<OTPFieldInput>>> codeInputKeys =
      List.generate(6, (_) => GlobalKey<State<OTPFieldInput>>());
  Timer? _timer;
  Duration _remainingTime = countdownDuration;
  bool isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    for (var controller in codeControllers) {
      controller.addListener(_updateSubmitButtonState);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in codeControllers) {
      controller.removeListener(_updateSubmitButtonState);
      controller.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _remainingTime = countdownDuration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _updateSubmitButtonState() {
    setState(() {
      isSubmitEnabled = codeControllers.every((controller) => controller.text.length == 1);
    });
  }

  Future<void> handleVerify(VerifyViewModel viewModel) async {
    if (!isSubmitEnabled) return;

    final otp = codeControllers.map((c) => c.text).join();
    await viewModel.verifyEmail(email: widget.email, otp: otp);
    if (mounted && viewModel.isSuccess) {
      ToastCustom.show(
        context: context,
        title: 'Verification successful!',
        description: 'Please log in.',
        type: ToastificationType.success,
      );
      context.goNamed('login');
    }
  }

  Future<void> handleResendCode(VerifyViewModel viewModel) async {
    if (_remainingTime.inSeconds > 0) return;

    await viewModel.resendVerificationEmail(email: widget.email);
    if (mounted && viewModel.isSuccess) {
      ToastCustom.show(
        context: context,
        title: 'Verification code resent!',
        description: 'Check your email for the new code.',
        type: ToastificationType.info,
      );
      for (var controller in codeControllers) {
        controller.clear();
      }
      _startCountdown();
      _updateSubmitButtonState();
    }
  }

  void handlePaste(String value, VerifyViewModel viewModel) {
    if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
      for (int i = 0; i < 6; i++) {
        codeControllers[i].text = value[i];
      }
      FocusScope.of(context).unfocus();
      _updateSubmitButtonState();
      handleVerify(viewModel);
    }
  }

  String get countdownText {
    final minutes = (_remainingTime.inSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    return 'Resend code after $minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      body: SafeArea(
        child: Consumer<VerifyViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.errorMessage != null && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ToastCustom.show(
                    context: context,
                    title: viewModel.errorTitle ?? 'Error',
                    description: viewModel.errorMessage!,
                    type: ToastificationType.error,
                  );
                  viewModel.clearError();
                }
              });
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  child: buildMainContainer(isSmallScreen, screenSize, viewModel),
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withAlpha(128),
                    child: const Center(
                      child: SpinKitFadingCircle(
                        color: AppColors.primary,
                        size: 50.0,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, VerifyViewModel viewModel) {
    return Container(
      width: screenSize.width,
      color: AppColors.defaultBackground,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLogo(),
              const SizedBox(height: 8),
              buildTitle(),
              const SizedBox(height: 8),
              buildWarningText(),
              const SizedBox(height: 24),
              buildImage(),
              const SizedBox(height: 24),
              buildOTPInput(viewModel),
              const SizedBox(height: 16),
              buildResendCodeButton(viewModel),
              const SizedBox(height: 16),
              buildSubmitButton(isSmallScreen, screenSize, viewModel),
              const SizedBox(height: 16),
            ],
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
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Text(
        'Verification Code',
        style: AppTextStyles.title,
      ),
    );
  }

  Widget buildWarningText() {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Text(
        'Enter code sent to ${widget.email}',
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
        'assets/images/verify.png',
        width: 353,
        height: 248,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildOTPInput(VerifyViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 48,
                height: 48,
                child: OTPFieldInput(
                  key: codeInputKeys[index],
                  controller: codeControllers[index],
                  index: index,
                  allControllers: codeControllers,
                  onChanged: (value) {
                    if (index == 0) {
                      handlePaste(value, viewModel);
                    }
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildResendCodeButton(VerifyViewModel viewModel) {
    return Center(
      child: TextButton(
        onPressed: _remainingTime.inSeconds == 0 && !viewModel.isLoading
            ? () => handleResendCode(viewModel)
            : null,
        child: Text(
          _remainingTime.inSeconds > 0 ? countdownText : 'Resend',
          style: AppTextStyles.link.copyWith(
            color: _remainingTime.inSeconds > 0 ? AppColors.grey : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton(bool isSmallScreen, Size screenSize, VerifyViewModel viewModel) {
    return Container(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: isSubmitEnabled && !viewModel.isLoading ? () => handleVerify(viewModel) : null,
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