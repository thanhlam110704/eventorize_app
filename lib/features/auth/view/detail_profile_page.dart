import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/components/labeled_input.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/features/auth/view_model/detail_profile_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DetailProfilePage extends StatefulWidget {
  const DetailProfilePage({super.key});

  @override
  DetailProfilePageState createState() => DetailProfilePageState();
}

class DetailProfilePageState extends State<DetailProfilePage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;
  static const minTouchTargetSize = 48.0;

  final formKey = GlobalKey<FormState>();
  bool _hasShownSuccessToast = false;
  bool _hasShownErrorToast = false;
  final ScrollController _scrollController = ScrollController();
  bool _showDivider = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        final viewModel = context.read<DetailProfileViewModel>();
        final sessionManager = context.read<SessionManager>();
        await viewModel.loadUser(sessionManager.user); // Gọi loadUser để tải location data
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_showDivider) {
        setState(() {
          _showDivider = true;
        });
      } else if (_scrollController.offset <= 0 && _showDivider) {
        setState(() {
          _showDivider = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    context.read<DetailProfileViewModel>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;
    final isShortScreen = screenSize.height < 600;

    return Consumer<DetailProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isUpdateSuccessful && !_hasShownSuccessToast && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && viewModel.isUpdateSuccessful) {
              ToastCustom.show(
                context: context,
                title: 'Update successful!',
                description: 'Your profile has been updated, ${viewModel.user!.fullname}!',
                type: ToastificationType.success,
              );
              _hasShownSuccessToast = true;
              viewModel.clearUpdateStatus();
              viewModel.clearError();
            }
          });
        } else if (viewModel.errorMessage != null && !_hasShownErrorToast && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && viewModel.errorMessage != null) {
              ToastCustom.show(
                context: context,
                title: viewModel.errorTitle ?? 'Error',
                description: viewModel.errorMessage!,
                type: ToastificationType.error,
              );
              _hasShownErrorToast = true;
              viewModel.clearError();
            }
          });
        }

        if (!viewModel.isDataLoaded) {
          return buildSkeletonUI(isSmallScreen, isShortScreen, screenSize);
        }
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isSmallScreen ? 16 : 24,
                          isShortScreen ? 24 : (isSmallScreen ? 40 : 80),
                          isSmallScreen ? 16 : 24,
                          0,
                        ),
                        child: TopNavBar(
                          title: "Detail Info",
                          showBackButton: true,
                          backgroundColor: AppColors.white,
                        ),  
                      ),
                      if (_showDivider)
                        Container(
                          width: double.infinity,
                          height: 0.5,
                          decoration: BoxDecoration(
                            color: AppColors.grey.withAlpha((0.5 * 255).toInt()),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey.withAlpha((0.6 * 255).toInt()),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: buildMainContainer(isSmallScreen, isShortScreen, screenSize, viewModel),
                    ),
                  ),
                ],
              ),
              if (viewModel.isLoading || (viewModel.isLoadingAnyLocation ))
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: SpinKitFadingCircle(
                      color: AppColors.primary,
                      size: 50.0,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSkeletonUI(bool isSmallScreen, bool isShortScreen, Size screenSize) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 16 : 24,
                  isShortScreen ? 24 : (isSmallScreen ? 40 : 80),
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
              ),
              if (_showDivider)
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.grey,
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                width: screenSize.width,
                color: AppColors.white,
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 16 : 24,
                  24,
                  isSmallScreen ? 16 : 24,
                  isSmallScreen ? 24 : 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxContentWidth),
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
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.skeleton,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: buttonHeight,
                            width: double.infinity,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainContainer(
    bool isSmallScreen,
    bool isShortScreen,
    Size screenSize,
    DetailProfileViewModel viewModel,
  ) {
    return Container(
      width: screenSize.width,
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAvatar(viewModel.user),
                const SizedBox(height: 20),
                buildSectionTitle(),
                const SizedBox(height: 16),
                buildFullnameField(viewModel),
                const SizedBox(height: 16),
                buildEmailField(viewModel),
                const SizedBox(height: 16),
                buildPhoneField(viewModel),
                const SizedBox(height: 16),
                buildCityDropdown(viewModel),
                const SizedBox(height: 16),
                buildDistrictDropdown(viewModel),
                const SizedBox(height: 16),
                buildWardDropdown(viewModel),
                const SizedBox(height: 24),
                buildUpdateButton(viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAvatar(User? user) {
    if (user == null) return const SizedBox.shrink();
    final String initials = user.fullname.isNotEmpty
        ? user.fullname.split(' ').map((e) => e[0]).take(2).join()
        : 'N/A';

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
                    child: initials.isNotEmpty
                        ? Text(
                            initials,
                            style: AppTextStyles.avatarInitials,
                          )
                        : null,
                  ),
                )
              : CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColors.shimmerBase,
                  child: initials.isNotEmpty
                      ? Text(
                          initials,
                          style: AppTextStyles.avatarInitials,
                        )
                      : null,
                ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.disabledGrey,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(minTouchTargetSize, minTouchTargetSize),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
            ),
            child: Text(
              "Upload your image",
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

  Widget buildSectionTitle() {
    return Text(
      "Personal Information",
      style: AppTextStyles.sectionTitle,
      textAlign: TextAlign.left,
    );
  }

  Widget buildFullnameField(DetailProfileViewModel viewModel) {
    return LabeledInput(
      label: "Full Name",
      child: TextFormField(
        controller: viewModel.fullnameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
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
        ),
        validator: (value) => value!.isEmpty ? "Please enter your full name" : null,
      ),
    );
  }

  Widget buildEmailField(DetailProfileViewModel viewModel) {
    return LabeledInput(
      label: "Email Address",
      child: TextFormField(
        controller: viewModel.emailController,
        enabled: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.disabledGrey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: AppColors.inputBackground,
        ),
      ),
    );
  }

  Widget buildPhoneField(DetailProfileViewModel viewModel) {
    return LabeledInput(
      label: "Phone Number",
      child: TextFormField(
        controller: viewModel.phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
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
        ),
        validator: (value) => value!.isEmpty ? "Please enter your phone number" : null,
      ),
    );
  }

  Widget buildCityDropdown(DetailProfileViewModel viewModel) {
    return LabeledInput(
      label: "City",
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedCity,
        items: viewModel.provinces.map((province) {
          return DropdownMenuItem(
            value: province.name,
            child: Text(
              province.name ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: viewModel.isLoadingAnyLocation ? null : viewModel.setCity,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
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
        ),
        validator: (value) => value == null ? "Please select a city" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget buildDistrictDropdown(DetailProfileViewModel viewModel) {
    return LabeledInput(
      label: "District",
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedDistrict,
        items: viewModel.districts.map((district) {
          return DropdownMenuItem(
            value: district.name,
            child: Text(
              district.name ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: viewModel.isLoadingAnyLocation ? null : viewModel.setDistrict,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
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
        ),
        validator: (value) => value == null ? "Please select a district" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget buildWardDropdown(DetailProfileViewModel viewModel) {
    return LabeledInput(
      label: "Ward",
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedWard,
        items: viewModel.wards.map((ward) {
          return DropdownMenuItem(
            value: ward.name,
            child: Text(
              ward.name ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: viewModel.isLoadingAnyLocation ? null : viewModel.setWard,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
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
        ),
        validator: (value) => value == null ? "Please select a ward" : null,
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
        dropdownColor: AppColors.white,
        style: AppTextStyles.text,
      ),
    );
  }

  Widget buildUpdateButton(DetailProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: viewModel.isLoading || viewModel.isLoadingAnyLocation
            ? null
            : () {
                if (!formKey.currentState!.validate()) {
                  ToastCustom.show(
                    context: context,
                    title: 'Validation Error',
                    description: 'Please fill in all required fields.',
                    type: ToastificationType.error,
                  );
                  return;
                }
                viewModel.handleUpdate(context, formKey);
                _hasShownSuccessToast = false;
                _hasShownErrorToast = false;
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: viewModel.isLoading || viewModel.isLoadingAnyLocation
            ? const SpinKitFadingCircle(
                color: AppColors.white,
                size: 24.0,
              )
            : Text(
                "Update Detail Info",
                style: AppTextStyles.button,
              ),
      ),
    );
  }
}