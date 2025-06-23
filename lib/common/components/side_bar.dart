import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum AppPage { orgInfo, eventList, orderList }

class CustomDrawer extends StatelessWidget {
  final AppPage currentPage;

  const CustomDrawer({super.key, required this.currentPage});

    @override
    Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Top
          Container(
            width: double.infinity,
            color: const Color(0xFFECEDF6),
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 36),
            child: Row(
              children: [
                CircleAvatar( 
                  radius: 36,
                  backgroundColor: Color(0xFF065290),
                  child: Text(
                    "FPT",
                    style: AppTextStyles.semibold.copyWith(color: Colors.white, fontSize: 25),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FPT Sofware",
                      style: AppTextStyles.bold.copyWith(fontSize: 20),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "fptsoftware@gmail.com",
                      style: AppTextStyles.text
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: MdiIcons.domain,
                    text: "Nhà tổ chức",
                    selected: currentPage == AppPage.orgInfo,
                    onTap: () {
                      context.go('/orginfo');
                    },
                  ),
                  _buildDrawerItem(
                    icon: MdiIcons.calendar,
                    text: "Danh sách sự kiện",
                    selected: currentPage == AppPage.eventList,
                    onTap: () {
                      context.go('/eventlist');
                    },
                  ),
                  _buildDrawerItem(
                    icon: MdiIcons.viewGridOutline,
                    text: "Danh sách đơn hàng",
                    selected: currentPage == AppPage.orderList,
                    onTap: () {
                      context.go('/orderlist');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.swap_horiz,
                    text: "Switch to attending",
                    selected: false,
                    onTap: () {
                      // 
                    },
                  ),
                  _buildLogoutItem(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFC4E3FD) : Colors.white, 
        border: const Border(
          bottom: BorderSide(color: AppColors.grey),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(text, style: AppTextStyles.text),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: Text(
          "Đăng xuất",
          style: AppTextStyles.text.copyWith(color: Colors.red),
        ),
        trailing: Text(
          "Phiên bản 1.0.0",
          style: AppTextStyles.text.copyWith(fontSize: 13),
        ),
        onTap: () {},
      ),
    );
  }
}
