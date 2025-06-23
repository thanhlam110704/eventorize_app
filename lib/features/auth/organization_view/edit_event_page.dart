import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/location_type.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:flutter/material.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key});

  @override
  EditEventPageState createState() => EditEventPageState();
}

class EditEventPageState extends State<EditEventPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  LocationType _selectedLocation = LocationType.location;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Chỉnh sửa sự kiện',
        actionIcon: Icons.check,
        onActionPressed: () {
         // Submit logic
        },
      ),
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: buildMainContainer(isSmallScreen, screenSize),
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 20 : 40,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), 
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImagePicker(),
                const SizedBox(height: 16),
                CustomTextField(label: "Tên sự kiện", isRequired: true, isBold: true, initialValue: "Mastering Vendor Development"),
                CustomTextField(label: "Tổng quan", isRequired: true, maxLines: 4, isBold: true, initialValue: "Mastering Vendor Development"),
                CustomTextField(label: "Thời gian", isRequired: true, isBold: true, initialValue: "2025-11-23 to 2025-12-24"),
                Text("Vị trí", style: AppTextStyles.bold),
                const SizedBox(height: 12),
                LocationToggle(
                  selected: _selectedLocation,
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedLocation == LocationType.location)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(label: "Địa chỉ", initialValue: "117 Gia Phu"),
                        CustomDropdownField(
                          label: "Thành phố",
                          hintText: "Chọn thành phố",
                          items: ["Hà Nội", "TP.HCM"],
                          selectedValue: "Hà Nội",
                          onChanged: (value) {
                            //
                          },
                          dropdownWidth: 345,
                        ),
                        CustomDropdownField(
                          label: "Quận",
                          hintText: "Chọn quận",
                          items: ["Quận 1", "Quận 2"],
                          selectedValue: "Quận 1",
                          onChanged: (value) {
                            //
                          },
                          dropdownWidth: 345,
                        ),
                        CustomDropdownField(
                          label: "Phường/huyện",
                          hintText: "Chọn phường/huyện",
                          items: ["Phường A", "Phường B"],
                          selectedValue: "Phường A",
                          onChanged: (value) {
                            //
                          },
                          dropdownWidth: 345,
                        ),
                      ],
                    ),
                  ),
                if (_selectedLocation == LocationType.online)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: CustomTextField(label: "Link sự kiện online", hintText: "Link"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ảnh", style: AppTextStyles.bold),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                'assets/images/event2.png',
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 140,
                color: Colors.black.withAlpha((0.6 * 255).toInt()),
              ),
            ),
            Positioned(
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFD9D9D9),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    // 
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

