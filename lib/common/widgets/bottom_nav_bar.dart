import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 3;

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    
    switch (index) {
      case 0:
        context.goNamed("home");
        break;
      case 1:
        context.goNamed("favorites");
        break;
      case 2:
        context.goNamed("tickets");
        break;
      case 3:
        context.goNamed("account"); 
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: onTabTapped,
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
          icon: Icon(MdiIcons.ticketOutline),
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