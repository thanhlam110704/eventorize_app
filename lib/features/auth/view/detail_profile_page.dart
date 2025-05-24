import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/common/widgets/labeled_input.dart';
import 'package:eventorize_app/common/widgets/toast_custom.dart';
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

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        final viewModel = context.read<DetailProfileViewModel>();
        final sessionManager = context.read<SessionManager>();
        await viewModel.loadUser(sessionManager.user);
      }
    });
  }

  @override
  void dispose() {
    context.read<DetailProfileViewModel>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Consumer<DetailProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isUpdateSuccessful && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && viewModel.isUpdateSuccessful) {
              ToastCustom.show(
                context: context,
                title: 'Update successful!',
                description: 'Your profile has been updated, ${viewModel.user!.fullname}!',
                type: ToastificationType.success,
              );
              viewModel.clearUpdateStatus();
              viewModel.clearError();
            }
          });
        }
        else if (viewModel.errorMessage != null && mounted) {
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
        }

        if (!viewModel.isDataLoaded || viewModel.isLoading) {
          return buildSkeletonUI(isSmallScreen, screenSize);
        }
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: buildMainContainer(isSmallScreen, screenSize, viewModel),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withAlpha(128),
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

  Widget buildSkeletonUI(bool isSmallScreen, Size screenSize) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenSize.width,
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              isSmallScreen ?16 : 24,
              isSmallScreen ? 40 : 80,
              isSmallScreen ? 16 : 24,
              isSmallScreen ? 24 : 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 40, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 108,
                              height: 108,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(height: 16, width: 120, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(height: 20, width: 200, color: Colors.white),
                      const SizedBox(height: 16),
                      ...List.generate(
                        6,
                        (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(height: 56, width: double.infinity, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(height: buttonHeight, width: double.infinity, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, DetailProfileViewModel viewModel) {
    return Container(
      width: screenSize.width,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 40 : 80,
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
                buildHeaderRow(context),
                const SizedBox(height: 16),
                buildAvatar(viewModel.user),
                const SizedBox(height: 24),
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
                const SizedBox(height: 32),
                buildUpdateButton(viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeaderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 40),
            child: Center(
              child: Text(
                "Detail Info",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
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
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.grey[300],
                    child: initials.isNotEmpty
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                )
              : CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.grey[300],
                  child: initials.isNotEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
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
    return const Text("Personal Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget buildFullnameField(DetailProfileViewModel viewModel) {
    return LabeledInput(
      label: "Full Name",
      child: TextFormField(
        controller: viewModel.fullnameController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF9F9F9),
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF9F9F9),
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF9F9F9),
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
            child: Text(province.name ?? ''),
          );
        }).toList(),
        onChanged: viewModel.setCity,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF9F9F9),
        ),
        validator: (value) => value == null ? "Please select a city" : null,
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
            child: Text(district.name ?? ''),
          );
        }).toList(),
        onChanged: viewModel.setDistrict,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF9F9F9),
        ),
        validator: (value) => value == null ? "Please select a district" : null,
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
            child: Text(ward.name ?? ''),
          );
        }).toList(),
        onChanged: viewModel.setWard,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF9F9F9),
        ),
        validator: (value) => value == null ? "Please select a ward" : null,
      ),
    );
  }

  Widget buildUpdateButton(DetailProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () => viewModel.handleUpdate(context, formKey),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Update Detail Info", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}