import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/custom_field_input.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/data/api/shared_preferences_service.dart';
import 'package:eventorize_app/common/network/dio_client.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;

  bool rememberMe = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final emailInputKey = GlobalKey<CustomFieldInputState>();
  final passwordInputKey = GlobalKey<CustomFieldInputState>();

  @override
  void initState() {
    super.initState();
    // Điền trước email nếu đã lưu
    SharedPreferencesService.getEmail().then((email) {
      if (email != null) {
        setState(() {
          emailController.text = email;
          rememberMe = true;
        });
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin(BuildContext context) {
    bool isValid = true;
    if (emailInputKey.currentState != null) {
      isValid &= emailInputKey.currentState!.validate();
    }
    if (passwordInputKey.currentState != null) {
      isValid &= passwordInputKey.currentState!.validate();
    }
    if (isValid) {
      context.read<LoginViewModel>().login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            rememberMe: rememberMe,
          );
    }
  }

  void toggleRememberMe() {
    setState(() {
      rememberMe = !rememberMe;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return MultiProvider(
      providers: [
        Provider<UserRepository>(
          create: (_) => UserRepository(UserApi(DioClient())),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(context.read<UserRepository>()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Consumer<LoginViewModel>(
              builder: (context, viewModel, child) {
                // Xử lý trạng thái
                if (viewModel.isLoading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logging in...')),
                    );
                  });
                } else if (viewModel.errorMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(viewModel.errorMessage!)),
                    );
                    viewModel.clearError();
                  });
                } else if (viewModel.user != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Welcome, ${viewModel.user!.fullname}!')),
                    );
                    context.goNamed('home'); // Chuyển hướng bằng go_router
                  });
                }

                return buildMainContainer(isSmallScreen, screenSize);
              },
            ),
          ),
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
                const SizedBox(height: 3),
                buildTitle(),
                const SizedBox(height: 36),
                buildEmailField(),
                const SizedBox(height: 21),
                buildPasswordField(),
                const SizedBox(height: 21),
                buildRememberMe(isSmallScreen),
                if (isSmallScreen) const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(top: screenSize.height * 0.05),
                  child: Column(
                    children: [
                      buildLoginButton(isSmallScreen, screenSize),
                      const SizedBox(height: 10),
                      buildDivider(),
                      const SizedBox(height: 10),
                      buildGoogleButton(isSmallScreen, screenSize),
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

  Widget buildRememberMe(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: toggleRememberMe,
            child: Icon(
              rememberMe ? MdiIcons.checkboxMarked : MdiIcons.checkboxBlankOutline,
              color: rememberMe ? AppColors.primary : AppColors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'Remember me',
            style: AppTextStyles.text,
          ),
        ],
      ),
    );
  }

  Widget buildLoginButton(bool isSmallScreen, Size screenSize) {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Container(
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      height: buttonHeight,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: () => handleLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
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
          // Xử lý đăng nhập Google (triển khai sau)
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