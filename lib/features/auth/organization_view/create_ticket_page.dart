import 'package:eventorize_app/common/components/ticket_range_slider.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:flutter/material.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  CreateTicketPageState createState() => CreateTicketPageState();
}

class CreateTicketPageState extends State<CreateTicketPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  double _minPer = 30;
  double _maxPer = 70;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Tạo vé',
        actionIcon: Icons.check,
        onLeadingPressed: () {
          Navigator.of(context).pop();
        },
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
                CustomTextField(label: "Tên vé", hintText: "Tên vé", isRequired: true, isBold: true),
                CustomTextField(label: "Tổng quan", hintText: "Tổng quan", isRequired: true, maxLines: 4, isBold: true),
                CustomTextField(label: "Số lượng", hintText: "0", isRequired: true, keyboardType: TextInputType.number, isBold: true),
                CustomTextField(label: "Thời gian", hintText: "YYYY-MM-DD to YYYY-MM-DD", isRequired: true, isBold: true),
                CustomTextField(label: "Giá vé", hintText: "0.000 VND", isRequired: true, isBold: true),
                CustomDropdownField(
                  label: "Trạng thái", 
                  hintText: "Còn vé", 
                  items: ["Còn vé", "Hết vé", "Ẩn", "Tạm dừng"],
                  selectedValue: selectedCity,
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                  dropdownWidth: 345,
                ),
                PerRangeSlider(
                  minPer: _minPer,
                  maxPer: _maxPer,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minPer = values.start;
                      _maxPer = values.end;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}