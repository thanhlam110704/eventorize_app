import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/widgets/bottom_nav_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/utils/datetime_convert.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Consumer2<SessionManager, HomeViewModel>(
      builder: (context, sessionManager, viewModel, child) {
        if (sessionManager.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ToastCustom.show(
                context: context,
                title: sessionManager.errorTitle ?? 'Error',
                description: sessionManager.errorMessage!,
                type: ToastificationType.error,
              );
              sessionManager.clearError();
              if (!sessionManager.isLoading &&
                  !sessionManager.isCheckingSession &&
                  sessionManager.user == null) {
                context.pushReplacementNamed('login');
              }
            }
          });
        }

        if (viewModel.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ToastCustom.show(
                context: context,
                title: viewModel.errorTitle ?? 'Error',
                description: viewModel.errorMessage!,
                type: ToastificationType.error,
              );
              viewModel.clearError();
            }
          });
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.whiteBackground,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: buildMainContainer(isSmallScreen, screenSize, sessionManager, viewModel),
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
                  const BottomNavBar(),
                ],
              ),
            ),
            if (sessionManager.isCheckingSession || viewModel.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(128),
                  child: const Center(
                    child: SpinKitFadingCircle(
                      color: AppColors.primary,
                      size: 50.0,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildMainContainer(
      bool isSmallScreen, Size screenSize, SessionManager sessionManager, HomeViewModel viewModel) {
    if (viewModel.isLoading) {
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
            child: buildSkeleton(),
          ),
        ),
      );
    }

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
              buildSearchHeader(),
              const SizedBox(height: 16),
              buildLocationSelector(),
              const SizedBox(height: 16),
              buildCategoryChips(),
              const SizedBox(height: 24),
              buildTrendingHeader(),
              const SizedBox(height: 16),
              buildEventList(viewModel),
            ],
          ),
        ),
      ),
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

  Widget buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSkeletonBox(double.infinity, 60),
        const SizedBox(height: 16),
        buildSkeletonBox(150, 24),
        const SizedBox(height: 16),
        buildSkeletonBox(340, 35),
        const SizedBox(height: 24),
        buildSkeletonBox(200, 24),
        const SizedBox(height: 16),
        Column(
          children: List.generate(2, (index) => Padding(
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
                      const SizedBox(height: 8),
                      buildSkeletonBox(150, 16),
                      const SizedBox(height: 8),
                      buildSkeletonBox(100, 16),
                      const SizedBox(height: 8),
                      buildSkeletonBox(80, 16),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ],
    );
  }

  Widget buildSearchHeader() {
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Image.asset('assets/icons/logo_e.png'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                Container(
                  height: 36,
                  width: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLocationSelector() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: DropdownButtonFormField<String>(
                    value: viewModel.selectedCity,
                    items: viewModel.provinces.map((province) {
                      return DropdownMenuItem(
                        value: province.name,
                        child: Text(
                          province.name ?? '',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: viewModel.isLoadingCity ? null : viewModel.setCity,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    ),
                    isExpanded: true,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    validator: (value) => value == null ? 'Please select a city' : null,
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 2.0),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    itemHeight: 48,
                    menuMaxHeight: 200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.grey,
              indent: 0,
              endIndent: 10,
            ),
          ],
        );
      },
    );
  }

  Widget buildCategoryChips() {
    final categories = ['All', 'Music', 'Today', 'Online', 'This Week'];

    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == 'All';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2176AE) : const Color(0xFFE8E1E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTrendingHeader() {
    return const Text(
      'Top Trending in Ho Chi Minh City',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget buildEventList(HomeViewModel viewModel) {
    if (viewModel.events.isEmpty && !viewModel.isLoading) {
      return const Center(
        child: Text(
          'No events found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: viewModel.events
          .asMap()
          .entries
          .map((entry) => buildEventCard(entry.value))
          .toList(),
    );
  }

  Widget buildEventCard(Event event) {
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
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.favorite_border,
                      color: Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        DateTimeConverter.formatDateRange(
                          event.startDate,
                          event.endDate,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.address ?? 'No address provided',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people,
                      size: 14,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '2.9k attendees',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
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