import 'package:flutter/material.dart';

class LabeledInput extends StatefulWidget {
  final String label;
  final Widget child;

  const LabeledInput({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  State<LabeledInput> createState() => LabeledInputState();
}

class LabeledInputState extends State<LabeledInput> {
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