import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/custom_field_input.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/data/api/google_signin_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final emailInputKey = GlobalKey<CustomFieldInputState>();
  final passwordInputKey = GlobalKey<CustomFieldInputState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(LoginViewModel viewModel) async {
    final isValid = (emailInputKey.currentState?.validate() ?? false) &&
        (passwordInputKey.currentState?.validate() ?? false);
    if (!isValid) return;

    await viewModel.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (mounted && viewModel.user != null) {
      context.read<HomeViewModel>().setUser(viewModel.user!);
      ToastCustom.show(
        context: context,
        title: 'Login successful!',
        description: 'Welcome, ${viewModel.user!.fullname}!',
        type: ToastificationType.success,
      );
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.width <= 640;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, _) {
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
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 13, top: 40),
                                child: Text(
                                  'eventorize',
                                  style: AppTextStyles.logo.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Text(
                                  'Log in',
                                  style: AppTextStyles.title,
                                ),
                              ),
                              const SizedBox(height: 36),
                              CustomFieldInput(
                                key: emailInputKey,
                                controller: emailController,
                                hintText: 'Email',
                                icon: MdiIcons.emailOutline,
                                inputType: InputType.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 21),
                              CustomFieldInput(
                                key: passwordInputKey,
                                controller: passwordController,
                                hintText: 'Password',
                                icon: MdiIcons.lock,
                                isPassword: true,
                                inputType: InputType.password,
                              ),
                              const SizedBox(height: 21),
                              Padding(
                                padding: EdgeInsets.only(top: screenSize.height * 0.05),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 90),
                                      child: SizedBox(
                                        width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: viewModel.isLoading ? null : () => handleLogin(viewModel),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            'Log in',
                                            style: AppTextStyles.text.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
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
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
                                      height: 50,
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
                                                      type: ToastificationType.info,
                                                    );
                                                  }
                                                  return;
                                                }

                                                if (mounted) {
                                                  await viewModel.googleSSOAndroid(
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
                                                  } else if (viewModel.user != null && mounted) {
                                                    context.read<HomeViewModel>().setUser(viewModel.user!);
                                                    ToastCustom.show(
                                                      context: context,
                                                      title: 'Login successful!',
                                                      description: 'Welcome, ${viewModel.user!.fullname}!',
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
                                    ),
                                    const SizedBox(height: 29),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () => context.goNamed('register'),
                                        child: Text(
                                          "Don't have an account? Register now!",
                                          style: AppTextStyles.link,
                                        ),
                                      ),
                                    ),
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
                        size: 50,
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
}