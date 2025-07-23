import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/common/components/bottom_nav_bar.dart';
import 'package:eventorize_app/data/api/order_api.dart';
import 'package:eventorize_app/data/models/order_item.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/features/auth/user_view_model/ticket_view_model.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eventorize_app/features/auth/user_view_model/home_view_model.dart';
import 'package:eventorize_app/core/utils/datetime_convert.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  TicketPageState createState() => TicketPageState();
}

class TicketPageState extends State<TicketPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 800.0;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return ChangeNotifierProvider(
      create: (_) => TicketViewModel(
        orderRepository: OrderRepository(OrderApi(DioClient())),
      ),
      child: Consumer<TicketViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.errorMessage != null && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ToastCustom.show(
                context: context,
                title: 'Lỗi',
                description: viewModel.errorMessage!,
                type: ToastificationType.error,
              );
              viewModel.clearError();
            });
          }

          return Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: SafeArea(
              child: buildMainContent(isSmallScreen, screenSize, viewModel),
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.grey,
                ),
                const BottomNavBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildMainContent(bool isSmallScreen, Size screenSize, TicketViewModel viewModel) {
    if (viewModel.isLoading) {
      return buildSkeleton(isSmallScreen, screenSize);
    }

    if (viewModel.tickets.isEmpty) {
      return buildEmptyState(isSmallScreen, screenSize);
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: buildMainContainer(isSmallScreen, screenSize, viewModel),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, TicketViewModel viewModel) {
    return Container(
      width: screenSize.width,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 20 : 40,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 15),
              buildTicketList(viewModel, screenSize, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text(
      'Lịch sử đặt vé',
      style: AppTextStyles.title,
    );
  }

  Widget buildSkeletonBox(double width, double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.skeleton,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget buildSkeleton(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 20 : 40,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 15),
              buildSkeletonContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSkeletonContent() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: Container(
            decoration: const BoxDecoration(),
            child: SizedBox(
              width: 360,
              height: 170,
              child: ClipPath(
                clipper: TicketClipper(),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildSkeletonBox(220, 40), 
                                  const SizedBox(height: 10),
                                  buildSkeletonBox(220, 20), 
                                  const SizedBox(height: 10),
                                  buildSkeletonBox(200, 16), 
                                  const SizedBox(height: 10),
                                  buildSkeletonBox(200, 16),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: const BoxDecoration(),
                                child: buildSkeletonBox(66, 66), 
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0.72 * 360 - 0.5,
                      top: 0,
                      bottom: 0,
                      child: const VerticalDashedLine(),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: TicketBorderPainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTicketList(TicketViewModel viewModel, Size screenSize, bool isSmallScreen) {
    return Column(
      children: viewModel.tickets.asMap().entries.map((entry) {
        final ticket = entry.value;
        // Find the order containing this ticket
        final order = viewModel.orders.firstWhere(
          (order) => order.orderItems.contains(ticket),
          orElse: () => throw Exception('Không có đơn hàng'),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: GestureDetector(
            onTap: () {
              context.pushNamed('ticketDetail', pathParameters: {'orderId': order.id});
            },
            child: buildTicketCard(ticket),
          ),
        );
      }).toList(),
    );
  }

  Widget buildEmptyState(bool isSmallScreen, Size screenSize) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 30),
              SizedBox(
                height: screenSize.height / 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/buy_ticket.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 300,
                        child: Text(
                          'Mua vé để tham gia sự kiện',
                          style: AppTextStyles.sectionTitle.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
                          context.goNamed('home');
                          homeViewModel.fetchEvents(
                            page: 1,
                            limit: 10,
                            city: homeViewModel.selectedCity,
                            isFromNavigation: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Mua vé ngay!',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTicketCard(OrderItem ticket) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 360 ? constraints.maxWidth : 360;
        return SizedBox(
          width: cardWidth.toDouble(),
          height: 171,
          child: Stack(
            children: [
              ClipPath(
                clipper: TicketClipper(),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 12, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.eventTitle ?? '',
                                style: AppTextStyles.semibold.copyWith(fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ticket.eventAddress ?? '',
                                style: AppTextStyles.medium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateTimeConverter.formatDateRange(
                                  ticket.eventStartDate,
                                  ticket.eventEndDate,
                                  pattern: 'dd \'thg\' M, HH:mm',
                                ),
                                style: AppTextStyles.medium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Loại vé: ', style: AppTextStyles.semibold.copyWith(fontSize: 13)),
                                  Text(ticket.ticketTitle ?? '', style: AppTextStyles.text.copyWith(fontSize: 13)),
                                  const SizedBox(width: 30),
                                  Text('Số lượng: ', style: AppTextStyles.semibold.copyWith(fontSize: 13)),
                                  Text(
                                    ticket.quantity.toString(),
                                    style: AppTextStyles.text.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/qr_code.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0.72 * cardWidth - 0.5,
                top: 0,
                bottom: 0,
                child: const VerticalDashedLine(),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: TicketBorderPainter(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VerticalDashedLine extends StatelessWidget {
  const VerticalDashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    const double radius = 10;
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashHeight = constraints.maxHeight - 2 * radius;
        return RotatedBox(
          quarterTurns: 1,
          child: DottedLine(
            dashColor: AppColors.darkGrey,
            dashLength: 8,
            dashGapLength: 4,
            lineThickness: 1,
            lineLength: dashHeight,
          ),
        );
      },
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double cornerRadius = 12;
    const double notchRadius = 12;
    final double notchX = size.width * 0.72;

    final ticketPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(cornerRadius),
      ));

    final topNotch = Path()
      ..addOval(Rect.fromCircle(center: Offset(notchX, 0), radius: notchRadius));

    final bottomNotch = Path()
      ..addOval(Rect.fromCircle(center: Offset(notchX, size.height), radius: notchRadius));

    final fullPath = Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, ticketPath, topNotch),
      bottomNotch,
    );

    return fullPath;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TicketBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = TicketClipper().getClip(size);

    final paint = Paint()
      ..color = AppColors.darkGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}