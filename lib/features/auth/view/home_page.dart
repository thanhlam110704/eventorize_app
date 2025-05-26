import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Consumer2<SessionManager, HomeViewModel>(
          builder: (context, sessionManager, viewModel, child) {
            // Handle session errors
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

            // Handle event errors
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
                SingleChildScrollView(
                  child: buildMainContainer(isSmallScreen, screenSize, sessionManager, viewModel),
                ),
                if (sessionManager.isCheckingSession || viewModel.isLoading)
                  Container(
                    color: Colors.black.withAlpha(128),
                    child: const Center(
                      child: SpinKitFadingCircle(
                        color: AppColors.primary,
                        size: 50.0,
                      ),
                    ),
                  ),
              ],
            );
          },
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
    );
  }

  Widget buildMainContainer(
      bool isSmallScreen, Size screenSize, SessionManager sessionManager, HomeViewModel viewModel) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 4),
            DropdownButton<String>(
              value: 'Ho Chi Minh City',
              underline: const SizedBox(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              items: <String>[
                'Ho Chi Minh City',
                'Hanoi',
                'Da Nang',
                'Can Tho',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Handle location change
              },
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          height: 1,
          width: 150,
          color: Colors.blue,
        ),
      ],
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
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                borderRadius: BorderRadius.circular(8),
                child: event.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: event.thumbnail!,
                        height: 107,
                        width: 107,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/event.png',
                          height: 107,
                          width: 107,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/event.png',
                        height: 107,
                        width: 107,
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
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        DateTimeConverter.formatDateRange(
                          event.startDate,
                          event.endDate,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.address ?? 'No address provided',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      '2.9k attendees', 
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite_border),
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