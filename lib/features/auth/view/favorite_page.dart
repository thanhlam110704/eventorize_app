import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/bottom_nav_bar.dart';
import 'package:eventorize_app/common/components/event_list.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/view_model/favorite_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  FavoritePageState createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Consumer<FavoriteViewModel>(
      builder: (context, viewModel, _) {
        _handleViewModelErrors(context, viewModel);

        if (viewModel.isInitialLoad || !viewModel.isDataLoaded) {
          return buildSkeletonUI(
            isSmallScreen: isSmallScreen,
            screenSize: screenSize,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.whiteBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              child: viewModel.events.isEmpty
                  ? buildEmptyState(context, isSmallScreen, screenSize)
                  : buildMainContainer(
                      isSmallScreen: isSmallScreen,
                      viewModel: viewModel,
                      screenSize: screenSize,
                    ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: 0.5,
                thickness: 0.5,
                color: AppColors.grey,
              ),
              const BottomNavBar(),
            ],
          ),
        );
      },
    );
  }

  void _handleViewModelErrors(BuildContext context, FavoriteViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ToastCustom.show(
            context: context,
            title: viewModel.errorTitle ?? 'Lỗi',
            description: viewModel.errorMessage!,
            type: ToastificationType.error,
          );
          viewModel.clearError();
        }
      });
    }
  }

  Widget buildMainContainer({
    required bool isSmallScreen,
    required Size screenSize,
    required FavoriteViewModel viewModel,
  }) {
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
              EventList(
                events: viewModel.events,
                isLoading: viewModel.isLoading,
                totalEvents: viewModel.totalEvents,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text(
      'Yêu thích',
      style: AppTextStyles.title,
    );
  }

  Widget buildTitle() {
    return Text(
      'Sự kiện',
      style: AppTextStyles.title.copyWith(fontSize: 22),
    );
  }

  Widget buildEmptyState(BuildContext context, bool isSmallScreen, Size screenSize) {
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
              const SizedBox(height: 30),
              SizedBox(
                height: screenSize.height / 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          'Lưu sự kiện yêu thích của bạn',
                          style: AppTextStyles.sectionTitle.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
                          context.goNamed('home');
                          homeViewModel.fetchEvents(
                            page: 1,
                            limit: 10,
                            city: homeViewModel.selectedCity,
                            isFromNavigation: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Khám phá điều thú vị!',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          buildHeader(),
          const SizedBox(height: 10),
          buildTitle(),
          const SizedBox(height: 10),
          Column(
            children: List.generate(
              4,
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
      );
    }

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
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
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.grey,
          ),
          const BottomNavBar(),
        ],
      ),
    );
  }
}