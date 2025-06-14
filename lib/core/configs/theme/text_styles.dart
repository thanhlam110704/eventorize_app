import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    fontSize: 36,
    color: AppColors.black,
  );

  static const TextStyle logo = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w900,
    fontSize: 36,
    color: AppColors.primary,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: 'Roboto',
    fontStyle: FontStyle.normal,
    fontSize: 16,
    color: AppColors.grey,
  );

  static const TextStyle text = TextStyle(
    fontFamily: 'Roboto',
    fontStyle: FontStyle.normal,
    fontSize: 16,
    color: AppColors.black,
  );

  static const TextStyle link = TextStyle(
    fontFamily: 'Roboto',
    fontStyle: FontStyle.normal,
    fontSize: 16,
    color: AppColors.linkBlue,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: AppColors.black,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.black,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.white,
  ); 

  static const TextStyle underlined = TextStyle( 
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.black,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.black,
    decorationThickness: 1.4,
  );

  static const TextStyle disabled = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.disabledGrey,
  );

  static const TextStyle avatarInitials = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.white,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.black,
  );
}