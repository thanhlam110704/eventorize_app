import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';

enum AppPage { orgInfo, eventList, orderList, ticketList }

class CustomDrawer extends StatelessWidget {
  final AppPage currentPage;

  const CustomDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Consumer<SessionManager>(
            builder: (context, sessionManager, _) {
              final organizerName = sessionManager.selectedOrganizerName;
              final organizerLogo = sessionManager.selectedOrganizerLogo;
              final organizerEmail = sessionManager.selectedOrganizerEmail;
              final initials = organizerName != null && organizerName.isNotEmpty
                  ? organizerName.split(' ').map((e) => e[0]).take(2).join()
                  : 'N/A';

              return Container(
                width: double.infinity,
                color: const Color(0xFFECEDF6),
                padding: const EdgeInsets.fromLTRB(16, 64, 16, 36),
                child: organizerName == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chưa chọn nhà tổ chức",
                            style: AppTextStyles.bold.copyWith(fontSize: 20),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          organizerLogo != null && organizerLogo.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: organizerLogo,
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                    radius: 36,
                                    backgroundImage: imageProvider,
                                  ),
                                  placeholder: (context, url) => CircleAvatar(
                                    radius: 36,
                                    backgroundColor: const Color(0xFF065290),
                                    child: Text(
                                      initials,
                                      style: AppTextStyles.semibold.copyWith(color: Colors.white, fontSize: 25),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => CircleAvatar(
                                    radius: 36,
                                    backgroundColor: const Color(0xFF065290),
                                    child: Text(
                                      initials,
                                      style: AppTextStyles.semibold.copyWith(color: Colors.white, fontSize: 25),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xFF065290),
                                  child: Text(
                                    initials,
                                    style: AppTextStyles.semibold.copyWith(color: Colors.white, fontSize: 25),
                                  ),
                                ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                organizerName,
                                style: AppTextStyles.bold.copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                organizerEmail ?? '',
                                style: AppTextStyles.text,
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Consumer<SessionManager>(
                    builder: (context, sessionManager, _) {
                      return _buildDrawerItem(
                        icon: MdiIcons.domain,
                        text: "Nhà tổ chức",
                        selected: currentPage == AppPage.orgInfo,
                        onTap: () {
                          if (sessionManager.selectedOrganizerId == null) {
                            ToastCustom.show(
                              context: context,
                              title: 'Lỗi',
                              description: 'Vui lòng chọn một nhà tổ chức trước',
                              type: ToastificationType.error,
                            );
                            return;
                          }
                          context.go('/org-info');
                        },
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: MdiIcons.calendar,
                    text: "Danh sách sự kiện",
                    selected: currentPage == AppPage.eventList,
                    onTap: () {
                      if (context.read<SessionManager>().selectedOrganizerId == null) {
                        ToastCustom.show(
                          context: context,
                          title: 'Lỗi',
                          description: 'Vui lòng chọn một nhà tổ chức trước',
                          type: ToastificationType.error,
                        );
                        return;
                      }
                      context.go('/event-list');
                    },
                  ),
                  _buildDrawerItem(
                    icon: MdiIcons.ticketConfirmationOutline,
                    text: "Danh sách vé",
                    selected: currentPage == AppPage.ticketList,
                    onTap: () {
                      context.go('/ticket-list');
                    },
                  ),
                  _buildDrawerItem(
                    icon: MdiIcons.viewGridOutline,
                    text: "Danh sách đơn hàng",
                    selected: currentPage == AppPage.orderList,
                    onTap: () {
                      context.go('/order-list');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.swap_horiz,
                    text: "Chế độ người dùng",
                    selected: false,
                    onTap: () {
                      context.push('/home');
                    },
                  ),
                  _buildLogoutItem(context),
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
          bottom: BorderSide(color: AppColors.grey, width: 0.5),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(text, style: AppTextStyles.text),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey, width: 0.5),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.red),
        title: Text(
          "Đăng xuất",
          style: AppTextStyles.text.copyWith(color: AppColors.red),
        ),
        trailing: Text(
          "Phiên bản 1.0.0",
          style: AppTextStyles.text.copyWith(fontSize: 13),
        ),
        onTap: () async {
          final sessionManager = context.read<SessionManager>();
          final toastContext = context;
          try {
            await sessionManager.logout();
            if (context.mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ToastCustom.show(
                    context: toastContext,
                    title: 'Đăng xuất thành công!',
                    type: ToastificationType.success,
                  );
                  GoRouter.of(context).pushReplacementNamed('login');
                }
              });
            }
          } catch (e) {
            if (context.mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ToastCustom.show(
                    context: toastContext,
                    title: sessionManager.errorTitle ?? 'Lỗi',
                    description: sessionManager.errorMessage ?? 'Đăng xuất thất bại',
                    type: ToastificationType.error,
                  );
                }
              });
            }
          }
        },
      ),
    );
  }
}