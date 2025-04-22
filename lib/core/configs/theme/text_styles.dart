import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
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
}