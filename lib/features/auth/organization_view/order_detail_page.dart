import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  OrderDetailPageState createState() => OrderDetailPageState();
}

class OrderDetailPageState extends State<OrderDetailPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Chi tiết đơn hàng',
        onLeadingPressed: () {
          context.pop();
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.black, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildImageSection(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  buildInfoRow("Tên sự kiện", "Mastering Vendor Development"),
                  const Divider(thickness: 0.7, height: 24),
                  buildInfoRow("Tên vé", "Vé A"),
                  const Divider(thickness: 0.7, height: 24),
                  buildInfoRow("Địa chỉ sự kiện", "Sự Vạn Hanh 888 Phường 1 Quận 10"),
                  const Divider(thickness: 0.7, height: 24),
                  buildInfoRow("Thời gian", "2025-11-23 đến 2025-12-24"),
                  const Divider(thickness: 0.7, height: 24),
                  buildInfoRow("Trạng thái", "Chờ xác nhận"),
                  const Divider(thickness: 0.7, height: 24),
                  buildInfoRow("Số lượng", "5"),
                  const Divider(thickness: 0.7, height: 24),
                  buildInfoRow("Tổng tiền", "100.000 VND"),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget buildImageSection() {
    return Image.asset(
      'assets/images/event2.png',
      width: double.infinity,
      height: 160,
      fit: BoxFit.cover,
    );
  }

    Widget buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.text.copyWith(fontSize: 15),
          ),
        ),
        const Text(
          ":",
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(width: 8), 
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bold.copyWith(fontSize: 15),
          ),
        ),
      ],
    ),
  );
}
}
