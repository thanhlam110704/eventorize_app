import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';

class OTPFieldInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int index;
  final List<TextEditingController> allControllers;

  const OTPFieldInput({
    super.key,
    required this.controller,
    this.onChanged,
    required this.index,
    required this.allControllers,
  });

  @override
  State<OTPFieldInput> createState() => _OTPFieldInputState();
}

class _OTPFieldInputState extends State<OTPFieldInput> {
  static const fieldHeight = 48.0;
  final FocusNode _focusNode = FocusNode();
  DateTime? _lastBackspaceTime;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (widget.controller.text.isNotEmpty) {
        widget.controller.clear();
        return KeyEventResult.handled;
      }
      if (widget.index > 0) {
        final now = DateTime.now();
        if (_lastBackspaceTime == null ||
            now.difference(_lastBackspaceTime!).inMilliseconds > 500) {
          _lastBackspaceTime = now;
          widget.allControllers[widget.index - 1].clear();
          FocusScope.of(context).previousFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleTextChange(String value) {
    if (value.length == 1 && widget.index < widget.allControllers.length - 1) {
      FocusScope.of(context).nextFocus();
    }
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        height: fieldHeight,
        width: fieldHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _focusNode.hasFocus ? AppColors.primary : AppColors.grey,
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          maxLength: 1,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: _handleTextChange,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          style: AppTextStyles.text.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.0,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
    );
  }
}