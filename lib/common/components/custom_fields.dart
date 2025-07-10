import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? hintText; 
  final List<String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;
  final double? dropdownWidth;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.hintText, 
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.dropdownWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.text),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            initialSelection: selectedValue,
            onSelected: onChanged,
            dropdownMenuEntries: items
                .map((item) => DropdownMenuEntry(value: item, label: item))
                .toList(),
            width: dropdownWidth ?? double.infinity,
            hintText: hintText,
            textStyle: AppTextStyles.text, 
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: const BorderSide(color: AppColors.grey),
                ),
              ),
              elevation: WidgetStateProperty.all(2),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final bool isRequired;
  final bool isBold;
  final TextInputType keyboardType;
  final int maxLines;
  final String? initialValue;
  final bool readOnly;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.isBold = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.initialValue,
    this.readOnly = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = isBold ? AppTextStyles.bold : AppTextStyles.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: labelStyle,
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: labelStyle.copyWith(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: readOnly ? 0.6 : 1.0,
            child: TextFormField(
              controller: controller ?? TextEditingController(text: initialValue),
              keyboardType: keyboardType,
              maxLines: maxLines,
              readOnly: readOnly,
              style: AppTextStyles.text,
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                filled: true,
                fillColor: AppColors.inputBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}