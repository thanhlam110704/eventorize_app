import 'package:flutter/material.dart';

class LabeledInput extends StatefulWidget {
  final String label;
  final Widget child;

  const LabeledInput({
    Key? key,
    required this.label,
    required this.child,
  }) : super(key: key);

  @override
  State<LabeledInput> createState() => _LabeledInputState();
}

class _LabeledInputState extends State<LabeledInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        widget.child,
      ],
    );
  }
}
