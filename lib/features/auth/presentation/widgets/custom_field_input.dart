import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:eventorize_app/assets/styles/text_styles.dart';
import 'package:eventorize_app/assets/styles/colors.dart';

enum InputType { email, password }

class CustomFieldInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final InputType inputType;
  final TextInputType keyboardType;

  const CustomFieldInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    required this.inputType,
    this.keyboardType = TextInputType.text,
  });

  @override
  CustomFieldInputState createState() => CustomFieldInputState();
}

class CustomFieldInputState extends State<CustomFieldInput> {
  static const smallScreenThreshold = 640.0;
  static const fieldHeight = 41.0;
  static const maxWidth = 600.0;

  bool obscureText = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateOnChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateOnChange);
    super.dispose();
  }

  void _validateOnChange() {
    setState(() {
      errorMessage = validateInput(widget.controller.text);
    });
  }

  String? validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ${widget.hintText.toLowerCase()}';
    }
    if (widget.inputType == InputType.email &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    if (widget.inputType == InputType.password && value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  bool validate() {
    setState(() {
      errorMessage = validateInput(widget.controller.text);
    });
    return errorMessage == null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Stack(
      children: [
        buildLeftBar(),
        buildInputContainer(isSmallScreen, screenSize),
      ],
    );
  }

  Widget buildLeftBar() {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: 27,
        height: fieldHeight,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }

  Widget buildInputContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: fieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  widget.icon,
                  color: AppColors.grey,
                  size: screenSize.width * 0.06,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: buildTextField(),
                ),
                if (widget.isPassword) buildVisibilityToggle(screenSize),
                const SizedBox(width: 12),
              ],
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                errorMessage!,
                style: AppTextStyles.hint.copyWith(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTextField() {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? obscureText : false,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintStyle: AppTextStyles.hint,
      ),
      style: AppTextStyles.text,
    );
  }

  Widget buildVisibilityToggle(Size screenSize) {
    return GestureDetector(
      onTap: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
      child: Icon(
        obscureText ? MdiIcons.eyeOff : MdiIcons.eye,
        color: AppColors.grey,
        size: screenSize.width * 0.06,
      ),
    );
  }
}