import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/bottom_nav_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
        isSmallScreen ? 20 : 40,
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
      style: AppTextStyles.title.copyWith(fontSize: 36),
    );
  }

  Widget buildUserCard() {
    final String initials = 'LT';
    final String name = 'Lâm Tuấn Thành';
    final String email = 'ltthanh@1107@gmail.com';

    return SizedBox(
    height: 180,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.black,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.text.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                )),
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
                      side: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ), 
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
    )
    );
  }
  
  Widget buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 20),
        buildPreferenceItem(
          icon: MdiIcons.mapMarker,
          title: 'Location',
          onTap: () {},
        ),
        buildDivider(),
        const SizedBox(height: 20),
        buildPreferenceItem(
          icon: MdiIcons.domain,
          title: 'Organization',
          onTap: () {},
        ),
        buildDivider(),
        const SizedBox(height: 20),
        buildPreferenceItem(
          icon: MdiIcons.accountCircle,
          title: 'Linked accounts',
          onTap: () {},
        ),
        buildDivider(),
        const SizedBox(height: 60),
        buildLogoutItem(),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget buildPreferenceItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 8), 
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.text.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget buildLogoutItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // todo: logout
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Color(0xFFEC0303)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
             padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16), 
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: Color(0xFFEC0303)),
                  const SizedBox(width: 8),
                  Text(
                    'Log out',
                    style: AppTextStyles.text.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEC0303),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),  
        Center(
          child: Text(
            'Version 1.0.0',
            style: AppTextStyles.text.copyWith(
              fontSize: 12,
            ),
          ),
        ),
      ],  
    );  
  }

  Widget buildDivider() {
    return const Divider(
      height: 0,
      thickness: 1,
      color: Colors.black12,
    );
  }
}
