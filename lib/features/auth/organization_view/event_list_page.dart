import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view_model/event_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/custom_event_menu.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  EventListPageState createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final sessionManager = context.read<SessionManager>();
        if (sessionManager.selectedOrganizerId == null) {
          ToastCustom.show(
            context: context,
            title: 'Lỗi',
            description: 'Vui lòng chọn một nhà tổ chức trước',
            type: ToastificationType.error,
          );
          context.go('/select-org');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: TopNavOrgBar(
        leadingIcon: Icons.menu,
        onLeadingPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        title: 'Danh sách sự kiện',
        actionIcon: Icons.search,
        onActionPressed: () {},
      ),
      drawer: const CustomDrawer(currentPage: AppPage.eventList),
      backgroundColor: AppColors.whiteBackground,
      floatingActionButton: Consumer<SessionManager>(
        builder: (context, sessionManager, _) {
          return FloatingActionButton(
            onPressed: () {
              context.go('/create-event/${sessionManager.selectedOrganizerId}');
            },
            backgroundColor: const Color(0xFF194185),
            elevation: 6,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          );
        },
      ),
      body: SafeArea(
        child: Consumer<EventListViewModel>(
          builder: (context, viewModel, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && viewModel.errorMessage != null) {
                ToastCustom.show(
                  context: context,
                  title: viewModel.errorTitle ?? 'Error',
                  description: viewModel.errorMessage!,
                  type: ToastificationType.error,
                );
                viewModel.clearError();
              }
            });

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: buildMainContainer(
                MediaQuery.of(context).size.width <= smallScreenThreshold,
                MediaQuery.of(context).size,
                viewModel,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, EventListViewModel viewModel) {
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
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFilterBar(),
                const SizedBox(height: 16),
                buildEventList(viewModel),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilterBar() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tất cả',
            style: AppTextStyles.text.copyWith(color: AppColors.linkBlue),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.arrow_drop_down, color: AppColors.linkBlue, size: 20),
        ],
      ),
    );
  }

  Widget buildEventList(EventListViewModel viewModel) {
    if (viewModel.events.isEmpty) {
      return const Center(
        child: Text(
          'Không có sự kiện nào',
          style: AppTextStyles.text,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.events.length,
      itemBuilder: (context, index) {
        final event = viewModel.events[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: buildEventCard(event),
        );
      },
    );
  }

  Widget buildEventCard(Event event) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: event.thumbnail != null
                        ? Image.network(
                            event.thumbnail!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: AppColors.grey,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: AppColors.grey,
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: AppTextStyles.semibold,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${event.startDate.day}/${event.startDate.month}/${event.startDate.year} - ${event.endDate.day}/${event.endDate.month}/${event.endDate.year}',
                          style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.grey),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          event.isOnline ? 'Online' : 'Offline',
                          style: AppTextStyles.text.copyWith(
                            fontSize: 12,
                            color: event.isOnline ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onPressed: () {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final position = box.localToGlobal(Offset.zero);
                showEventMenu(context, position, event.id);
              },
            ),
          ),
        ),
      ],
    );
  }

  void showEventMenu(BuildContext context, Offset position, String eventId) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + 40,
        left: position.dx - 80,
        child: Material(
          color: Colors.transparent,
          child: CustomEventMenu(
            onEdit: () {
              context.go('/edit-event/$eventId');
            },
            onDelete: () {
              // Delete action placeholder
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (_) => GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const SizedBox.expand(),
        ),
      ).then((_) => entry.remove());
    });
  }
}