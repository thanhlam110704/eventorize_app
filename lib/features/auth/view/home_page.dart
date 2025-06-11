import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/components/bottom_nav_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:eventorize_app/common/components/event_list.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];
  final GlobalKey _searchContainerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  String? _activeItem;
  Timer? _debounce;
  List<String> _initialSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialSuggestions();
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
      setState(() {});
    });
    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {});
        if (_searchFocusNode.hasFocus && _overlayEntry != null) {
          _overlayEntry!.markNeedsBuild();
        }
      });
    });
  }

  Future<void> _loadInitialSuggestions() async {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    try {
      final suggestions = await viewModel.fetchEventTitles("");
      setState(() {
        _initialSuggestions = suggestions;
      });
    } catch (e) {
      // Silent error handling
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

  void _deleteRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setOverlayState) => buildSearchSuggestionsOverlay(
          searchContainerKey: _searchContainerKey,
          recentSearches: _recentSearches,
          searchController: _searchController,
          activeItem: _activeItem,
          viewModel: Provider.of<HomeViewModel>(context, listen: false),
          initialSuggestions: _initialSuggestions,
          onItemSelected: (item) {
            setState(() {
              _searchController.text = item;
              _addRecentSearch(item);
              _searchFocusNode.unfocus();
            });
          },
          onActiveItemChanged: (item) {
            setState(() {
              _activeItem = item;
            });
            setOverlayState(() {});
          },
          onDeleteRecentSearch: (search) {
            _deleteRecentSearch(search);
            setOverlayState(() {});
          },
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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

  void _handleViewModelErrors(BuildContext context, HomeViewModel viewModel) {
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
            searchHeader: buildSearchHeader(
              context: context,
              searchContainerKey: _searchContainerKey,
              searchFocusNode: _searchFocusNode,
              searchController: _searchController,
              onSearchSubmitted: _addRecentSearch,
            ),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.whiteBackground,
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: _searchFocusNode.hasFocus
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  child: buildMainContainer(
                    isSmallScreen: isSmallScreen,
                    screenSize: screenSize,
                    sessionManager: sessionManager,
                    viewModel: viewModel,
                    searchHeader: buildSearchHeader(
                      context: context,
                      searchContainerKey: _searchContainerKey,
                      searchFocusNode: _searchFocusNode,
                      searchController: _searchController,
                      onSearchSubmitted: _addRecentSearch,
                    ),
                  ),
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
              buildLoadingOverlay(),
          ],
        );
      },
    );
  }
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
  required Widget searchHeader,
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
        searchHeader,
        const SizedBox(height: 16),
        buildSkeletonBox(176, 48),
        const SizedBox(height: 16),
        buildSkeletonBox(double.infinity, 35),
        const SizedBox(height: 24),
        buildSkeletonBox(200, 20),
        const SizedBox(height: 16),
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
              constraints: const BoxConstraints(maxWidth: 600),
              child: buildSkeleton(),
            ),
          ),
        ),
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

Widget buildMainContainer({
  required bool isSmallScreen,
  required Size screenSize,
  required SessionManager sessionManager,
  required HomeViewModel viewModel,
  required Widget searchHeader,
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
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchHeader,
            const SizedBox(height: 16),
            buildLocationSelector(viewModel: viewModel),
            const SizedBox(height: 16),
            buildCategoryChips(),
            const SizedBox(height: 24),
            buildTrendingHeader(),
            const SizedBox(height: 16),
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

Widget buildSearchHeader({
  required BuildContext context,
  required GlobalKey searchContainerKey,
  required FocusNode searchFocusNode,
  required TextEditingController searchController,
  required ValueChanged<String> onSearchSubmitted,
}) {
  final isSearchActive = searchFocusNode.hasFocus;

  return Row(
    children: [
      const SizedBox(
        width: 60,
        height: 60,
        child: Image(
          image: AssetImage('assets/icons/logo_e.png'),
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
          key: searchContainerKey,
          width: 270,
          height: 44,
          child: SearchBar(
            controller: searchController,
            focusNode: searchFocusNode,
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return Colors.white;
              }
              return const Color(0xFFF6F6F6);
            }),
            elevation: const WidgetStatePropertyAll(0),
            shadowColor: const WidgetStatePropertyAll(Colors.transparent),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStateProperty.resolveWith((states) {
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSearchActive ? AppColors.darkGrey : Colors.black12,
                ),
              );
            }),
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                Icons.search,
                color: isSearchActive ? AppColors.darkGrey : AppColors.grey,
                size: 20,
              ),
            ),
            trailing: [
                GestureDetector(
                  onTap: () {
                    if (searchController.text.isNotEmpty) {
                      onSearchSubmitted(searchController.text);
                      searchFocusNode.unfocus();
                    }
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 24),
                  ),
                ),
            ],
            hintText: 'Search events...',
            hintStyle: WidgetStateProperty.resolveWith((states) {
              return TextStyle(
                color: isSearchActive ? AppColors.darkGrey : AppColors.grey,
                fontSize: 15,
              );
            }),
            textStyle: WidgetStateProperty.resolveWith((states) {
              return TextStyle(
                fontSize: 15,
                color: isSearchActive ? AppColors.darkGrey : Colors.black,
              );
            }),
            constraints: const BoxConstraints(minHeight: 44, maxHeight: 44),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 8),
            ),
            onSubmitted: (value) {
              onSearchSubmitted(value);
              searchFocusNode.unfocus();
            },
          ),
        ),
    ],
  );
}

Widget buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGrey,
        ),
      ),
    );

Widget buildSuggestionItem({
  required String suggestion,
  required String? activeItem,
  required ValueChanged<String> onItemSelected,
  required ValueChanged<String?> onActiveItemChanged,
  required double activeRectHeight,
}) => InkWell(
      onTapDown: (TapDownDetails _) => onActiveItemChanged(suggestion),
      onTapUp: (TapUpDetails _) => onActiveItemChanged(null),
      onTapCancel: () => onActiveItemChanged(null),
      onTap: () => onItemSelected(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: activeItem == suggestion ? const Color(0xFFF3F3F3) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: activeRectHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.darkGrey, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: const TextStyle(color: AppColors.darkGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );

Widget buildRecentSearchItem({
  required String search,
  required String? activeItem,
  required ValueChanged<String> onItemSelected,
  required ValueChanged<String?> onActiveItemChanged,
  required ValueChanged<String> onDeleteRecentSearch,
  required double activeRectHeight,
}) => InkWell(
      onTapDown: (TapDownDetails _) => onActiveItemChanged(search),
      onTapUp: (TapUpDetails _) => onActiveItemChanged(null),
      onTapCancel: () => onActiveItemChanged(null),
      onTap: () => onItemSelected(search),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: activeItem == search ? const Color(0xFFF3F3F3) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: activeRectHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: AppColors.darkGrey, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          search,
                          style: const TextStyle(color: AppColors.darkGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.darkGrey, size: 20),
                onPressed: () => onDeleteRecentSearch(search),
              ),
            ],
          ),
        ),
      ),
    );

Widget buildSuggestionsList({
  required List<String> suggestions,
  required String? activeItem,
  required ValueChanged<String> onItemSelected,
  required ValueChanged<String?> onActiveItemChanged,
  required double activeRectHeight,
}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Suggestions'),
        ...suggestions.map(
          (suggestion) => buildSuggestionItem(
            suggestion: suggestion,
            activeItem: activeItem,
            onItemSelected: onItemSelected,
            onActiveItemChanged: onActiveItemChanged,
            activeRectHeight: activeRectHeight,
          ),
        ),
      ],
    );

Widget buildRecentSearchesList({
  required List<String> recentSearches,
  required String? activeItem,
  required ValueChanged<String> onItemSelected,
  required ValueChanged<String?> onActiveItemChanged,
  required ValueChanged<String> onDeleteRecentSearch,
  required double activeRectHeight,
}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Recent Searches'),
        ...recentSearches.map(
          (search) => buildRecentSearchItem(
            search: search,
            activeItem: activeItem,
            onItemSelected: onItemSelected,
            onActiveItemChanged: onActiveItemChanged,
            onDeleteRecentSearch: onDeleteRecentSearch,
            activeRectHeight: activeRectHeight,
          ),
        ),
      ],
    );

Widget buildSearchSuggestionsOverlay({
  required GlobalKey searchContainerKey,
  required List<String> recentSearches,
  required TextEditingController searchController,
  required String? activeItem,
  required HomeViewModel viewModel,
  required List<String> initialSuggestions,
  required ValueChanged<String> onItemSelected,
  required ValueChanged<String?> onActiveItemChanged,
  required ValueChanged<String> onDeleteRecentSearch,
  double activeRectHeight = 40.0,
}) {
  final renderBox = searchContainerKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return const SizedBox.shrink();

  final size = renderBox.size;
  final offset = renderBox.localToGlobal(Offset.zero);
  final query = searchController.text.trim();

  return Positioned(
    left: offset.dx,
    top: offset.dy + size.height + 8,
    width: size.width,
    child: Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (query.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (initialSuggestions.isNotEmpty)
                      buildSuggestionsList(
                        suggestions: initialSuggestions,
                        activeItem: activeItem,
                        onItemSelected: onItemSelected,
                        onActiveItemChanged: onActiveItemChanged,
                        activeRectHeight: activeRectHeight,
                      ),
                    if (recentSearches.isNotEmpty)
                      buildRecentSearchesList(
                        recentSearches: recentSearches,
                        activeItem: activeItem,
                        onItemSelected: onItemSelected,
                        onActiveItemChanged: onActiveItemChanged,
                        onDeleteRecentSearch: onDeleteRecentSearch,
                        activeRectHeight: activeRectHeight,
                      ),
                    if (recentSearches.isEmpty && initialSuggestions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No suggestions or recent searches',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                  ],
                )
              else
                FutureBuilder<List<String>>(
                  future: viewModel.fetchEventTitles(query),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: SpinKitFadingCircle(
                          color: AppColors.primary,
                          size: 30.0,
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No suggestions found',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSuggestionsList(
                          suggestions: snapshot.data!,
                          activeItem: activeItem,
                          onItemSelected: onItemSelected,
                          onActiveItemChanged: onActiveItemChanged,
                          activeRectHeight: activeRectHeight,
                        ),
                        if (recentSearches.isNotEmpty)
                          buildRecentSearchesList(
                            recentSearches: recentSearches,
                            activeItem: activeItem,
                            onItemSelected: onItemSelected,
                            onActiveItemChanged: onActiveItemChanged,
                            onDeleteRecentSearch: onDeleteRecentSearch,
                            activeRectHeight: activeRectHeight,
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildLocationSelector({required HomeViewModel viewModel}) {
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

Widget buildCategoryChips() {
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

Widget buildTrendingHeader() {
  return const Text(
    'Top Trending Event In City',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );
}