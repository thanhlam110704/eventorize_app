import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class EditTicketPage extends StatefulWidget {
  const EditTicketPage({super.key});

  @override
  EditTicketPageState createState() => EditTicketPageState();
}

class EditTicketPageState extends State<EditTicketPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  double _minPer = 30;
  double _maxPer = 70;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Chỉnh sửa vé',
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
                CustomTextField(label: "Tên vé", isRequired: true, isBold: true, initialValue: "Vé A"),
                CustomTextField(label: "Tổng quan", isRequired: true, maxLines: 4, isBold: true, initialValue: "Đây là...."),
                CustomTextField(label: "Số lượng", isRequired: true, keyboardType: TextInputType.number, isBold: true, initialValue: "1000"),
                CustomTextField(label: "Thời gian", isRequired: true, isBold: true, initialValue: "2025-11-23 to 2025-12-24"),
                CustomTextField(label: "Giá vé", isRequired: true, isBold: true, initialValue: "100.000 VND"),
                CustomDropdownField(
                  label: "Trạng thái", 
                  hintText: "Còn vé", 
                  items: ["Còn vé", "Hết vé", "Ẩn", "Tạm dừng"],
                  selectedValue: "Còn vé",
                  onChanged: (value) {
                    //
                  },
                  dropdownWidth: 345,
                ),
                buildRangeSlider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRangeSlider() {
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
                    values: RangeValues(_minPer, _maxPer),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withAlpha((0.2 * 255).toInt()),
                    labels: RangeLabels(
                      _minPer.round().toString(),
                      _maxPer.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minPer = values.start;
                        _maxPer = values.end;
                      });
                    },
                  ),
                  Positioned(
                    left: (_minPer / 100) * MediaQuery.of(context).size.width - 40,
                    top: -25,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text("Min per", style: AppTextStyles.text.copyWith(color: Colors.white, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: (_maxPer / 100) * MediaQuery.of(context).size.width - 40,
                    top: -25,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text("Max per", style: AppTextStyles.text.copyWith(color: Colors.white, fontSize: 13)),
                        ),
                      ],
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