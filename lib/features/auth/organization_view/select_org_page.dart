import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class SelectOrgPage extends StatefulWidget {
  const SelectOrgPage({super.key});

  @override
  SelectOrgPageState createState() => SelectOrgPageState();
}

class SelectOrgPageState extends State<SelectOrgPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showPopup = true;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          appBar: TopNavOrgBar(
            leadingIcon: Icons.menu,
            onLeadingPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            title: 'Danh sách sự kiện',
            actionIcon: Icons.search,
            onActionPressed: () {
              // 
            },
          ),
          drawer: const CustomDrawer(currentPage: AppPage.eventList),
          backgroundColor: AppColors.whiteBackground,
          body: const SizedBox.expand(), 
          floatingActionButton: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 50),
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () {
                  context.go('/createevent');
                },
                backgroundColor: const Color(0xFF194185),
                elevation: 6,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        if (showPopup) ...[
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withOpacity(0), 
              ),
            ),
          ),
          Center(
              child: Material(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.grey,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lựa chọn nhà tổ chức',
                            style: AppTextStyles.bold,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showPopup = false;
                              });
                            },
                            child: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chọn nhà tổ chức quản lý sự kiện',
                        style: AppTextStyles.text.copyWith(
                          color: AppColors.grey,
                          fontSize: 13,
                        ),
                      ),
                      CustomDropdownField(
                        label: '',
                        hintText: "Chọn nhà tổ chức",
                        items: ['Huflit', 'Huflit', 'Huflit', 'Huflit'],
                        selectedValue: selectedCity,
                        dropdownWidth: 300,
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value;
                          });
                          context.push('/createorg');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            
          ),
        ]
      ],
    );
  }
}