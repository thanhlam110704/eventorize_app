import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';

class EventCardList extends StatelessWidget {
  final int itemCount;

  const EventCardList({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => const EventCard()).toList(),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                    color: Color(0xFFE8E1E1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Free',
                    style: AppTextStyles.medium.copyWith(fontSize: 16, color: Color(0xFFEC0303)),
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
                  style: AppTextStyles.semibold.copyWith( 
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.calendar_today, size: 14, color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Friday, Jan 10, 6:00 - Monday, Jan 13, 8:00',
                        style: AppTextStyles.medium.copyWith(fontSize: 12,color: Color(0xFF9B9B9B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on, size: 14, color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '53 Nguyen Co Thach, Thu Duc, Ho Chi Minh City',
                        style: AppTextStyles.medium.copyWith(fontSize: 12,color: Color(0xFF9B9B9B)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      '2.9k attendees',
                      style: AppTextStyles.medium.copyWith(fontSize: 12,color: Color(0xFF9B9B9B)),
                    ),
                    Spacer(),
                    Icon(Icons.favorite_border),
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
