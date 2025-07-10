import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

enum LocationType { location, online }

class LocationToggle extends StatefulWidget {
  final LocationType selected;
  final void Function(LocationType) onChanged;

  const LocationToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<LocationToggle> createState() => _LocationToggleState();
}

class _LocationToggleState extends State<LocationToggle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(
            title: "Địa điểm",
            isSelected: widget.selected == LocationType.location,
            onTap: () => widget.onChanged(LocationType.location),
          ),
          _buildTab(
            title: "Sự kiện online",
            isSelected: widget.selected == LocationType.online,
            onTap: () => widget.onChanged(LocationType.online),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyles.text.copyWith(fontSize:13)
          ),
        ),
      ),
    );
  }
}