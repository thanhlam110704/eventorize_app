import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';

class BottomNavBar extends StatelessWidget {
  final Color? backgroundColor;

  const BottomNavBar({super.key, this.backgroundColor});

  int _getCurrentIndex(BuildContext context) {
    final String? currentRoute = GoRouterState.of(context).name;
    switch (currentRoute) {
      case 'home':
        return 0;
      case 'favorite':
        return 1;
      case 'ticket':
        return 2;
      case 'account':
        return 3;
      default:
        return 0; 
    }
  }

  void _onTabTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed("home");
        break;
      case 1:
        context.goNamed("favorite");
        break;
      case 2:
        context.goNamed("ticket");
        break;
      case 3:
        context.goNamed("account");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getCurrentIndex(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.linkBlue,
      unselectedItemColor: AppColors.black,
      backgroundColor: backgroundColor ?? AppColors.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) => _onTabTapped(index, context),
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.homeOutline),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.heartOutline),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.ticketConfirmationOutline),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.accountOutline),
          label: "",
        ),
      ],
    );
  }
}