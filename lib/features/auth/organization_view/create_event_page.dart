import 'package:dotted_border/dotted_border.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/location_type.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends State<CreateEventPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  LocationType _selectedLocation = LocationType.location;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Tạo sự kiện',
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
                CustomTextField(label: "Tên sự kiện", hintText: "Tên sự kiện", isRequired: true, isBold: true),
                CustomTextField(label: "Tổng quan", hintText: "Tổng quan", isRequired: true, maxLines: 4, isBold: true),
                CustomTextField(label: "Thời gian", hintText: "YYYY-MM-DD to YYYY-MM-DD", isRequired: true, isBold: true),
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
                        CustomTextField(label: "Địa chỉ", hintText: "Địa chỉ"),
                        CustomDropdownField(
                          label: "Thành phố",
                          hintText: "Chọn thành phố",
                          items: ["Hà Nội", "TP.HCM"],
                          selectedValue: selectedCity,
                          onChanged: (value) {
                            setState(() {
                              selectedCity = value;
                            });
                          },
                          dropdownWidth: 345,
                        ),
                        CustomDropdownField(
                          label: "Quận",
                          hintText: "Chọn quận",
                          items: ["Quận 1", "Quận 2"],
                          selectedValue: selectedDistrict,
                          onChanged: (value) {
                            setState(() {
                              selectedDistrict = value;
                            });
                          },
                          dropdownWidth: 345,
                        ),
                        CustomDropdownField(
                          label: "Phường/huyện",
                          hintText: "Chọn phường/huyện",
                          items: ["Phường A", "Phường B"],
                          selectedValue: selectedWard,
                          onChanged: (value) {
                            setState(() {
                              selectedWard = value;
                            });
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
        Text("Thêm ảnh", style: AppTextStyles.bold),
        const SizedBox(height: 8),
        DottedBorder(
          color: AppColors.grey,
          dashPattern: [6, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(5),
          child: Container(
            height: 140,
            width: double.infinity,
            color: AppColors.inputBackground,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/upload.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kéo và thả ảnh hoặc tải ảnh lên",
                    style: AppTextStyles.text.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}