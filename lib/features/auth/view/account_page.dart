import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/widgets/bottom_nav_bar.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/data/models/user.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<SessionManager>().checkSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: buildMainContainer(isSmallScreen, screenSize),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black12,
          ),
          const BottomNavBar(),
        ],
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
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
          child: Consumer<SessionManager>(
            builder: (context, sessionManager, child) {
              if (sessionManager.errorMessage != null && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ToastCustom.show(
                      context: context,
                      title: sessionManager.errorTitle ?? 'Error',
                      description: sessionManager.errorMessage!,
                      type: ToastificationType.error,
                    );
                    sessionManager.clearError();
                    if (!sessionManager.isLoading && sessionManager.user == null) {
                      context.pushReplacementNamed('login');
                    }
                  }
                });
              }
              if (sessionManager.isCheckingSession || sessionManager.isLoading) {
                return buildSkeletonUI(isSmallScreen, screenSize);
              }

              final user = sessionManager.user;
              if (user == null) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(),
                  const SizedBox(height: 15),
                  buildUserCard(user),
                  const SizedBox(height: 25),
                  buildSetting(context, sessionManager),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildSkeletonUI(bool isSmallScreen, Size screenSize) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 150,
            color: Colors.white,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 120,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 16,
                        width: 200,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 36,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              buildSkeletonSettingItem(),
              const Divider(
                thickness: 0.5,
                height: 1,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              buildSkeletonSettingItem(),
              const Divider(
                thickness: 0.5,
                height: 1,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              buildSkeletonSettingItem(),
              const Divider(
                thickness: 0.5,
                height: 1,
                color: Colors.white,
              ),
              const SizedBox(height: 125),
              Container(
                height: 48,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  height: 12,
                  width: 80,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSkeletonSettingItem() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          color: Colors.white,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 20,
            color: Colors.white,
          ),
        ),
        Container(
          width: 15,
          height: 15,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Text(
      'Account',
      style: AppTextStyles.title.copyWith(fontSize: 36, fontWeight: FontWeight.w700),
    );
  }

  Widget buildUserCard(User user) {
    final String initials = user.fullname.isNotEmpty
        ? user.fullname.split(' ').map((e) => e[0]).take(2).join()
        : 'N/A';
    final String name = user.fullname;
    final String email = user.email;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: user.avatar ?? '',
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 34,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 34,
              backgroundColor: Colors.grey[300],
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.text.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTextStyles.text,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.pushNamed("detail-profile");
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Detail profile',
                      style: AppTextStyles.text.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSetting(BuildContext context, SessionManager sessionManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: AppTextStyles.title.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        buildSettingItem(
          icon: Icons.location_on,
          title: 'Location',
          onTap: () {},
          iconColor: Colors.black,
          textColor: Colors.black,
          showTrailing: true,
        ),
        buildDivider(),
        const SizedBox(height: 20),
        buildSettingItem(
          icon: Icons.apartment_outlined,
          title: 'Organization',
          onTap: () {},
          iconColor: Colors.black,
          textColor: Colors.black,
          showTrailing: true,
        ),
        buildDivider(),
        const SizedBox(height: 20),
        buildSettingItem(
          icon: Icons.account_circle,
          title: 'Linked accounts',
          onTap: () {},
          iconColor: Colors.black,
          textColor: Colors.black,
          showTrailing: true,
        ),
        buildDivider(),
        const SizedBox(height: 125),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              await sessionManager.logout();
              if (context.mounted) {
                ToastCustom.show(
                  context: context,
                  title: 'Logged out successfully!',
                  type: ToastificationType.success,
                );
                context.pushReplacementNamed('login');
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Log out',
                  style: AppTextStyles.text.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Version 1.0.0',
            style: AppTextStyles.text.copyWith(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
    required Color textColor,
    required bool showTrailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: AppTextStyles.text.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: showTrailing
          ? const Icon(Icons.chevron_right, size: 15, color: AppColors.darkGrey)
          : null,
      onTap: onTap,
    );
  }

  Widget buildDivider() {
    return const Divider(
      thickness: 0.5,
      height: 1,
      color: Color(0xFF9B9B9B),
    );
  }
}