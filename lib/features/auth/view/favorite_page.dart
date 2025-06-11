import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/bottom_nav_bar.dart';
import 'package:eventorize_app/common/components/event_list.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/view_model/favorite_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

    return Consumer2<SessionManager, FavoriteViewModel>(
      builder: (context, sessionManager, viewModel, _) {
        _handleSessionErrors(context, sessionManager);
        _handleViewModelErrors(context, viewModel);

        if (sessionManager.isCheckingSession) {
          return Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: buildLoadingOverlay(),
          );
        }

        if (!sessionManager.isLoading &&
            !sessionManager.isCheckingSession &&
            sessionManager.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.pushReplacementNamed('login');
            }
          });
          return Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: buildLoadingOverlay(),
          );
        }

        if (!viewModel.isDataLoaded) {
          return buildSkeletonUI(
            isSmallScreen: isSmallScreen,
            screenSize: screenSize,
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.whiteBackground,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: buildMainContainer(
                    isSmallScreen: isSmallScreen,
                    screenSize: screenSize,
                    viewModel: viewModel,
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
            ),
            if (viewModel.isLoading && !viewModel.isInitialLoad)
              buildLoadingOverlay(),
          ],
        );
      },
    );
  }

  void _handleSessionErrors(BuildContext context, SessionManager sessionManager) {
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
  }

  void _handleViewModelErrors(BuildContext context, FavoriteViewModel viewModel) {
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
      'Favorite',
      style: AppTextStyles.title,
    );
  }

  Widget buildTitle() {
    return Text(
      'Events',
      style: AppTextStyles.title.copyWith(fontSize: 22),
    );
  }

  Widget buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(128),
        child: const Center(
          child: SpinKitFadingCircle(
            color: AppColors.primary,
            size: 50.0,
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