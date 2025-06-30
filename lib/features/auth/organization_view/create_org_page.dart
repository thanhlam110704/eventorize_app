import 'package:dotted_border/dotted_border.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateOrgPage extends StatefulWidget {
  const CreateOrgPage({super.key});

  @override
  CreateOrgPageState createState() => CreateOrgPageState();
}

class CreateOrgPageState extends State<CreateOrgPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

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
        title: 'Tạo nhà tổ chức',
        actionIcon: Icons.check,
        onLeadingPressed: () {
          Navigator.of(context).pop();
        },
        onActionPressed: () {
          context.go('/eventlist');
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
                CustomTextField(label: "Tên tổ chức", hintText: "Tên tổ chức", isRequired: true, isBold: true),
                CustomTextField(label: "Email", hintText: "Email", isRequired: true, keyboardType: TextInputType.emailAddress, isBold: true),
                CustomTextField(label: "Số điện thoại", hintText: "Số điện thoại", isRequired: true, keyboardType: TextInputType.phone, isBold: true),
                CustomTextField(label: "Tổng quan", hintText: "Tổng quan", isRequired: true, maxLines: 4, isBold: true),
                CustomTextField(label: "Ngày thành lập", hintText: "YYYY-MM-DD to YYYY-MM-DD", isRequired: true, isBold: true),
                buildLocationSection(),
                buildSocialLinksSection(),
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
                    style: AppTextStyles.text.copyWith(color: AppColors.grey, fontSize:13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Địa điểm", style: AppTextStyles.bold),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 5), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(label: "Địa chỉ", hintText: "Địa chỉ",),
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
      ],
    );
  }

  Widget buildSocialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text("Liên kết mạng xã hội", style: AppTextStyles.bold),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(label: "Facebook", hintText: "Facebook url",),
              CustomTextField(label: "Twitter", hintText: "Twitter url",),
              CustomTextField(label: "Instagram", hintText: "Instagram url",),
              CustomTextField(label: "LinkedIn", hintText: "LinkedIn url",),
            ],
          ),
        ),
      ],
    );
  }
}