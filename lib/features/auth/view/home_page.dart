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
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];
  final List<String> _suggestions = [
    'Music Festival',
    'Art Exhibition',
    'Tech Conference',
    'Food Fair',
    'Charity Run'
  ];
  final GlobalKey _searchContainerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _addRecentSearch(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = _searchContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return OverlayEntry(builder: (_) => const SizedBox.shrink());

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final filteredSuggestions = _suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 8,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_recentSearches.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  ..._recentSearches.map((search) => ListTile(
                        leading: const Icon(Icons.history, color: AppColors.darkGrey),
                        title: Text(
                          search,
                          style: const TextStyle(color: AppColors.darkGrey),
                        ),
                        tileColor: _selectedItem == search ? Colors.blue[200] : null,
                        onTap: () {
                          setState(() {
                            _selectedItem = search;
                          });
                          _searchController.text = search;
                          _addRecentSearch(search);
                          _searchFocusNode.unfocus();
                        },
                      )),
                ],
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
                ...filteredSuggestions.map((suggestion) => ListTile(
                      leading: const Icon(Icons.search, color: AppColors.darkGrey),
                      title: Text(
                        suggestion,
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                      tileColor: _selectedItem == suggestion ? Colors.blue[200] : null,
                      onTap: () {
                        setState(() {
                          _selectedItem = suggestion;
                        });
                        _searchController.text = suggestion;
                        _addRecentSearch(suggestion);
                        _searchFocusNode.unfocus();
                      },
                    )),
                if (filteredSuggestions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No suggestions found',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.width <= 640;

    return Consumer2<SessionManager, HomeViewModel>(
      builder: (context, sessionManager, viewModel, _) {
        _handleSessionErrors(context, sessionManager);
        _handleViewModelErrors(context, viewModel);

        if (sessionManager.isCheckingSession) {
          return Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: _buildLoadingOverlay(),
          );
        }

        if (!sessionManager.isLoading && !sessionManager.isCheckingSession && sessionManager.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacementNamed('login');
          });
          return Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: _buildLoadingOverlay(),
          );
        }

        if (!viewModel.isDataLoaded) {
          return _buildSkeletonUI(isSmallScreen, screenSize);
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.whiteBackground,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: _buildMainContainer(isSmallScreen, screenSize, sessionManager, viewModel),
                ),
              ),
              bottomNavigationBar: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: 0.5, thickness: 0.5, color: AppColors.grey),
                  BottomNavBar(),
                ],
              ),
            ),
            if (viewModel.isLoading && !viewModel.isInitialLoad)
              _buildLoadingOverlay(),
          ],
        );
      },
    );
  }

  void _handleSessionErrors(BuildContext context, SessionManager sessionManager) {
    if (sessionManager.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastCustom.show(
          context: context,
          title: sessionManager.errorTitle ?? 'Error',
          description: sessionManager.errorMessage!,
          type: ToastificationType.error,
        );
        sessionManager.clearError();
        if (!sessionManager.isLoading && !sessionManager.isCheckingSession && sessionManager.user == null) {
          context.pushReplacementNamed('login');
        }
      });
    }
  }

  void _handleViewModelErrors(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastCustom.show(
          context: context,
          title: viewModel.errorTitle ?? 'Error',
          description: viewModel.errorMessage!,
          type: ToastificationType.error,
        );
        viewModel.clearError();
      });
    }
  }

  Widget _buildLoadingOverlay() {
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

  Widget _buildSkeletonUI(bool isSmallScreen, Size screenSize) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: _buildSkeletonContainer(isSmallScreen, screenSize),
        ),
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 0.5, thickness: 0.5, color: AppColors.grey),
          BottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildSkeletonContainer(bool isSmallScreen, Size screenSize) {
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
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildSkeleton(),
        ),
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height) {
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

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchHeader(),
        const SizedBox(height: 16),
        _buildSkeletonBox(176, 48),
        const SizedBox(height: 16),
        _buildSkeletonBox(double.infinity, 35),
        const SizedBox(height: 24),
        _buildSkeletonBox(200, 20),
        const SizedBox(height: 16),
        Column(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonBox(120, 120),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonBox(double.infinity, 20),
                        const SizedBox(height: 4),
                        _buildSkeletonBox(150, 16),
                        const SizedBox(height: 4),
                        _buildSkeletonBox(100, 16),
                        const SizedBox(height: 4),
                        _buildSkeletonBox(80, 16),
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

  Widget _buildMainContainer(
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
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchHeader(),
              const SizedBox(height: 16),
              _buildLocationSelector(viewModel),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              _buildTrendingHeader(),
              const SizedBox(height: 16),
              _buildEventList(viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final bool isSearchActive = _searchFocusNode.hasFocus;

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
            key: _searchContainerKey,
            height: 44,
            decoration: BoxDecoration(
              color: isSearchActive ? Colors.white : const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSearchActive ? AppColors.darkGrey : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Icon(
                  Icons.search,
                  color: isSearchActive ? AppColors.darkGrey : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSearchActive ? AppColors.darkGrey : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: TextStyle(
                        color: isSearchActive ? AppColors.darkGrey : Colors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: (value) {
                      _addRecentSearch(value);
                      _searchFocusNode.unfocus();
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_searchController.text.isNotEmpty) {
                      _addRecentSearch(_searchController.text);
                      _searchFocusNode.unfocus();
                    }
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 24),
            const SizedBox(width: 2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: viewModel.provinces.isEmpty
                  ? const SizedBox.shrink()
                  : DropdownButtonFormField<String>(
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
                      onChanged: viewModel.isLoading ? null : (value) => viewModel.setCity(value),
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
                        child: Icon(Icons.arrow_drop_down, color: Colors.blue, size: 24),
                      ),
                      itemHeight: 48,
                      menuMaxHeight: 200,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        const Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.grey,
          indent: 0,
          endIndent: 190,
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    const categories = ['All', 'Music', 'Today', 'Online', 'This Week'];
    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final cat = categories[index];
          final isSelected = cat == 'All';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2176AE) : const Color(0xFFE8E1E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              cat,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingHeader() {
    return Text(
      'Top Trending Event In City',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEventList(HomeViewModel viewModel) {
    return SizedBox(
      height: 300,
      child: viewModel.events.isEmpty && !viewModel.isLoading && viewModel.totalEvents == 0
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
              children: viewModel.events.map(_buildEventCard).toList(),
            ),
    );
  }

  Widget _buildEventCard(Event event) {
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