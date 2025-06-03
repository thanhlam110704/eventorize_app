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
    'Charity Run',
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
    _overlayEntry = OverlayEntry(
      builder: (context) => SearchSuggestionsOverlay(
        searchContainerKey: _searchContainerKey,
        recentSearches: _recentSearches,
        suggestions: _suggestions,
        searchController: _searchController,
        selectedItem: _selectedItem,
        onItemSelected: (item) {
          setState(() {
            _selectedItem = item;
            _searchController.text = item;
            _addRecentSearch(item);
            _searchFocusNode.unfocus();
          });
        },
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
          return const Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: LoadingOverlay(),
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
          return const Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: LoadingOverlay(),
          );
        }

        if (!viewModel.isDataLoaded) {
          return SkeletonUI(
            isSmallScreen: isSmallScreen,
            screenSize: screenSize,
            searchHeader: SearchHeader(
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
                  child: MainContainer(
                    isSmallScreen: isSmallScreen,
                    screenSize: screenSize,
                    sessionManager: sessionManager,
                    viewModel: viewModel,
                    searchHeader: SearchHeader(
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
              const LoadingOverlay(),
          ],
        );
      },
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
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
}


class SkeletonUI extends StatelessWidget {
  final bool isSmallScreen;
  final Size screenSize;
  final Widget searchHeader;

  const SkeletonUI({
    super.key,
    required this.isSmallScreen,
    required this.screenSize,
    required this.searchHeader,
  });

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
        searchHeader,
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

  @override
  Widget build(BuildContext context) {
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
                child: _buildSkeleton(),
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
}

class MainContainer extends StatelessWidget {
  final bool isSmallScreen;
  final Size screenSize;
  final SessionManager sessionManager;
  final HomeViewModel viewModel;
  final Widget searchHeader;

  const MainContainer({
    super.key,
    required this.isSmallScreen,
    required this.screenSize,
    required this.sessionManager,
    required this.viewModel,
    required this.searchHeader,
  });

  @override
  Widget build(BuildContext context) {
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
              LocationSelector(viewModel: viewModel),
              const SizedBox(height: 16),
              const CategoryChips(),
              const SizedBox(height: 24),
              const TrendingHeader(),
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
}

class SearchHeader extends StatelessWidget {
  final GlobalKey searchContainerKey;
  final FocusNode searchFocusNode;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;

  const SearchHeader({
    super.key,
    required this.searchContainerKey,
    required this.searchFocusNode,
    required this.searchController,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSearchActive = searchFocusNode.hasFocus;

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
        Expanded(
          child: Container(
            key: searchContainerKey,
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
                    controller: searchController,
                    focusNode: searchFocusNode,
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
                      onSearchSubmitted(value);
                      searchFocusNode.unfocus();
                    },
                    onChanged: (value) {
                      context.findAncestorStateOfType<HomePageState>()?.setState(() {});
                    },
                  ),
                ),
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
}

class SearchSuggestionsOverlay extends StatelessWidget {
  final GlobalKey searchContainerKey;
  final List<String> recentSearches;
  final List<String> suggestions;
  final TextEditingController searchController;
  final String? selectedItem;
  final ValueChanged<String> onItemSelected;

  const SearchSuggestionsOverlay({
    super.key,
    required this.searchContainerKey,
    required this.recentSearches,
    required this.suggestions,
    required this.searchController,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    RenderBox? renderBox = searchContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final filteredSuggestions = suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList();

    return Positioned(
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
              if (recentSearches.isNotEmpty) ...[
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
                ...recentSearches.map(
                  (search) => ListTile(
                    leading: const Icon(Icons.history, color: AppColors.darkGrey),
                    title: Text(
                      search,
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                    tileColor: selectedItem == search ? Colors.blue[200] : null,
                    onTap: () => onItemSelected(search),
                  ),
                ),
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
              ...filteredSuggestions.map(
                (suggestion) => ListTile(
                  leading: const Icon(Icons.search, color: AppColors.darkGrey),
                  title: Text(
                    suggestion,
                    style: const TextStyle(color: AppColors.darkGrey),
                  ),
                  tileColor: selectedItem == suggestion ? Colors.blue[200] : null,
                  onTap: () => onItemSelected(suggestion),
                ),
              ),
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
    );
  }
}

class LocationSelector extends StatelessWidget {
  final HomeViewModel viewModel;

  const LocationSelector({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class TrendingHeader extends StatelessWidget {
  const TrendingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Top Trending Event In City',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}