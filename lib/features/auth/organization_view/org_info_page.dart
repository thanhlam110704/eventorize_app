import 'dart:io';
import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OrgInfoPage extends StatefulWidget {
  const OrgInfoPage({super.key});

  @override
  OrgInfoPageState createState() => OrgInfoPageState();
}

class OrgInfoPageState extends State<OrgInfoPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  File? _pickedImage;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      key: _scaffoldKey,
      appBar: TopNavOrgBar(
        leadingIcon: Icons.menu,
        onLeadingPressed: () {
          _scaffoldKey.currentState?.openDrawer(); 
        },
        title: 'Nhà tổ chức',
        actionIcon: Icons.check,
        onActionPressed: () {
          // to do
        },
      ),
      drawer: const CustomDrawer(currentPage: AppPage.orgInfo),
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
                buildImageUpload(),
                Text("Thông tin nhà tổ chức", style: AppTextStyles.bold.copyWith(fontSize: 20),),
                const SizedBox(height: 8),
                CustomTextField(label: "Tên", initialValue: "FPT Software Company"),
                CustomTextField(label: "Email", initialValue: "fptsoftware@gmail.com", readOnly: true),
                CustomTextField(label: "Số điện thoại", keyboardType: TextInputType.number, initialValue: "0901734198"),
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
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Widget buildImageUpload() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF065290),
            backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
            child: _pickedImage == null
                ? Text(
                    "FPT",
                    style: AppTextStyles.semibold.copyWith(color: Colors.white, fontSize: 38),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _pickImage,
            child: Text(
              "Tải ảnh lên",
              style: AppTextStyles.text.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}