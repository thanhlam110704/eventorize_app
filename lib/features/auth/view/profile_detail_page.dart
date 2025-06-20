import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toastification/toastification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/components/labeled_input.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/features/auth/view_model/profile_detail_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:io';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key});

  @override
  ProfileDetailPageState createState() => ProfileDetailPageState();
}

class ProfileDetailPageState extends State<ProfileDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hasShownSuccessToast = false;
  bool _hasShownErrorToast = false;
  final _scrollController = ScrollController();
  final _showDividerNotifier = ValueNotifier<bool>(false);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<ProfileDetailViewModel>();
      final sessionManager = context.read<SessionManager>();
      await viewModel.loadUser(sessionManager.user);
    });
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final viewModel = context.read<ProfileDetailViewModel>();
    if (!viewModel.isDataLoaded) return; 

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _showDividerNotifier.value = _scrollController.offset > 0;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _showDividerNotifier.dispose();
    context.read<ProfileDetailViewModel>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.width <= 640;
    final isShortScreen = screenSize.height < 600;

    return Consumer<ProfileDetailViewModel>(
      builder: (context, viewModel, _) {
        _showToastIfNeeded(context, viewModel);

        if (!viewModel.isDataLoaded) {
          return _buildSkeletonUI(isSmallScreen, isShortScreen, screenSize);
        }
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(isSmallScreen, isShortScreen),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showDividerNotifier,
                    builder: (context, showDivider, _) {
                      return showDivider ? _buildDivider() : const SizedBox.shrink();
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: _buildMainContainer(isSmallScreen, isShortScreen, screenSize, viewModel),
                    ),
                  ),
                ],
              ),
              if (viewModel.isLoading || viewModel.isLoadingAnyLocation || viewModel.isUploadingAvatar)
                _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  void _showToastIfNeeded(BuildContext context, ProfileDetailViewModel viewModel) {
    if (viewModel.isUpdateSuccessful && !_hasShownSuccessToast) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastCustom.show(
          context: context,
          title: 'Cập nhật tài khoản thành công!',
          type: ToastificationType.success,
        );
        _hasShownSuccessToast = true;
        viewModel.clearUpdateStatus();
        viewModel.clearError();
      });
    } else if (viewModel.errorMessage != null && !_hasShownErrorToast) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastCustom.show(
          context: context,
          title: viewModel.errorTitle ?? 'Lỗi',
          description: viewModel.errorMessage!,
          type: ToastificationType.error,
        );
        _hasShownErrorToast = true;
        viewModel.clearError();
      });
    }
  }

  Widget _buildTopBar(bool isSmallScreen, bool isShortScreen) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isShortScreen ? 24 : isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        0,
      ),
      child: const TopNavBar(
        title: "Thông tin chi tiết",
        showBackButton: true,
      ),
    );
  }

  Widget _buildSkeletonTopBar(bool isSmallScreen, bool isShortScreen) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isShortScreen ? 24 : isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        0,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.skeleton,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 0.5,
      decoration: BoxDecoration(
        color: AppColors.grey.withAlpha((0.5 * 255).toInt()),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withAlpha((0.6 * 255).toInt()),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Divider(
        color: AppColors.grey,
        thickness: 0.5
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: SpinKitFadingCircle(
          color: AppColors.primary,
          size: 50.0,
        ),
      ),
    );
  }

  Widget _buildSkeletonUI(bool isSmallScreen, bool isShortScreen, Size screenSize) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildSkeletonTopBar(isSmallScreen, isShortScreen),
          ValueListenableBuilder<bool>(
            valueListenable: _showDividerNotifier,
            builder: (context, showDivider, _) {
              return showDivider ? _buildDivider() : const SizedBox.shrink();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _buildSkeletonContent(isSmallScreen, screenSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonContent(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(isSmallScreen ? 16 : 24, 24, isSmallScreen ? 16 : 24, isSmallScreen ? 24 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.skeleton,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.skeleton,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 20,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.skeleton,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  6,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.skeleton,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.skeleton,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContainer(bool isSmallScreen, bool isShortScreen, Size screenSize, ProfileDetailViewModel viewModel) {
    return Container(
      width: screenSize.width,
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(isSmallScreen ? 16 : 24, 24, isSmallScreen ? 16 : 24, isSmallScreen ? 24 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(viewModel.user, viewModel),
                const SizedBox(height: 20),
                _buildSectionTitle(),
                const SizedBox(height: 16),
                _buildFullnameField(viewModel),
                const SizedBox(height: 16),
                _buildEmailField(viewModel),
                const SizedBox(height: 16),
                _buildPhoneField(viewModel),
                const SizedBox(height: 16),
                _buildCityDropdown(viewModel),
                const SizedBox(height: 16),
                _buildDistrictDropdown(viewModel),
                const SizedBox(height: 16),
                _buildWardDropdown(viewModel),
                const SizedBox(height: 24),
                _buildUpdateButton(viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User? user, ProfileDetailViewModel viewModel) {
    if (user == null) return const SizedBox.shrink();
    final initials = user.fullname.isNotEmpty ? user.fullname.split(' ').map((e) => e[0]).take(2).join() : 'N/A';

    return Center(
      child: Column(
        children: [
          user.avatar != null && user.avatar!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user.avatar!,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 54,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.shimmerBase,
                    highlightColor: AppColors.shimmerHighlight,
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.skeleton,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.shimmerBase,
                    child: Text(initials, style: AppTextStyles.avatarInitials),
                  ),
                )
              : CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColors.shimmerBase,
                  child: Text(initials, style: AppTextStyles.avatarInitials),
                ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                if (mounted) {
                  await viewModel.uploadAvatar(context, File(pickedFile.path));
                  _hasShownSuccessToast = false;
                  _hasShownErrorToast = false;
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Tải ảnh lên",
              style: AppTextStyles.text.copyWith(
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black,
                decorationThickness: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      "Thông tin cá nhân",
      style: AppTextStyles.sectionTitle,
      textAlign: TextAlign.left,
    );
  }

  InputDecoration _inputDecoration({bool isEnabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isEnabled ? AppColors.grey : AppColors.disabledGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: AppColors.inputBackground,
    );
  }

  Widget _buildFullnameField(ProfileDetailViewModel viewModel) {
    return LabeledInput(
      label: "Họ tên",
      child: TextFormField(
        controller: viewModel.fullnameController,
        decoration: _inputDecoration(),
        validator: (value) => value!.isEmpty ? "Hãy nhập thông tin tên" : null,
      ),
    );
  }

  Widget _buildEmailField(ProfileDetailViewModel viewModel) {
    return LabeledInput(
      label: "Email",
      child: TextFormField(
        controller: viewModel.emailController,
        enabled: false,
        decoration: _inputDecoration(isEnabled: false),
      ),
    );
  }

  Widget _buildPhoneField(ProfileDetailViewModel viewModel) {
    return LabeledInput(
      label: "Số điện thoại",
      child: TextFormField(
        controller: viewModel.phoneController,
        keyboardType: TextInputType.phone,
        decoration: _inputDecoration(),
        validator: (value) => value!.isEmpty ? "Hãy nhập thông tin số điện thoại" : null,
      ),
    );
  }

  Widget _buildCityDropdown(ProfileDetailViewModel viewModel) {
    return LabeledInput(
      label: "Thành phố/Tỉnh",
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedCity,
        items: viewModel.provinces.map((province) {
          return DropdownMenuItem(
            value: province.name,
            child: Text(province.name ?? '', overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: viewModel.isLoadingAnyLocation ? null : viewModel.setCity,
        decoration: _inputDecoration(),
        validator: (value) => value == null ? "Hãy nhập thông tin thành phố/tỉnh" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget _buildDistrictDropdown(ProfileDetailViewModel viewModel) {
    return LabeledInput(
      label: "Quận/Huyện",
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedDistrict,
        items: viewModel.districts.map((district) {
          return DropdownMenuItem(
            value: district.name,
            child: Text(district.name ?? '', overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: viewModel.isLoadingAnyLocation ? null : viewModel.setDistrict,
        decoration: _inputDecoration(),
        validator: (value) => value == null ? "Hãy nhập thông tin quận/huyện" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget _buildWardDropdown(ProfileDetailViewModel viewModel) {
    return LabeledInput(
      label: "Phường/Xã",
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedWard,
        items: viewModel.wards.map((ward) {
          return DropdownMenuItem(
            value: ward.name,
            child: Text(ward.name ?? '', overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: viewModel.isLoadingAnyLocation ? null : viewModel.setWard,
        decoration: _inputDecoration(),
        validator: (value) => value == null ? "Hãy nhập thông tin phường/xã" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget _buildUpdateButton(ProfileDetailViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isLoading || viewModel.isLoadingAnyLocation
            ? null
            : () {
                if (!_formKey.currentState!.validate()) {
                  ToastCustom.show(
                    context: context,
                    title: 'Lỗi cập nhật',
                    description: 'Hãy điền đầy đủ thông tin trước khi cập nhật.',
                    type: ToastificationType.error,
                  );
                  return;
                }
                viewModel.handleUpdate(context, _formKey);
                _hasShownSuccessToast = false;
                _hasShownErrorToast = false;
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text("Cập nhật thông tin", style: AppTextStyles.button),
      ),
    );
  }
}