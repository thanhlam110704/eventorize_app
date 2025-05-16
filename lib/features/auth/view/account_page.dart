import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/bottom_nav_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 20),
              buildUserCard(),
              const SizedBox(height: 30),
              buildPreferences(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text(
      'Account',
      style: AppTextStyles.title.copyWith(fontSize: 28),
    );
  }

  Widget buildUserCard() {
    final String initials = 'LT';
    final String name = 'Lâm Tuấn Thành';
    final String email = 'ltthanh@1107@gmail.com';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.black,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.text),
                const SizedBox(height: 4),
                Text(email, style: AppTextStyles.text),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.goNamed("detail-info");
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black), // black border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Detail profile',
                      style: AppTextStyles.text.copyWith(
                        fontWeight: FontWeight.w600, // bold text
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
  Widget buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: AppTextStyles.title.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 20),
        buildPreferenceItem(
          icon: Icons.location_on_outlined,
          title: 'Location',
          onTap: () {},
        ),
        buildDivider(),
        buildPreferenceItem(
          icon: Icons.apartment_outlined,
          title: 'Organization',
          onTap: () {},
        ),
        buildDivider(),
        buildPreferenceItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {},
        ),
        buildDivider(),
        buildPreferenceItem(
          icon: Icons.logout,
          title: 'Log out',
          onTap: () {},
        ),
        buildDivider(),
      ],
    );
  }

  Widget buildPreferenceItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: AppTextStyles.text.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget buildDivider() {
    return const Divider(
      thickness: 1,
      height: 1,
      color: Colors.black12,
    );
  }
  
}
