import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/custom_event_menu.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view_model/ticket_list_view_model.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/data/models/ticket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

final getIt = GetIt.instance;

class TicketListPage extends StatefulWidget {
  final String eventId;

  const TicketListPage({super.key, required this.eventId});

  @override
  TicketListPageState createState() => TicketListPageState();
}

class TicketListPageState extends State<TicketListPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = getIt<TicketListViewModel>();
      viewModel.fetchTickets(
        eventId: widget.eventId,
        page: 1,
        limit: 20,
        search: "",
      );
    });

    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        final viewModel = getIt<TicketListViewModel>();
        viewModel.fetchTickets(
          eventId: widget.eventId,
          page: 1,
          limit: 20,
          search: _searchController.text.trim(),
        );
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      key: _scaffoldKey,
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Danh sách vé',
        actionIcon: Icons.search,
        onLeadingPressed: () {
          context.pop();
        },
        onSearchChanged: (query) {
          _searchController.text = query;
        },
      ),
      drawer: const CustomDrawer(currentPage: AppPage.ticketList),
      backgroundColor: AppColors.whiteBackground,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/create-ticket/${widget.eventId}');
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
      ),
      floatingActionButtonLocation: const CustomFloatingActionButtonLocation(30, 40),
      body: SafeArea(
        child: ChangeNotifierProvider<TicketListViewModel>.value(
          value: getIt<TicketListViewModel>(),
          child: Consumer<TicketListViewModel>(
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
              });

              return buildMainContainer(isSmallScreen, screenSize, viewModel);
            },
          ),
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, TicketListViewModel viewModel) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: viewModel.tickets.isEmpty && !viewModel.isLoading
          ? buildTicketList(viewModel)
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTicketList(viewModel),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildTicketList(TicketListViewModel viewModel) {
    if (viewModel.isLoading) {
      return Column(
        children: List.generate(
          7,
          (index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: buildSkeletonCard(),
          ),
        ),
      );
    }
    if (viewModel.tickets.isEmpty) {
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
                color: AppColors.grey.withValues(alpha: 0.5),
                child: const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không có vé',
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
      itemCount: viewModel.tickets.length,
      itemBuilder: (context, index) {
        final ticket = viewModel.tickets[index];
        return Column(
          children: [
            buildTicketItem(index, ticket),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
          ],
        );
      },
    );
  }

  Widget buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            color: AppColors.skeleton,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  color: AppColors.skeleton,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      color: AppColors.skeleton,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            color: AppColors.skeleton,
          ),
        ],
      ),
    );
  }

  Widget buildTicketItem(int index, Ticket ticket) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: AppTextStyles.semibold,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          ticket.price == 0 ? 'Miễn phí' : '${ticket.price} VND',
                          style: AppTextStyles.text.copyWith(color: Colors.red, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Số lượng: ${ticket.quantity}',
                          style: AppTextStyles.text.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                  showEventMenu(context, position, ticket);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEventMenu(BuildContext context, Offset position, Ticket ticket) {
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
              context.push('/edit-ticket/${ticket.eventId}/${ticket.id}');
            },
            onDelete: () async {
              closeMenu(dialogContext);
              final viewModel = getIt<TicketListViewModel>();
              await viewModel.deleteTicket(ticket.id);
              if (!context.mounted) return;
              if (viewModel.errorMessage == null) {
                ToastCustom.show(
                  context: context,
                  title: 'Thành công',
                  description: 'Xóa vé thành công',
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
            onTickets: () {},
            showTickets: false,
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