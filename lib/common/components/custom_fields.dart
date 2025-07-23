import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final String? hintText;
  final List<String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;
  final double? dropdownWidth;
  final double menuHeight;
  final bool isRequired;
  final String? Function(String?)? validator;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.hintText,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.dropdownWidth,
    this.menuHeight = 200,
    this.isRequired = false,
    this.validator,
  });

  @override
  CustomDropdownFieldState createState() => CustomDropdownFieldState();
}

class CustomDropdownFieldState extends State<CustomDropdownField> {
  String? _errorMessage;

  String? _validateInput(String? value) {
    if (widget.validator != null) {
      final result = widget.validator!(value);
      if (result != null) {
        return result;
      }
    }
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'Vui lòng chọn ${widget.label.toLowerCase()}';
    }
    return null;
  }

  bool validate() {
    setState(() {
      _errorMessage = _validateInput(widget.selectedValue);
    });
    return _errorMessage == null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppTextStyles.text,
              children: widget.isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: AppTextStyles.text.copyWith(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            initialSelection: widget.selectedValue,
            onSelected: (value) {
              widget.onChanged(value);
              setState(() {
                _errorMessage = _validateInput(value);
              });
            },
            dropdownMenuEntries: widget.items
                .map((item) => DropdownMenuEntry(value: item, label: item))
                .toList(),
            width: widget.dropdownWidth ?? double.infinity,
            hintText: widget.hintText,
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
              maximumSize: WidgetStateProperty.all(Size(double.infinity, widget.menuHeight)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              hintStyle: AppTextStyles.text.copyWith(color: AppColors.grey),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _errorMessage!,
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
}

class CustomTextField extends StatefulWidget {
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
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

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
    this.onTap,
    this.onChanged,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  String? _validateInput(String? value) {
    if (widget.validator != null) {
      final result = widget.validator!(value);
      if (result != null) {
        return result;
      }
    }
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'Vui lòng nhập ${widget.label.toLowerCase()}';
    }
    return null;
  }

  bool validate() {
    setState(() {
      _errorMessage = _validateInput(_internalController.text);
    });
    return _errorMessage == null;
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = widget.isBold ? AppTextStyles.bold : AppTextStyles.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style: labelStyle,
              children: widget.isRequired
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
            opacity: widget.readOnly ? 0.6 : 1.0,
            child: TextFormField(
              controller: _internalController,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              style: AppTextStyles.text,
              validator: (value) => _validateInput(value),
              onTap: () {
                widget.onTap?.call();
                setState(() {
                  _errorMessage = _validateInput(_internalController.text);
                });
              },
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.text.copyWith(color: AppColors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                filled: true,
                fillColor: AppColors.inputBackground,
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _errorMessage!,
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
}