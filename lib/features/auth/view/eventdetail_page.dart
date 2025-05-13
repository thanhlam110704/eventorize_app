import 'package:eventorize_app/common/widgets/bottom_nav_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key});

  @override
  EventDetailPageState createState() => EventDetailPageState();
}

class EventDetailPageState extends State<EventDetailPage>{
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: buildMainContainer(isSmallScreen, screenSize),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black12,
          ),
          
        ],
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeaderImage(),
    const SizedBox(height: 16),
    buildEventDateTime(),
    const SizedBox(height: 8),
    buildEventTitle(),
    const SizedBox(height: 16),
    buildLocation(),
    const SizedBox(height: 16),
    buildDateRange(),
    const SizedBox(height: 8),
    buildRefundPolicy(),
    const SizedBox(height: 24),
    buildAboutSection(),
    const SizedBox(height: 24),
    buildOrganizer(),
    const SizedBox(height: 24),
    buildTicketRow(),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildHeaderImage() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.asset(
      'assets/icons/event1.png',
      fit: BoxFit.cover,
      width: double.infinity,
    ),
  );
}

Widget buildEventDateTime() {
  return Text(
    'Friday, January 10, 6:00',
    style: AppTextStyles.text.copyWith(color: Colors.red),
  );
}

Widget buildEventTitle() {
  return Text(
    'Mastering Vendor Development & The Service Provider Lifecycle',
    style: AppTextStyles.title,
  );
}

Widget buildLocation() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '53 Nguyen Co Thach, Thu Duc, Ho Chi Minh City',
              style: AppTextStyles.text,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () {},
        child: Text(
          'Show map',
          style: AppTextStyles.text.copyWith(color: AppColors.primary),
        ),
      ),
    ],
  );
}

Widget buildDateRange() {
  return Row(
    children: [
      const Icon(Icons.calendar_today_outlined, size: 20),
      const SizedBox(width: 8),
      Text(
        'Friday, Jan 10, 6:00 - Monday, Jan 13, 8:00',
        style: AppTextStyles.text,
      ),
    ],
  );
}

Widget buildRefundPolicy() {
  return Row(
    children: [
      const Icon(Icons.monetization_on_outlined, size: 20),
      const SizedBox(width: 8),
      Text('Refund policy: ', style: AppTextStyles.text),
      Text(
        'No refunds',
        style: AppTextStyles.text.copyWith(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

Widget buildAboutSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('About this event', style: AppTextStyles.title),
      const SizedBox(height: 8),
      Text(
        'The event will gather migration agencies, immigration attorneys, global service providers, regional centers, project developers and investors from across the world.',
        style: AppTextStyles.text,
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () {},
        child: Text(
          'Read more',
          style: AppTextStyles.text.copyWith(color: AppColors.primary),
        ),
      ),
    ],
  );
}

Widget buildOrganizer() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Organized by', style: AppTextStyles.title),
      const SizedBox(height: 8),
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/fpt_logo.png',
              height: 36,
              width: 36,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FPT Sofware', style: AppTextStyles.text),
              Text('22k Followers', style: AppTextStyles.text),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Follow'),
          ),
        ],
      ),
    ],
  );
}

Widget buildTicketRow() {
  return Row(
    children: [
      Text('Free', style: AppTextStyles.title),
      const Spacer(),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: const Text('Get tickets'),
      ),
    ],
  );
}

}