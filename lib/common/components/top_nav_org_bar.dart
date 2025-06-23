import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class TopNavOrgBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData leadingIcon;
  final VoidCallback? onLeadingPressed;
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  const TopNavOrgBar({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.onLeadingPressed,
    this.actionIcon,
    this.onActionPressed,
  });

  @override
Widget build(BuildContext context) {
  return AppBar(
    backgroundColor: const Color(0xFF1E266D),
    automaticallyImplyLeading: false,
    titleSpacing: 0, 
    title: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16), 
  child: Row(
    children: [
      IconButton(
        icon: Icon(leadingIcon, color: Colors.white),
        onPressed: onLeadingPressed ?? () => Navigator.pop(context),
      ),
      Text(
        title,
        style: AppTextStyles.bold.copyWith(fontSize: 25,color: Colors.white)
      ),
      const Spacer(),
      if (actionIcon != null)
        IconButton( 
          icon: Icon(actionIcon, color: Colors.white),
          onPressed: onActionPressed,
        ),
    ],
  ),
),
  );
}


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
