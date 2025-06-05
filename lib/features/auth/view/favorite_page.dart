import 'package:eventorize_app/common/components/bottom_nav_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  FavoritePageState createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage>{
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
              const SizedBox(height: 10),
              buildTitle(),
              const SizedBox(height: 10),
              buildEventList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text(
      'Saved',
      style: AppTextStyles.title.copyWith(fontSize: 32),
    );
  }

  Widget buildTitle() {
    return Text(
      'Events',
      style: AppTextStyles.title.copyWith(fontSize: 22),
    );
  }
  
  Widget buildEventList() {
    return Column(
      children: List.generate(4, (index) => buildEventCard()).toList(),
    );
  }

  Widget buildEventCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                child: Image.asset(
                  'assets/images/event.png',
                  height: 125,
                  width: 125,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mastering Vendor Development & The Service Provider...',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2), 
                      child: Icon(Icons.calendar_today, size: 14, color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Friday, Jan 10, 6:00 - Monday, Jan 13, 8:00',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ),
                 ],
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2), 
                      child: Icon(Icons.location_on, size: 14, color: Colors.black),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '53 Nguyen Co Thach, Thu Duc, Ho Chi Minh City',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9B9B9B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    const Text(
                      '2.9k attendees',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9B9B9B),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite, color: Colors.black,),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}