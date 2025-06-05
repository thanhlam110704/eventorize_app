import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:eventorize_app/common/components/bottom_nav_bar.dart';
import 'package:dotted_line/dotted_line.dart';

class TicketsDetailPage extends StatefulWidget {
  const TicketsDetailPage({super.key});

  @override
  State<TicketsDetailPage> createState() => _TicketsDetailPageState();
}

class _TicketsDetailPageState extends State<TicketsDetailPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final ScrollController _scrollController = ScrollController();
  bool _showDivider = false;

  @override
  void initState() {
    super.initState();
    _showDivider = true;
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

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TopNavBar(title: "Ticket detail", showBackButton: true),
            ),

            if (_showDivider)
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  color: AppColors.grey.withAlpha((0.5 * 255).toInt()),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withAlpha((0.6 * 255).toInt()),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: buildMainContainer(isSmallScreen, screenSize),
              ),
            ),
          ],
        ),
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
  } 

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
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
              buildTicketCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTicketCard(BuildContext context) {
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/images/event2.png',
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: 160,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildTicketInfo(),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/qr_code.png',
                        width: 141,
                        height: 141,
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

  Widget buildTicketInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mastering Vendor Development & The Service Provider...',
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
                    TextSpan(text: 'Type: ', style: AppTextStyles.semibold),
                    TextSpan(text: 'Ticket Vip', style: AppTextStyles.text),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Quantity: ', style: AppTextStyles.semibold),
                    TextSpan(text: '3', style: AppTextStyles.text),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Date and time:',
            style: AppTextStyles.semibold,
          ),
          const SizedBox(height: 4),
          Text(
            'Friday, Jan 10, 6:00 - Monday, Jan 13, 8:00',
            style: AppTextStyles.text,
          ),
          const SizedBox(height: 10),
          Text(
            'Venue:',
            style: AppTextStyles.semibold,
          ),
          const SizedBox(height: 4),
          const Text(
            '53 Nguyen Co Thach, Thu Duc, Ho Chi Minh.',
            style: AppTextStyles.text,
          ),
        ],
      ),
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
      ..color = AppColors.grey
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
      dashColor: AppColors.grey,
      dashLength: 8,
      dashGapLength: 4,
      lineThickness: 1,
    );
  }
}







