import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class PerRangeSlider extends StatelessWidget {
  final double minPer;
  final double maxPer;
  final ValueChanged<RangeValues> onChanged;

  const PerRangeSlider({
    super.key,
    required this.minPer,
    required this.maxPer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Per range',
              style: AppTextStyles.text,
              children: [
                TextSpan(
                  text: ' *',
                  style: AppTextStyles.text.copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("0"),
                  Text("100"),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  RangeSlider(
                    values: RangeValues(minPer, maxPer),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withAlpha((0.2 * 255).toInt()),
                    labels: RangeLabels(
                      minPer.round().toString(),
                      maxPer.round().toString(),
                    ),
                    onChanged: onChanged,
                  ),
                  Positioned(
                    left: (minPer / 100) * MediaQuery.of(context).size.width - 40,
                    top: -25,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("Min per",
                          style: AppTextStyles.text.copyWith(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                  Positioned(
                    left: (maxPer / 100) * MediaQuery.of(context).size.width - 40,
                    top: -25,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("Max per",
                          style: AppTextStyles.text.copyWith(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
