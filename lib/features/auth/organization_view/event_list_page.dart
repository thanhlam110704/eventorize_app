import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view_model/event_list_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/edit_event_view_model.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/custom_event_menu.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

final getIt = GetIt.instance;

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  EventListPageState createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasShownUpdateToast = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = getIt<EventListViewModel>();
      final sessionManager = getIt<SessionManager>();
      if (sessionManager.user != null) {
        viewModel.fetchEvents(
          organizerId: sessionManager.selectedOrganizerId!,
          page: 1,
          limit: 20,
          search: "",
        );
      }
    });

    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        final viewModel = getIt<EventListViewModel>();
        final sessionManager = getIt<SessionManager>();
        if (sessionManager.user != null) {
          viewModel.fetchEvents(
            organizerId: sessionManager.selectedOrganizerId!,
            page: 1,
            limit: 20,
            search: _searchController.text.trim(),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
        onSearchChanged: (query) {
          _searchController.text = query;
        },
      ),
      drawer: const CustomDrawer(currentPage: AppPage.eventList),
      backgroundColor: AppColors.whiteBackground,
      floatingActionButton: Consumer<SessionManager>(
        builder: (context, sessionManager, _) {
          return SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              onPressed: () {
                context.push('/create-event/${sessionManager.selectedOrganizerId}');
              },
              backgroundColor: const Color(0xFF194185),
              elevation: 6,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(30, 40),
      body: SafeArea(
        child: ChangeNotifierProvider<EventListViewModel>.value(
          value: getIt<EventListViewModel>(),
          child: Consumer<EventListViewModel>(
            builder: (context, viewModel, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && viewModel.errorMessage != null) {
                  ToastCustom.show(
                    context: context,
                    title: viewModel.errorTitle ?? 'Lỗi',
                    description: viewModel.errorMessage!,
                    type: ToastificationType.error,
                  );
                  viewModel.clearError();
                }
                if (mounted && Provider.of<EditEventViewModel>(context, listen: false).isUpdateSuccessful && !_hasShownUpdateToast) {
                  _hasShownUpdateToast = true;
                  Provider.of<EditEventViewModel>(context, listen: false).clearUpdateStatus();
                  viewModel.fetchEvents(
                    organizerId: getIt<SessionManager>().selectedOrganizerId!,
                    page: 1,
                    limit: 20,
                    search: _searchController.text.trim(),
                  );
                }
              });

              return buildMainContainer(
                MediaQuery.of(context).size.width <= smallScreenThreshold,
                MediaQuery.of(context).size,
                viewModel,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant EventListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasShownUpdateToast = false;
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
      child: viewModel.events.isEmpty && !viewModel.isLoading
          ? buildEventList(viewModel)
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        buildEventList(viewModel),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildEventList(EventListViewModel viewModel) {
    if (viewModel.isLoading) {
      return Column(
        children: List.generate(
          7,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: buildSkeletonCard(),
          ),
        ),
      );
    }
    if (viewModel.events.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/no_data.svg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Container(
                width: 100,
                height: 100,
                color: AppColors.shimmerBase,
                child: const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không có sự kiện',
              style: AppTextStyles.text,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: UniqueKey(),
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

  Widget buildSkeletonCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 45),
      ],
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${event.startDate.day}/${event.startDate.month}/${event.startDate.year} - ${event.endDate.day}/${event.endDate.month}/${event.endDate.year}',
                          style: AppTextStyles.medium.copyWith(fontSize: 12, color: AppColors.grey),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          event.isOnline ? 'Trực tuyến' : 'Trực tiếp',
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
            const SizedBox(width: 45),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
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
        ),
      ],
    );
  }

  void showEventMenu(BuildContext context, Offset position, String eventId) {
    OverlayEntry? entry;

    void closeMenu(BuildContext dialogContext) {
      if (entry != null) {
        entry!.remove();
        entry = null;
      }
      Navigator.of(dialogContext).pop();
    }

    entry = OverlayEntry(
      builder: (dialogContext) => Positioned(
        top: position.dy + 40,
        left: position.dx - 80,
        child: Material(
          color: Colors.transparent,
          child: CustomEventMenu(
            onEdit: () {
              closeMenu(dialogContext);
              _hasShownUpdateToast = false;
              context.push('/edit-event/$eventId');
            },
            onDelete: () async {
              closeMenu(dialogContext);
              final viewModel = getIt<EventListViewModel>();
              await viewModel.deleteEvent(eventId);
              if (!context.mounted) return;
              if (viewModel.errorMessage == null) {
                ToastCustom.show(
                  context: context,
                  title: 'Thành công',
                  description: 'Xóa sự kiện thành công',
                  type: ToastificationType.success,
                );
              } else {
                ToastCustom.show(
                  context: context,
                  title: viewModel.errorTitle ?? 'Lỗi',
                  description: viewModel.errorMessage!,
                  type: ToastificationType.error,
                );
              }
            },
            onTickets: () {
              closeMenu(dialogContext);
              context.push('/ticket-list/$eventId');
            },
            showTickets: true,
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(entry!);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          closeMenu(dialogContext);
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double rightPadding;
  final double bottomPadding;

  const CustomFloatingActionButtonLocation(this.rightPadding, this.bottomPadding);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double x = scaffoldGeometry.scaffoldSize.width - rightPadding - scaffoldGeometry.floatingActionButtonSize.width;
    final double y = scaffoldGeometry.scaffoldSize.height - bottomPadding - scaffoldGeometry.floatingActionButtonSize.height;
    return Offset(x, y);
  }
}