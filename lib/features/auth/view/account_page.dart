import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/components/bottom_nav_bar.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/data/models/user.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.grey,
          ),
          const BottomNavBar(backgroundColor: AppColors.defaultBackground),
        ],
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.defaultBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 20 : 40,
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

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: sessionManager.isCheckingSession || sessionManager.isLoading
                    ? buildSkeletonUI(isSmallScreen, screenSize)
                    : buildContent(sessionManager.user, context, sessionManager),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildContent(User? user, BuildContext context, SessionManager sessionManager) {
    if (user == null) {
      return const SizedBox.shrink();
    }
    _animationController.forward();
    return FadeTransition(
      key: const ValueKey('content'),
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(),
          const SizedBox(height: 15),
          buildUserCard(user),
          const SizedBox(height: 25),
          buildSetting(context, sessionManager),
        ],
      ),
    );
  }

  Widget buildSkeletonUI(bool isSmallScreen, Size screenSize) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      period: const Duration(milliseconds: 1500), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 150,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.skeleton,
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
                        decoration: BoxDecoration(
                          color: AppColors.skeleton,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 16,
                        width: 200,
                        decoration: BoxDecoration(
                          color: AppColors.skeleton,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 36,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.skeleton,
                          borderRadius: BorderRadius.circular(8), 
                        ),
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
                decoration: BoxDecoration(
                  color: AppColors.skeleton,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              buildSkeletonSettingItem(),
              buildDivider(),
              const SizedBox(height: 20),
              buildSkeletonSettingItem(),
              buildDivider(),
              const SizedBox(height: 20),
              buildSkeletonSettingItem(),
              buildDivider(),
              const SizedBox(height: 125),
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.skeleton,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.skeleton,
                    borderRadius: BorderRadius.circular(4),
                  ),
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
          decoration: BoxDecoration(
            color: AppColors.skeleton,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: AppColors.skeleton,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Text(
      'Tài khoản',
      style: AppTextStyles.title,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(51, 51, 51, 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              baseColor: AppColors.shimmerBase,
              highlightColor: AppColors.shimmerHighlight,
              child: Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.skeleton,
                ),
              ),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.shimmerBase,
              child: Text(
                initials,
                style: AppTextStyles.avatarInitials,
              ),
            ),
            memCacheHeight: 136, 
            memCacheWidth: 136,
            fadeInDuration: const Duration(milliseconds: 200), 
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
                      side: const BorderSide(color: AppColors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Thông tin chi tiết',
                      style: AppTextStyles.text.copyWith(fontWeight: FontWeight.w700),
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
          'Cài đặt',
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 15),
        buildSettingItem(
          icon: Icons.account_circle,
          title: 'Liên kết tài khoản',
          onTap: () {},
          iconColor: AppColors.black,
          textColor: AppColors.black,
          showTrailing: true,
        ),
        buildDivider(),
        const SizedBox(height: 15),
        buildSettingItem(
          icon: Icons.apartment_outlined,
          title: 'Nhà tổ chức',
          onTap: () {},
          iconColor: AppColors.black,
          textColor: AppColors.black,
          showTrailing: true,
        ),
        buildDivider(),
        const SizedBox(height: 15),
        buildSettingItem(
          icon: MdiIcons.fileDocumentOutline,
          title: 'Điều khoản dịch vụ',
          onTap: () {},
          iconColor: AppColors.black,
          textColor: AppColors.black,
          showTrailing: true,
        ),
        buildDivider(),
        const SizedBox(height: 15),
        buildSettingItem(
          icon: MdiIcons.lockOutline,
          title: 'Chính sách bảo mật',
          onTap: () {},
          iconColor: AppColors.black,
          textColor: AppColors.black,
          showTrailing: true,
        ),
        buildDivider(),
        const SizedBox(height: 80),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              await sessionManager.logout();
              if (context.mounted) {
                ToastCustom.show(
                  context: context,
                  title: 'Đăng xuất thành công!',
                  type: ToastificationType.success,
                );
                context.pushReplacementNamed('login');
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red),
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
                  color: AppColors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Đăng xuất',
                  style: AppTextStyles.text.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Phiên bản 1.0.0',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.mutedText),
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
          ? const Icon(Icons.chevron_right, size: 24, color: AppColors.darkGrey)
          : null,
      onTap: onTap,
    );
  }

  Widget buildDivider() {
    return Divider(
      thickness: 0.5,
      height: 1,
      color: AppColors.grey,
    );
  }
}