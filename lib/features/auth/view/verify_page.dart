import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/custom_field_input.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/common/network/dio_client.dart';

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
  final List<GlobalKey<CustomFieldInputState>> codeInputKeys =
      List.generate(6, (_) => GlobalKey<CustomFieldInputState>());
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool navigated = false;
  Timer? _timer;
  Duration _remainingTime = countdownDuration;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in codeControllers) {
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

  Future<void> handleVerify() async {
    bool isValid = true;
    for (var key in codeInputKeys) {
      if (key.currentState != null) {
        isValid &= key.currentState!.validate();
      }
    }
    if (!isValid || !formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final otp = codeControllers.map((c) => c.text).join();
    try {
      final userApi = UserApi(DioClient());
      await userApi.verifyEmail(
        email: widget.email,
        otp: otp,
      );
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.minimal,
          title: const Text('Verification successful! Please log in.'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
        navigated = true;
        context.goNamed('login');
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.minimal,
          title: Text('Verification failed: ${e.toString()}'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleResendCode() async {
    if (_remainingTime.inSeconds > 0) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userApi = UserApi(DioClient());
      await userApi.resendVerificationEmail(email: widget.email);
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.minimal,
          title: const Text('Verification code has been resent!'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.minimal,
          title: Text('Failed to resend code: ${e.toString()}'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topCenter,
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: buildMainContainer(isSmallScreen, screenSize),
            ),
            if (isLoading)
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
                const SizedBox(height: 8),
                buildTitle(),
                const SizedBox(height: 8),
                buildWarningText(),
                const SizedBox(height: 24),
                buildImage(),
                const SizedBox(height: 24),
                buildPinInput(),
                const SizedBox(height: 16),
                buildResendCodeButton(),
                const SizedBox(height: 16),
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
        'assets/icons/verify.png',
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
          return SizedBox(
            width: 48,
            height: 48,
            child: CustomFieldInput(
              key: codeInputKeys[index],
              controller: codeControllers[index],
              hintText: '',
              inputType: InputType.number,
              keyboardType: TextInputType.number,
              maxLength: 1,
              textAlign: TextAlign.center,
              onChanged: (value) {
                if (value.length == 1 && index < 5) {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget buildResendCodeButton() {
    return Center(
      child: TextButton(
        onPressed: _remainingTime.inSeconds == 0 && !isLoading ? handleResendCode : null,
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

  Widget buildSubmitButton(bool isSmallScreen, Size screenSize) {
    return Container(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: isLoading ? null : handleVerify,
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