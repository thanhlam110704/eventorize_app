import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  OrderListPageState createState() => OrderListPageState();
}

class OrderListPageState extends State<OrderListPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0; 

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> tickets = [
    {'title': 'Order 1'},
    {'title': 'Order 2'},
    {'title': 'Order 3'},
  ];

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
        title: 'Danh sách đơn hàng',
        actionIcon: Icons.search,
        onActionPressed: () {
         // Submit logic
        },
      ),
      drawer: const CustomDrawer(currentPage: AppPage.orderList),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildOrderList(),
        ],
      ),
    );
  }

  Widget buildOrderItem(int index, Map<String, dynamic> ticket) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Container(
                width: 24,
                alignment: Alignment.center, 
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.bold
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket['title'],
                      style: AppTextStyles.semibold
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Quantity: 2',
                      style: AppTextStyles.text.copyWith(fontSize:13)
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {
                  // 
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.grey),
      ],
    );
  }



  Widget buildOrderList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        tickets.length,
        (index) => buildOrderItem(index, tickets[index]),
      ),
    ); 
  }

  
}