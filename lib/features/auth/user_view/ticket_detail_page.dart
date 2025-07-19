import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:eventorize_app/data/api/order_api.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/features/auth/user_view_model/ticket_detail_view_model.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/core/utils/datetime_convert.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventorize_app/data/models/order_item.dart';

class TicketDetailPage extends StatefulWidget {
  final String orderId;

  const TicketDetailPage({super.key, required this.orderId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;
    final isShortScreen = screenSize.height < 600;

    return ChangeNotifierProvider(
      create: (_) => TicketDetailViewModel(
        orderRepository: OrderRepository(OrderApi(DioClient())),
      )..fetchOrderDetail(widget.orderId),
      child: Consumer<TicketDetailViewModel>(
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
            backgroundColor: AppColors.inputBackground,
            body: Column(
              children: [
                _buildTopBar(isSmallScreen, isShortScreen, context),
                Expanded(
                  child: buildMainContainer(isSmallScreen, screenSize, viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(bool isSmallScreen, bool isShortScreen, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isShortScreen ? 24 : isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        0,
      ),
      child: TopNavBar(
        title: "Chi tiết vé",
        showBackButton: true,
        backgroundColor: AppColors.inputBackground,
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, TicketDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return buildSkeleton(isSmallScreen, screenSize);
    }

    if (viewModel.order == null || viewModel.order!.orderItems.isEmpty) {
      return buildEmptyState(isSmallScreen, screenSize);
    }

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: AppColors.inputBackground,
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
              buildTicketCard(context, viewModel.order!.orderItems[0]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSkeleton(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.inputBackground,
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.88,
                height: 630,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: TicketClipper(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.whiteBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: Shimmer.fromColors(
                                  baseColor: AppColors.shimmerBase,
                                  highlightColor: AppColors.shimmerHighlight,
                                  child: Container(
                                    width: double.infinity,
                                    height: 160,
                                    color: AppColors.skeleton,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Expanded(
                                child: SingleChildScrollView(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 250),
                                    child: buildSkeletonTicketInfo(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 630 * 0.7,
                      left: 14,
                      right: 14,
                      child: HorizontalDashedLine(),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 630 * 0.7 + (630 * 0.3 - 141) / 2,
                      child: Center(
                        child: Shimmer.fromColors(
                          baseColor: AppColors.shimmerBase,
                          highlightColor: AppColors.shimmerHighlight,
                          child: Container(
                            width: 141,
                            height: 141,
                            color: AppColors.skeleton,
                          ),
                        ),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.inputBackground,
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
              SizedBox(
                height: screenSize.height / 2,
                child: Center(
                  child: Text(
                    'Không tìm thấy thông tin vé',
                    style: AppTextStyles.sectionTitle.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTicketCard(BuildContext context, OrderItem? ticket) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.88,
      height: 630,
      child: Stack(
        children: [
          ClipPath(
            clipper: TicketClipper(),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.whiteBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: ticket?.eventThumbnail ?? '',
                        imageBuilder: (context, imageProvider) => Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.shimmerBase,
                          highlightColor: AppColors.shimmerHighlight,
                          child: Container(
                            width: double.infinity,
                            height: 160,
                            color: AppColors.skeleton,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: double.infinity,
                          height: 160,
                          color: AppColors.skeleton,
                          child: const Center(child: Icon(Icons.error, color: AppColors.red)),
                        ),
                        memCacheHeight: 320,
                        memCacheWidth: 600,
                        fadeInDuration: const Duration(milliseconds: 200),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ticket != null ? buildTicketInfo(ticket) : buildSkeletonTicketInfo(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 630 * 0.7,
            left: 14,
            right: 14,
            child: HorizontalDashedLine(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 630 * 0.7 + (630 * 0.3 - 141) / 2,
            child: Center(
              child: Image.asset(
                'assets/images/qr_code.png',
                width: 141,
                height: 141,
              ),
            ),
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
  }

  Widget buildTicketInfo(OrderItem ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ticket.eventTitle ?? '',
          style: AppTextStyles.semibold.copyWith(fontSize: 20),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Loại vé: ', style: AppTextStyles.semibold),
                  TextSpan(text: ticket.ticketTitle, style: AppTextStyles.text),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 60),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Số lượng: ', style: AppTextStyles.semibold),
                  TextSpan(text: ticket.quantity.toString(), style: AppTextStyles.text),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Thời gian diễn ra:',
          style: AppTextStyles.semibold,
        ),
        const SizedBox(height: 4),
        Text(
          DateTimeConverter.formatDateRange(
            ticket.eventStartDate,
            ticket.eventEndDate,
          ),
          style: AppTextStyles.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Text(
          'Địa điểm:',
          style: AppTextStyles.semibold,
        ),
        const SizedBox(height: 4),
        Text(
          ticket.eventAddress?? '',
          style: AppTextStyles.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildSkeletonTicketInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            width: double.infinity,
            height: 48, 
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double cornerRadius = 12;
    const double notchRadius = 14;

    final double notchY = size.height * 0.7;

    final ticketPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(cornerRadius),
      ));

    final leftNotch = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, notchY), radius: notchRadius));
    final rightNotch = Path()
      ..addOval(Rect.fromCircle(center: Offset(size.width, notchY), radius: notchRadius));

    final clipped = Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, ticketPath, leftNotch),
      rightNotch,
    );

    return clipped;
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
      ..strokeWidth = 1
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HorizontalDashedLine extends StatelessWidget {
  const HorizontalDashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedLine(
      direction: Axis.horizontal,
      dashColor: AppColors.darkGrey,
      dashLength: 8,
      dashGapLength: 4,
      lineThickness: 1,
    );
  }
}