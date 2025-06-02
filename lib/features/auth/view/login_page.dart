import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/custom_field_input.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/data/api/google_signin_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final emailInputKey = GlobalKey<CustomFieldInputState>();
  final passwordInputKey = GlobalKey<CustomFieldInputState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(LoginViewModel viewModel) async {
    bool isValid = true;
    if (emailInputKey.currentState != null) {
      isValid &= emailInputKey.currentState!.validate();
    }
    if (passwordInputKey.currentState != null) {
      isValid &= passwordInputKey.currentState!.validate();
    }
    if (isValid) {
      try {
        final result = await viewModel.login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (mounted) {
          await context.read<SessionManager>().setUserFromToken(result['token']);
          ToastCustom.show(
            context: context,
            title: 'Login successful!',
            description: 'Welcome, ${result['user'].fullname}!',
            type: ToastificationType.success,
          );
          context.goNamed('home');
        }
      } catch (e) {
        // Lỗi đã được xử lý trong LoginViewModel
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      body: SafeArea(
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.errorMessage != null) {
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
                  child: Container(
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
                              buildPasswordField(),
                              const SizedBox(height: 21),
                              Padding(
                                padding: EdgeInsets.only(top: screenSize.height * 0.05),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 90),
                                      child: Container(
                                        width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
                                        height: buttonHeight,
                                        margin: const EdgeInsets.only(top: 10),
                                        child: ElevatedButton(
                                          onPressed: viewModel.isLoading ? null : () => handleLogin(viewModel),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'Log in',
                                            style: AppTextStyles.button,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    buildDivider(),
                                    const SizedBox(height: 10),
                                    buildGoogleButton(isSmallScreen, screenSize, viewModel),
                                    const SizedBox(height: 29),
                                    buildRegisterLink(),
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
        style: AppTextStyles.logo,
      ),
    );
  }

  Widget buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Text(
        'Log in',
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

  Widget buildGoogleButton(bool isSmallScreen, Size screenSize, LoginViewModel viewModel) {
    return SizedBox(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () async {
                final googleUser = await GoogleSignInApi.signIn();
                
                if (googleUser == null) {
                  if (mounted) {
                    ToastCustom.show(
                      context: context,
                      title: 'Sign-In Canceled',
                      description: 'Google Sign-In was canceled. Please try again.',
                      type: ToastificationType.error,
                    );
                  }
                  return;
                }

                if (mounted) {
                  final result = await viewModel.googleSSOAndroid(
                    googleId: googleUser['google_id']!,
                    displayName: googleUser['fullname']!,
                    email: googleUser['email']!,
                    picture: googleUser['avatar']!,
                  );
                  
                  if (viewModel.errorMessage != null && mounted) {
                    ToastCustom.show(
                      context: context,
                      title: viewModel.errorTitle ?? 'Error',
                      description: viewModel.errorMessage!,
                      type: ToastificationType.error,
                    );
                    viewModel.clearError();
                  } else if (mounted) {
                    await context.read<SessionManager>().setUserFromToken(result['token']);
                    ToastCustom.show(
                      context: context,
                      title: 'Login successful!',
                      description: 'Welcome, ${result['user'].fullname}!',
                      type: ToastificationType.success,
                    );
                    context.goNamed('home');
                  }
                }
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
              style: AppTextStyles.button.copyWith(
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          context.goNamed('register');
        },
        child: Text(
          'Don\'t have an account? Register now!',
          style: AppTextStyles.link,
        ),
      ),
    );
  }
}