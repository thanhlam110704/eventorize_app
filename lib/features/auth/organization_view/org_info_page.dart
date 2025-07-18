import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toastification/toastification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventorize_app/common/components/labeled_input.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/features/auth/organization_view_model/org_info_view_model.dart';
import 'package:eventorize_app/common/components/side_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class OrgInfoPage extends StatefulWidget {
  const OrgInfoPage({super.key});

  @override
  OrgInfoPageState createState() => OrgInfoPageState();
}

class OrgInfoPageState extends State<OrgInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasShownSuccessToast = false;
  bool _hasShownErrorToast = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<OrgInfoViewModel>().loadOrganizer();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    context.read<OrgInfoViewModel>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.width <= 640;
    final isShortScreen = screenSize.height < 600;

    return Consumer<OrgInfoViewModel>(
      builder: (context, viewModel, _) {
        _showToastIfNeeded(context, viewModel);

        if (!viewModel.getIsDataLoaded) {
          return _buildSkeletonUI(isSmallScreen, isShortScreen, screenSize);
        }
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.white,
          drawer: const CustomDrawer(currentPage: AppPage.orgInfo),
          appBar: TopNavOrgBar(
            leadingIcon: Icons.menu,
            onLeadingPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            title: 'Nhà tổ chức',
            actionIcon: Icons.check,
            onActionPressed: viewModel.getIsLoading || viewModel.getIsLoadingAnyLocation
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) {
                      ToastCustom.show(
                        context: context,
                        title: 'Lỗi cập nhật',
                        description: 'Hãy điền đầy đủ thông tin bắt buộc trước khi cập nhật.',
                        type: ToastificationType.error,
                      );
                      return;
                    }
                    viewModel.handleUpdate(context, _formKey);
                    _hasShownSuccessToast = false;
                    _hasShownErrorToast = false;
                  },
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: _buildMainContainer(isSmallScreen, isShortScreen, screenSize, viewModel),
              ),
              if (viewModel.getIsLoadingAnyLocation || viewModel.getIsUploadingLogo)
                _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  void _showToastIfNeeded(BuildContext context, OrgInfoViewModel viewModel) {
    if (viewModel.getIsUpdateSuccessful && !_hasShownSuccessToast) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastCustom.show(
          context: context,
          title: 'Cập nhật thông tin nhà tổ chức thành công!',
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
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      drawer: const CustomDrawer(currentPage: AppPage.orgInfo),
      appBar: TopNavOrgBar(
        leadingIcon: Icons.menu,
        onLeadingPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        title: 'Nhà tổ chức',
        actionIcon: Icons.check,
        onActionPressed: null,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: _buildSkeletonContent(isSmallScreen, screenSize),
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
                  8,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContainer(bool isSmallScreen, bool isShortScreen, Size screenSize, OrgInfoViewModel viewModel) {
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
                _buildLogo(viewModel.getOrganizer, viewModel),
                const SizedBox(height: 20),
                _buildSectionTitle(),
                const SizedBox(height: 16),
                _buildNameField(viewModel),
                const SizedBox(height: 16),
                _buildEmailField(viewModel),
                const SizedBox(height: 16),
                _buildPhoneField(viewModel),
                const SizedBox(height: 16),
                _buildDescriptionField(viewModel),
                const SizedBox(height: 16),
                _buildCountryField(viewModel),
                const SizedBox(height: 16),
                _buildCityDropdown(viewModel),
                const SizedBox(height: 16),
                _buildDistrictDropdown(viewModel),
                const SizedBox(height: 16),
                _buildWardDropdown(viewModel),
                const SizedBox(height: 16),
                _buildFacebookField(viewModel),
                const SizedBox(height: 16),
                _buildTwitterField(viewModel),
                const SizedBox(height: 16),
                _buildLinkedinField(viewModel),
                const SizedBox(height: 16),
                _buildInstagramField(viewModel),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Organizer? organizer, OrgInfoViewModel viewModel) {
    if (organizer == null) return const SizedBox.shrink();
    final initials = organizer.name.isNotEmpty ? organizer.name.split(' ').map((e) => e[0]).take(2).join() : 'N/A';

    return Center(
      child: Column(
        children: [
          organizer.logo != null && organizer.logo!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: organizer.logo!,
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
                  await viewModel.uploadLogo(context, File(pickedFile.path));
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
              "Tải logo lên",
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
      "Thông tin nhà tổ chức",
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

  Widget _buildNameField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Tên nhà tổ chức",
      child: TextFormField(
        controller: viewModel.nameController,
        decoration: _inputDecoration(),
        validator: (value) => value!.isEmpty ? "Hãy nhập tên nhà tổ chức" : null,
      ),
    );
  }

  Widget _buildEmailField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Email",
      child: TextFormField(
        controller: viewModel.emailController,
        enabled: false,
        decoration: _inputDecoration(isEnabled: false),
      ),
    );
  }

  Widget _buildPhoneField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Số điện thoại",
      child: TextFormField(
        controller: viewModel.phoneController,
        keyboardType: TextInputType.phone,
        decoration: _inputDecoration(),
        validator: (value) => value!.isEmpty ? "Hãy nhập số điện thoại" : null,
      ),
    );
  }

  Widget _buildDescriptionField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Mô tả",
      child: TextFormField(
        controller: viewModel.descriptionController,
        maxLines: 4,
        decoration: _inputDecoration(),
      ),
    );
  }

  Widget _buildCountryField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Quốc gia",
      child: TextFormField(
        controller: TextEditingController(text: viewModel.selectedCountry),
        enabled: false,
        decoration: _inputDecoration(isEnabled: false),
      ),
    );
  }

  Widget _buildCityDropdown(OrgInfoViewModel viewModel) {
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
        onChanged: viewModel.getIsLoadingAnyLocation ? null : viewModel.setCity,
        decoration: _inputDecoration(),
        validator: (value) => value == null ? "Hãy chọn thành phố/tỉnh" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget _buildDistrictDropdown(OrgInfoViewModel viewModel) {
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
        onChanged: viewModel.getIsLoadingAnyLocation ? null : viewModel.setDistrict,
        decoration: _inputDecoration(),
        validator: (value) => value == null ? "Hãy chọn quận/huyện" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget _buildWardDropdown(OrgInfoViewModel viewModel) {
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
        onChanged: viewModel.getIsLoadingAnyLocation ? null : viewModel.setWard,
        decoration: _inputDecoration(),
        validator: (value) => value == null ? "Hãy chọn phường/xã" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget _buildFacebookField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Facebook",
      child: TextFormField(
        controller: viewModel.facebookController,
        decoration: _inputDecoration(),
      ),
    );
  }

  Widget _buildTwitterField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Twitter",
      child: TextFormField(
        controller: viewModel.twitterController,
        decoration: _inputDecoration(),
      ),
    );
  }

  Widget _buildLinkedinField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "LinkedIn",
      child: TextFormField(
        controller: viewModel.linkedinController,
        decoration: _inputDecoration(),
      ),
    );
  }

  Widget _buildInstagramField(OrgInfoViewModel viewModel) {
    return LabeledInput(
      label: "Instagram",
      child: TextFormField(
        controller: viewModel.instagramController,
        decoration: _inputDecoration(),
      ),
    );
  }
}