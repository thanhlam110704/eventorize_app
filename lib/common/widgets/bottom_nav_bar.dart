import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).routeInformationProvider.value.location;

    int currentIndex = 0;
    if (location.contains('/home')) {
      currentIndex = 0;
    } else if (location.contains('/favorites')) {
      currentIndex = 1;
    } else if (location.contains('/tickets')) {
      currentIndex = 2;
    } else if (location.contains('/account')) {
      currentIndex = 3;
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/favorites');
            break;
          case 2:
            context.go('/tickets');
            break;
          case 3:
            context.go('/account');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(MdiIcons.homeOutline), label: ""),
        BottomNavigationBarItem(icon: Icon(MdiIcons.heartOutline), label: ""),
        BottomNavigationBarItem(icon: Icon(MdiIcons.ticketOutline), label: ""),
        BottomNavigationBarItem(icon: Icon(MdiIcons.accountOutline), label: ""),
      ],
    );
  }
}