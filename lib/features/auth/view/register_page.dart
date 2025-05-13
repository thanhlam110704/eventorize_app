import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/custom_field_input.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
import 'package:eventorize_app/features/auth/view_model/register_view_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;

  final emailController = TextEditingController();
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final emailInputKey = GlobalKey<CustomFieldInputState>();
  final fullnameInputKey = GlobalKey<CustomFieldInputState>();
  final phoneInputKey = GlobalKey<CustomFieldInputState>();
  final passwordInputKey = GlobalKey<CustomFieldInputState>();

  @override
  void dispose() {
    emailController.dispose();
    fullnameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleRegister(RegisterViewModel viewModel) async {
    bool isValid = true;
    if (emailInputKey.currentState != null) {
      isValid &= emailInputKey.currentState!.validate();
    }
    if (fullnameInputKey.currentState != null) {
      isValid &= fullnameInputKey.currentState!.validate();
    }
    if (phoneInputKey.currentState != null) {
      isValid &= phoneInputKey.currentState!.validate();
    }
    if (passwordInputKey.currentState != null) {
      isValid &= passwordInputKey.currentState!.validate();
    }

    if (isValid) {
      await viewModel.register(
        fullname: fullnameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted && viewModel.user != null) {
        ToastCustom.show(
          context: context,
          title: 'Registration successful!',
          type: ToastificationType.success,
        );
        context.goNamed(
          'verify-code',
          extra: {
            'email': emailController.text.trim(),
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<RegisterViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.errorMessage != null && viewModel.errorTitle != null && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ToastCustom.show(
                    context: context,
                    title: viewModel.errorTitle!,
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
                  child: Container(
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
                              const SizedBox(height: 3),
                              buildTitle(),
                              const SizedBox(height: 36),
                              buildEmailField(),
                              const SizedBox(height: 21),
                              buildFullnameField(),
                              const SizedBox(height: 21),
                              buildPhoneField(),
                              const SizedBox(height: 21),
                              buildPasswordField(),
                              const SizedBox(height: 21),
                              Padding(
                                padding: EdgeInsets.only(top: screenSize.height * 0.05),
                                child: Column(
                                  children: [
                                    buildRegisterButton(isSmallScreen, screenSize, viewModel),
                                    const SizedBox(height: 10),
                                    buildDivider(),
                                    const SizedBox(height: 10),
                                    buildGoogleButton(isSmallScreen, screenSize),
                                    const SizedBox(height: 29),
                                    buildLoginLink(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
        'Create an account',
        style: AppTextStyles.title,
      ),
    );
  }

  Widget buildEmailField() {
    return CustomFieldInput(
      key: emailInputKey,
      controller: emailController,
      hintText: 'Email',
      icon: MdiIcons.emailOutline,
      inputType: InputType.email,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget buildFullnameField() {
    return CustomFieldInput(
      key: fullnameInputKey,
      controller: fullnameController,
      hintText: 'Fullname',
      icon: MdiIcons.accountOutline,
      inputType: InputType.fullname,
    );
  }

  Widget buildPhoneField() {
    return CustomFieldInput(
      key: phoneInputKey,
      controller: phoneController,
      hintText: 'Phone',
      icon: MdiIcons.phone,
      inputType: InputType.phone,
    );
  }

  Widget buildPasswordField() {
    return CustomFieldInput(
      key: passwordInputKey,
      controller: passwordController,
      hintText: 'Password',
      icon: MdiIcons.lock,
      isPassword: true,
      inputType: InputType.password,
    );
  }

  Widget buildRegisterButton(bool isSmallScreen, Size screenSize, RegisterViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Container(
        width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
        height: buttonHeight,
        margin: const EdgeInsets.only(top: 10),
        child: ElevatedButton(
          onPressed: viewModel.isLoading ? null : () => handleRegister(viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            'Register',
            style: AppTextStyles.text.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey)),
        const SizedBox(width: 10),
        Text(
          'or',
          style: AppTextStyles.text.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: AppColors.grey)),
      ],
    );
  }

  Widget buildGoogleButton(bool isSmallScreen, Size screenSize) {
    return SizedBox(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          ToastCustom.show(
            context: context,
            title: 'Processing registration with Google...',
            type: ToastificationType.info,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/logo_google.png',
              width: screenSize.width * 0.06,
              height: screenSize.width * 0.06,
            ),
            const SizedBox(width: 11),
            Text(
              'Continue with Google',
              style: AppTextStyles.text.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          context.goNamed('login');
        },
        child: Text(
          'Login if you have an account!',
          style: AppTextStyles.link,
        ),
      ),
    );
  }
}