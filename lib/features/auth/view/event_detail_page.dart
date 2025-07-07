import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/utils/datetime_convert.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/features/auth/view_model/event_detail_view_model.dart';
import 'package:eventorize_app/common/components/event_list.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventorize_app/data/api/geocoding_service.dart';
import 'package:eventorize_app/common/components/ticket_dialog.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  EventDetailPageState createState() => EventDetailPageState();
}

class EventDetailPageState extends State<EventDetailPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  late final GeocodingService _geocodingService;
  bool isExpanded = false;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _geocodingService = GeocodingService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventDetailViewModel>(context, listen: false)
          .fetchEventDetail(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Consumer<EventDetailViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return buildSkeletonUI(
            isSmallScreen: isSmallScreen,
            screenSize: screenSize,
          );
        }

        if (viewModel.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Text(
                viewModel.errorMessage!,
                style: AppTextStyles.text.copyWith(color: Colors.red),
              ),
            ),
          );
        }

        final event = viewModel.event;
        if (event == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy sự kiện')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.whiteBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildEventBanner(event),
                  buildMainContainer(isSmallScreen, screenSize, event, viewModel),
                ],
              ),
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
              buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  Widget buildSkeletonUI({
    required bool isSmallScreen,
    required Size screenSize,
  }) {
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

    Widget buildSkeleton() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSkeletonBox(double.infinity, 200),
          Container(
            width: screenSize.width,
            color: AppColors.whiteBackground,
            padding: EdgeInsets.fromLTRB(
              isSmallScreen ? 16 : 24,
              isSmallScreen ? 16 : 24,
              isSmallScreen ? 16 : 24,
              isSmallScreen ? 24 : 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSkeletonBox(150, 16),
                    const SizedBox(height: 4),
                    buildSkeletonBox(double.infinity, 25),
                    const SizedBox(height: 16),
                    buildSkeletonBox(200, 20),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          color: AppColors.skeleton,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSkeletonBox(double.infinity, 16),
                              const SizedBox(height: 4),
                              buildSkeletonBox(100, 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          color: AppColors.skeleton,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: buildSkeletonBox(double.infinity, 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          color: AppColors.skeleton,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSkeletonBox(100, 16),
                              const SizedBox(height: 6),
                              buildSkeletonBox(80, 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    buildSkeletonBox(200, 20),
                    const SizedBox(height: 8),
                    buildSkeletonBox(double.infinity, 16),
                    const SizedBox(height: 4),
                    buildSkeletonBox(double.infinity, 16),
                    const SizedBox(height: 4),
                    buildSkeletonBox(100, 16),
                    const SizedBox(height: 32),
                    buildSkeletonBox(200, 20),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E1E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.skeleton,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildSkeletonBox(100, 16),
                                const SizedBox(height: 4),
                                buildSkeletonBox(80, 16),
                              ],
                            ),
                          ),
                          buildSkeletonBox(80, 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    buildSkeletonBox(200, 20),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(
                        2,
                        (_) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSkeletonBox(120, 120),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildSkeletonBox(double.infinity, 20),
                                    const SizedBox(height: 4),
                                    buildSkeletonBox(150, 16),
                                    const SizedBox(height: 4),
                                    buildSkeletonBox(100, 16),
                                    const SizedBox(height: 4),
                                    buildSkeletonBox(80, 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: buildSkeleton(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black12, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildSkeletonBox(300, 44),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainContainer(
      bool isSmallScreen, Size screenSize, Event event, EventDetailViewModel viewModel) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildEventTitleAndDate(event),
              buildEventInformation(event),
              const SizedBox(height: 32),
              buildEventDescription(event),
              const SizedBox(height: 32),
              buildOrganizerSection(),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Các sự kiện liên quan",
                    style: AppTextStyles.bold.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Consumer<EventDetailViewModel>(
                    builder: (context, viewModel, _) => EventList(
                      events: viewModel.relatedEvents,
                      isLoading: viewModel.isLoadingRelated,
                      totalEvents: viewModel.relatedEvents.length,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventBanner(Event event) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: event.thumbnail ?? 'https://via.placeholder.com/600x200',
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: TopNavBar(
            title: '',
            showBackButton: true,
          ),
        ),
      ],
    );
  }

  Widget buildEventTitleAndDate(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateTimeConverter.formatDateTime(event.startDate),
          style: AppTextStyles.medium.copyWith(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          event.title,
          style: AppTextStyles.bold.copyWith(
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  Widget buildEventInformation(Event event) {
    return MapWidget(event: event, geocodingService: _geocodingService);
  }

  Widget buildEventDescription(Event event) {
    final description = event.description ?? 'Chưa có mô tả';
    final isDescriptionLong = (description.split('\n').length > 3 ||
        description.length > 100); 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mô tả sự kiện",
          style: AppTextStyles.bold.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyles.text.copyWith(
            fontSize: 16,
            color: const Color(0xFF9B9B9B),
          ),
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (isDescriptionLong) ...[
          const SizedBox(height: 9),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? "Thu gọn" : "Đọc thêm",
              style: AppTextStyles.medium.copyWith(
                color: AppColors.linkBlue,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildOrganizerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          "Tổ chức bởi",
          style: AppTextStyles.bold.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E1E1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/images/fpt.png"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FPT Software",
                      style: AppTextStyles.medium.copyWith(fontSize: 16),
                    ),
                    Text(
                      "fptsoftware.com",
                      style: AppTextStyles.text.copyWith(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF3659E3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  "Theo dõi",
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC0303),
              foregroundColor: Colors.white,
              minimumSize: const Size(300, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    final viewModel = Provider.of<EventDetailViewModel>(context, listen: false);
                    await viewModel.fetchEventTickets(widget.eventId);
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => TicketDialog(eventId: widget.eventId),
                    );
                    setState(() => _isLoading = false);
                  },
            child: _isLoading
                ? const SpinKitFadingCircle(
                    color: Colors.white,
                    size: 24.0,
                  )
                : const Text(
                    "Đặt vé ngay",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  final Event event;
  final GeocodingService geocodingService;

  const MapWidget({super.key, required this.event, required this.geocodingService});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool isMapVisible = false;
  LatLng? location;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadCachedLocation();
  }

  Future<void> _loadCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'location_${widget.event.id}';
    final cachedLat = prefs.getDouble('${cacheKey}_lat');
    final cachedLng = prefs.getDouble('${cacheKey}_lng');

    if (cachedLat != null && cachedLng != null) {
      setState(() {
        location = LatLng(cachedLat, cachedLng);
      });
    }
  }

  Future<void> _fetchLocation() async {
    if (isLoadingLocation) return;
    setState(() {
      isLoadingLocation = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'location_${widget.event.id}';
    final cachedLat = prefs.getDouble('${cacheKey}_lat');
    final cachedLng = prefs.getDouble('${cacheKey}_lng');

    if (cachedLat != null && cachedLng != null) {
      setState(() {
        location = LatLng(cachedLat, cachedLng);
        isLoadingLocation = false;
      });
      return;
    }

    try {
      final address = widget.event.address;
      if (address == null || address.isEmpty) {
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      final newLocation = await widget.geocodingService.getCoordinatesFromAddress(address);
      if (newLocation != null) {
        await prefs.setDouble('${cacheKey}_lat', newLocation.latitude);
        await prefs.setDouble('${cacheKey}_lng', newLocation.longitude);
        setState(() {
          location = newLocation;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xác định vị trí trên bản đồ'),
          ),
        );
      }
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thông tin sự kiện",
            style: AppTextStyles.bold.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.address ?? 'Không có địa chỉ',
                      style: AppTextStyles.text.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: isLoadingLocation
                          ? null
                          : () async {
                              if (location == null) {
                                await _fetchLocation();
                              }
                              if (location != null) {
                                setState(() {
                                  isMapVisible = !isMapVisible;
                                });
                              }
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLoadingLocation ? "Đang tải..." : "Hiển thị bản đồ",
                            style: AppTextStyles.medium.copyWith(
                              color: AppColors.linkBlue,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: isMapVisible ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              MdiIcons.chevronDown,
                              size: 15,
                              color: AppColors.linkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isMapVisible && location != null)
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 200,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: location!,
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  userAgentPackageName: 'com.example.eventorize',
                                  maxNativeZoom: 18,
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: location!,
                                      width: 36,
                                      height: 36,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateTimeConverter.formatDateRange(widget.event.startDate, widget.event.endDate),
                  style: AppTextStyles.text.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.attach_money, size: 24),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chính sách hoàn vé",
                    style: AppTextStyles.text.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Không hoàn vé",
                    style: AppTextStyles.text.copyWith(
                      fontSize: 14,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}