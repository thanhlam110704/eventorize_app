import 'package:dotted_line/dotted_line.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/common/components/bottom_nav_bar.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  TicketsPageState createState() => TicketsPageState();
}

class TicketsPageState extends State<TicketsPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: buildMainContainer(isSmallScreen, screenSize),
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
              const SizedBox(height: 20),
              buildTicketList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text(
      'Tickets',
      style: AppTextStyles.bold.copyWith(fontSize: 30),
    );
  }

  Widget buildTicketList() {
    final List<int> ticketCount = [1, 2, 3];

    return Column(
      children: ticketCount.map((_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20), 
          child: buildTicketCard(),
        );
      }).toList(),
    );
  }

  Widget buildTicketCard() {
    return SizedBox(
      width: 360, 
      height: 170,
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
                            'Mastering Vendor Development & The Service Provider...',
                            style: AppTextStyles.semibold.copyWith(fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Friday, Jan 10, 6:00 - Monday, Jan 13, 8:00',
                            style: AppTextStyles.medium.copyWith(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Type: ',style: AppTextStyles.semibold.copyWith(fontSize: 13)),
                              Text('Ticket Vip',style: AppTextStyles.text.copyWith(fontSize: 13)),

                              const SizedBox(width: 30),

                              Text('Quantity: ',style: AppTextStyles.semibold.copyWith(fontSize: 13)),
                              Text('3',style: AppTextStyles.text.copyWith(fontSize: 13)),
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
        return Positioned(
          left: 0, 
          top: radius, 
          child: RotatedBox(
            quarterTurns: 1,
            child: DottedLine(
              dashColor: Colors.grey,
              dashLength: 8,
              dashGapLength: 4,
              lineThickness: 1,
              lineLength: dashHeight, 
            ),
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
      ..color = AppColors.grey 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}





