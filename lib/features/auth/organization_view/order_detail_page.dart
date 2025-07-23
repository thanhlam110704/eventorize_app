import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view_model/order_detail_view_model.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:shimmer/shimmer.dart';

final getIt = GetIt.instance;

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  OrderDetailPageState createState() => OrderDetailPageState();
}

class OrderDetailPageState extends State<OrderDetailPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = getIt<OrderDetailViewModel>();
      viewModel.fetchOrderDetail(widget.orderId);
    });
  }

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
        child: ChangeNotifierProvider<OrderDetailViewModel>.value(
          value: getIt<OrderDetailViewModel>(),
          child: Consumer<OrderDetailViewModel>(
            builder: (context, viewModel, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && viewModel.errorMessage != null) {
                  ToastCustom.show(
                    context: context,
                    title: viewModel.errorTitle ?? 'Lỗi',
                    description: viewModel.errorMessage!,
                    type: ToastificationType.error,
                  );
                  viewModel.clearError();
                }
              });

              return buildMainContainer(isSmallScreen, screenSize, viewModel);
            },
          ),
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, OrderDetailViewModel viewModel) {
    return SingleChildScrollView(
      child: Container(
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
            child: viewModel.isLoading
                ? buildSkeletonCard()
                : viewModel.order == null
                    ? Center(
                        child: Text(
                          'Không tìm thấy đơn hàng',
                          style: AppTextStyles.text.copyWith(fontSize: 16),
                        ),
                      )
                    : buildOrderDetailCard(viewModel.order!),
          ),
        ),
      ),
    );
  }

  Widget buildSkeletonCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  color: AppColors.skeleton,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.skeleton,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 24),
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.skeleton,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonEventTimeRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 8),
              buildSkeletonInfoRow(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSkeletonInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        height: 15,
        decoration: BoxDecoration(
          color: AppColors.skeleton,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget buildSkeletonEventTimeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        height: 15,
        decoration: BoxDecoration(
          color: AppColors.skeleton,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget buildOrderDetailCard(Order order) {
    String localizeStatus(String status) {
      const statusMap = {
        'active': 'Hoạt động',
        'pending': 'Đang xử lý',
      };
      return statusMap[status] ?? status;
    }

    Color getStatusColor(String status) {
      return status == 'active' ? const Color(0xFF09D270) : Colors.amber[400]!;
    }

    String formatDateRange(DateTime startDate, DateTime endDate) {
      final formatter = DateFormat('dd/MM/yyyy');
      return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImageSection(),
            const SizedBox(height: 16),
            Text(
              'Thông tin đơn hàng',
              style: AppTextStyles.bold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            buildInfoRow('Order_id:', order.orderNo),
            const SizedBox(height: 8),
            buildInfoRow('Tên người đặt:', order.userName ?? 'Không có'),
            const SizedBox(height: 8),
            buildInfoRow('Email:', order.userEmail ?? 'Không có'),
            const SizedBox(height: 8),
            buildInfoRow('Số điện thoại:', order.userPhone ?? 'Không có'),
            const SizedBox(height: 8),
            buildInfoRow(
              'Trạng thái:',
              localizeStatus(order.status),
              valueStyle: AppTextStyles.text.copyWith(
                fontSize: 15,
                color: getStatusColor(order.status),
              ),
            ),
            const SizedBox(height: 8),
            buildInfoRow('Tổng tiền:',
                order.amount == 0 ? 'Miễn phí' : '${order.amount} VND'),
            if (order.orderItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Chi tiết vé',
                style: AppTextStyles.bold.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...order.orderItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const SizedBox(height: 8),
                    buildInfoRow('Tên sự kiện:', item.eventTitle ?? 'Không có'),
                    const SizedBox(height: 8),
                    buildInfoRow('Tên vé:', item.ticketTitle ?? 'Không có'),
                    const SizedBox(height: 8),
                    buildInfoRow('Địa chỉ sự kiện:', item.eventAddress ?? 'Không có'),
                    const SizedBox(height: 8),
                    buildInfoRow(
                      'Thời gian sự kiện:',
                      formatDateRange(item.eventStartDate, item.eventEndDate),
                    ),
                    const SizedBox(height: 8),
                    buildInfoRow('Số lượng:', item.quantity.toString()),
                    const SizedBox(height: 8),
                    buildInfoRow(
                      'Giá vé:',
                      item.price == 0 ? 'Miễn phí' : '${item.price} VND',
                    ),
                  ],
                );
              }),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/event2.png',
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.text.copyWith(fontSize: 15),
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? AppTextStyles.text.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}