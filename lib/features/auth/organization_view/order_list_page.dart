import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view_model/order_list_view_model.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/common/components/custom_event_menu.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

final getIt = GetIt.instance;

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  OrderListPageState createState() => OrderListPageState();
}

class OrderListPageState extends State<OrderListPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = getIt<OrderListViewModel>();
      viewModel.fetchOrders(
        page: 1,
        limit: 20,
        search: "",
      );
    });

    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        final viewModel = getIt<OrderListViewModel>();
        viewModel.fetchOrders(
          page: 1,
          limit: 20,
          search: _searchController.text.trim(),
        );
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
        onSearchChanged: (query) {
          _searchController.text = query;
        },
      ),
      drawer: const CustomDrawer(currentPage: AppPage.orderList),
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: ChangeNotifierProvider<OrderListViewModel>.value(
          value: getIt<OrderListViewModel>(),
          child: Consumer<OrderListViewModel>(
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

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, OrderListViewModel viewModel) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      child: viewModel.orders.isEmpty && !viewModel.isLoading
          ? buildOrderList(viewModel)
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildOrderList(viewModel),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildOrderList(OrderListViewModel viewModel) {
    if (viewModel.isLoading) {
      return Column(
        children: List.generate(
          7,
          (index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: buildSkeletonCard(),
          ),
        ),
      );
    }
    if (viewModel.orders.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/no_data.svg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Container(
                width: 100,
                height: 100,
                color: AppColors.skeleton,
                child: const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không có đơn hàng',
              style: AppTextStyles.text,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      key: UniqueKey(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.orders.length,
      itemBuilder: (context, index) {
        final order = viewModel.orders[index];
        return Column(
          children: [
            buildOrderItem(index, order),
            const Divider(height: 1, thickness: 1, color: AppColors.grey),
          ],
        );
      },
    );
  }

  Widget buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            color: AppColors.shimmerBase,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  color: AppColors.shimmerBase,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      color: AppColors.shimmerBase,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            color: AppColors.shimmerBase,
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem(int index, Order order) {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24,
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order_id: ${order.orderNo}',
                      style: AppTextStyles.bold,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Tổng tiền:',
                          style: AppTextStyles.bold.copyWith(fontSize: 13),
                        ),
                        const SizedBox(width: 1),
                        Text(
                          ' ${order.amount == 0 ? 'Miễn phí' : '${order.amount} VND'}',
                          style: AppTextStyles.text.copyWith(fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trạng thái:',
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 1),
                        Text(
                          ' ${localizeStatus(order.status)}',
                          style: AppTextStyles.text.copyWith(
                            fontSize: 13,
                            color: getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                onPressed: () {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final position = box.localToGlobal(Offset.zero);
                  showEventMenu(context, position, order);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEventMenu(BuildContext context, Offset position, Order order) {
    OverlayEntry? entry;

    void closeMenu(BuildContext dialogContext) {
      if (entry != null) {
        entry!.remove();
        entry = null;
      }
      Navigator.of(dialogContext).pop();
    }

    entry = OverlayEntry(
      builder: (dialogContext) => Positioned(
        top: position.dy + 40,
        left: position.dx - 80,
        child: Material(
          color: Colors.transparent,
          child: CustomEventMenu(
            onEdit: () {},
            onDelete: () {},
            onTickets: () {},
            onDetail: () {
              closeMenu(dialogContext);
              context.push('/order/${order.id}');
            },
            showTickets: false,
            showDetail: true,
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(entry!);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          closeMenu(dialogContext);
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}