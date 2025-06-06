import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';

class TopNavBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? titleColor;
  final double minTouchTargetSize;

  const TopNavBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.backgroundColor,
    this.iconColor,
    this.titleColor,
    this.minTouchTargetSize = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            Container(
              width: 40.0,
              height: 40.0,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: AppColors.iconButtonOverlay,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  size: 28,
                  color: iconColor ?? AppColors.black,
                  semanticLabel: 'Back',
                ),
                onPressed: () => context.pop(),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                  minHeight: 40.0,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Center(
                child: Text(
                  title,
                  style: AppTextStyles.pageTitle.copyWith(
                    color: titleColor ?? AppColors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}