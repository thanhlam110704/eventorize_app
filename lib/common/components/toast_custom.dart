import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';

class ToastCustom {
  static void show({
    required BuildContext context,
    required String title,
    String? description,
    ToastificationType type = ToastificationType.success,
    ToastificationStyle style = ToastificationStyle.minimal,
    Duration autoCloseDuration = const Duration(seconds: 3),
    Alignment alignment = Alignment.topCenter,
    bool showProgressBar = false,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: style,
      title: Text(
        title,
        style: AppTextStyles.text.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: description != null
          ? Text(
              description,
              style: AppTextStyles.text.copyWith(
                color: Colors.black,
              ),
            )
          : null,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
      showProgressBar: showProgressBar
    );
  }
}