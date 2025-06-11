import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/utils/datetime_convert.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/repositories/favorite_repository.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/favorite_view_model.dart';

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
    final sessionManager = Provider.of<SessionManager>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context, listen: false);

    if (sessionManager.user == null) {
      return const Center(
        child: Text(
          'Please log in to view events',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (events.isEmpty && totalEvents == 0) {
      return Center(
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
              'No events found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Column(
        children: events.map((event) {
          final isFavoritePage = favoriteViewModel.events.contains(event);
          return EventCard(
            event: event,
            isFavorited: isFavoritePage ? true : homeViewModel.favoriteIdMap.containsKey(event.id),
            favoriteId: isFavoritePage ? event.id : homeViewModel.favoriteIdMap[event.id],
          );
        }).toList(),
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final Event event;
  final bool isFavorited;
  final String? favoriteId;

  const EventCard({
    super.key,
    required this.event,
    required this.isFavorited,
    this.favoriteId,
  });

  @override
  EventCardState createState() => EventCardState();
}

class EventCardState extends State<EventCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late bool _isFavorited;
  late String? _favoriteId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
    _favoriteId = widget.favoriteId;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorited != widget.isFavorited || oldWidget.favoriteId != widget.favoriteId) {
      setState(() {
        _isFavorited = widget.isFavorited;
        _favoriteId = widget.favoriteId;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final favoriteRepository = Provider.of<FavoriteRepository>(context, listen: false);
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context, listen: false);
    final userId = sessionManager.user?.id;

    setState(() {
      _isProcessing = true;
      _isFavorited = !_isFavorited;
    });

    await _animationController.forward();
    await _animationController.reverse();

    if (userId == null) {
      if (mounted) {
        ToastCustom.show(
          context: context,
          title: 'Error',
          description: 'User not logged in',
          type: ToastificationType.error,
        );
        setState(() {
          _isFavorited = widget.isFavorited;
          _favoriteId = widget.favoriteId;
          _isProcessing = false;
        });
      }
      return;
    }

    if (widget.event.id.isEmpty) {
      if (mounted) {
        ToastCustom.show(
          context: context,
          title: 'Error',
          description: 'Invalid event ID',
          type: ToastificationType.error,
        );
        setState(() {
          _isFavorited = widget.isFavorited;
          _favoriteId = widget.favoriteId;
          _isProcessing = false;
        });
      }
      return;
    }

    try {
      if (_isFavorited) {
        final favorite = await favoriteRepository.create(eventId: widget.event.id);
        if (mounted) {
          setState(() {
            _favoriteId = favorite.id;
            _isProcessing = false;
          });
          ToastCustom.show(
            context: context,
            title: 'Success',
            description: 'Event added to favorites',
            type: ToastificationType.success,
          );
        }
      } else {
        if (_favoriteId == null) {
          if (mounted) {
            ToastCustom.show(
              context: context,
              title: 'Error',
              description: 'Favorite ID not found',
              type: ToastificationType.error,
            );
            setState(() {
              _isFavorited = widget.isFavorited;
              _favoriteId = widget.favoriteId;
              _isProcessing = false;
            });
          }
          return;
        }
        await favoriteRepository.delete(_favoriteId!);
        if (mounted) {
          setState(() {
            _favoriteId = null;
            _isProcessing = false;
          });
          ToastCustom.show(
            context: context,
            title: 'Success',
            description: 'Event removed from favorites',
            type: ToastificationType.success,
          );
        }
      }
      await homeViewModel.fetchEvents(page: 1, limit: 10, search: homeViewModel.selectedCity);
      await favoriteViewModel.refreshFavorites();
    } catch (e) {
      if (mounted) {
        ToastCustom.show(
          context: context,
          title: 'Error',
          description: e.toString().replaceFirst('Exception: ', ''),
          type: ToastificationType.error,
        );
        setState(() {
          _isFavorited = widget.isFavorited;
          _favoriteId = widget.favoriteId;
          _isProcessing = false;
        });
      }
    }
  }

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
                  imageUrl: widget.event.thumbnail ?? '',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(5),
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
                        widget.event.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
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
                        DateTimeConverter.formatDateRange(widget.event.startDate, widget.event.endDate),
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
                        widget.event.address ?? 'No address provided',
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