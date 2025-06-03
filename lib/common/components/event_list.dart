import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/utils/datetime_convert.dart';
import 'package:eventorize_app/data/models/event.dart';

class EventList extends StatelessWidget {
  final List<Event> events;
  final bool isLoading;
  final int totalEvents;

  const EventList({
    super.key,
    required this.events,
    required this.isLoading,
    required this.totalEvents,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: events.isEmpty && !isLoading && totalEvents == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/no_data.svg',
                    width: 102,
                    height: 102,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No data',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: events.map((event) => EventCard(event: event)).toList(),
            ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

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
                borderRadius: BorderRadius.circular(5),
                child: CachedNetworkImage(
                  imageUrl: event.thumbnail ?? '',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.shimmerBase,
                    highlightColor: AppColors.shimmerHighlight,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.skeleton,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.event, size: 40, color: Colors.grey),
                  ),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.favorite_border, color: Colors.black),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        DateTimeConverter.formatDateRange(event.startDate, event.endDate),
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.address ?? 'No address provided',
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      '2.9k attendees',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                    ),
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