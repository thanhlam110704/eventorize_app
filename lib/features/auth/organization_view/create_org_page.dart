import 'package:dotted_border/dotted_border.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/data/api/organizer_api.dart';
import 'package:eventorize_app/features/auth/organization_view_model/create_org_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'dart:developer' as developer;
import 'package:toastification/toastification.dart';
import 'dart:io';

class CreateOrgPage extends StatefulWidget {
  const CreateOrgPage({super.key});

  @override
  CreateOrgPageState createState() => CreateOrgPageState();
}

class CreateOrgPageState extends State<CreateOrgPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final overviewController = TextEditingController();
  final addressController = TextEditingController();
  final facebookController = TextEditingController();
  final twitterController = TextEditingController();
  final instagramController = TextEditingController();
  final linkedInController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      extendBodyBehindAppBar: true,
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Tạo nhà tổ chức',
        actionIcon: Icons.check,
        onLeadingPressed: () {
          context.pop();
        },
        onActionPressed: () async {
          if (!_formKey.currentState!.validate()) {
            ToastCustom.show(
              context: context,
              title: 'Lỗi',
              description: 'Vui lòng kiểm tra lại thông tin!',
              type: ToastificationType.error,
            );
            return;
          }

          final viewModel = Provider.of<CreateOrgViewModel>(context, listen: false);
          viewModel.updateName(nameController.text);
          viewModel.updateEmail(emailController.text);
          viewModel.updatePhone(phoneController.text);
          viewModel.updateDescription(overviewController.text);
          viewModel.updateFacebook(facebookController.text);
          viewModel.updateTwitter(twitterController.text);
          viewModel.updateInstagram(instagramController.text);
          viewModel.updateLinkedin(linkedInController.text);

          await viewModel.createOrganizer();

          if (viewModel.organizer != null && context.mounted) {
            ToastCustom.show(
              context: context,
              title: 'Success',
              description: 'Tạo nhà tổ chức thành công!',
              type: ToastificationType.success,
            );
            context.go('/eventlist');
          } else if (viewModel.errorMessage != null && context.mounted) {
            developer.log('Toast error: ${viewModel.errorMessage}');
            ToastCustom.show(
              context: context,
              title: viewModel.errorTitle ?? 'Error',
              description: viewModel.errorMessage!,
              type: ToastificationType.error,
            );
          }
        },
      ),
      body: Consumer<SessionManager>(
        builder: (context, sessionManager, _) {
          if (sessionManager.errorMessage != null && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ToastCustom.show(
                  context: context,
                  title: sessionManager.errorTitle ?? 'Error',
                  description: sessionManager.errorMessage!,
                  type: ToastificationType.error,
                );
                sessionManager.clearError();
                if (!sessionManager.isLoading && sessionManager.user == null) {
                  context.pushReplacementNamed('login');
                }
              }
            });
          }
          if (sessionManager.isCheckingSession || sessionManager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sessionManager.user == null) {
            return const SizedBox.shrink();
          }
          return ChangeNotifierProvider(
            create: (_) => CreateOrgViewModel(
              organizerRepository: OrganizerRepository(OrganizerApi(DioClient())),
              sessionManager: sessionManager,
            ),
            child: Consumer<CreateOrgViewModel>(
              builder: (context, viewModel, _) => SingleChildScrollView(
                child: buildMainContainer(viewModel),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMainContainer(CreateOrgViewModel viewModel) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 100 : 150,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16,),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildImagePicker(viewModel),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Tên tổ chức",
                    controller: nameController,
                    hintText: "Tên tổ chức",
                    isRequired: true,
                    isBold: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tên tổ chức không được để trống';
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: "Email",
                    controller: emailController,
                    hintText: "Email",
                    isRequired: true,
                    isBold: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email không được để trống';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: "Số điện thoại",
                    controller: phoneController,
                    hintText: "Số điện thoại",
                    isRequired: true,
                    isBold: true,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Số điện thoại không được để trống';
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: "Tổng quan",
                    controller: overviewController,
                    hintText: "Tổng quan",
                    isRequired: true,
                    isBold: true,
                    maxLines: 4,
                  ),
                  buildLocationSection(viewModel),
                  buildSocialLinksSection(viewModel),
                  if (viewModel.isLoading) const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePicker(CreateOrgViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ảnh", style: AppTextStyles.bold),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              final file = await MultipartFile.fromFile(pickedFile.path);
              viewModel.setImage(file, File(pickedFile.path));
            }
          },
          child: DottedBorder(
            color: AppColors.grey,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(5),
            child: Container(
              height: 140,
              width: double.infinity,
              color: AppColors.inputBackground,
              child: Center(
                child: viewModel.imageFile != null
                    ? Image.file(
                        viewModel.imageFile!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/upload.png',
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Kéo và thả ảnh hoặc tải ảnh lên",
                            style: AppTextStyles.text.copyWith(
                              color: AppColors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLocationSection(CreateOrgViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Địa điểm", style: AppTextStyles.bold),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdownField(
                label: "Thành phố",
                hintText: "Chọn thành phố",
                items: const ["Hà Nội", "TP.HCM"],
                selectedValue: viewModel.selectedCity,
                onChanged: viewModel.updateCity,
                dropdownWidth: 345,
              ),
              CustomDropdownField(
                label: "Quận",
                hintText: "Chọn quận",
                items: const ["Quận 1", "Quận 2"],
                selectedValue: viewModel.selectedDistrict,
                onChanged: viewModel.updateDistrict,
                dropdownWidth: 345,
              ),
              CustomDropdownField(
                label: "Phường/huyện",
                hintText: "Chọn phường/huyện",
                items: const ["Phường A", "Phường B"],
                selectedValue: viewModel.selectedWard,
                onChanged: viewModel.updateWard,
                dropdownWidth: 345,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSocialLinksSection(CreateOrgViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text("Liên kết mạng xã hội", style: AppTextStyles.bold),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "Facebook",
                controller: facebookController,
                hintText: "Facebook url",
              ),
              CustomTextField(
                label: "Twitter",
                controller: twitterController,
                hintText: "Twitter url",
              ),
              CustomTextField(
                label: "Instagram",
                controller: instagramController,
                hintText: "Instagram url",
              ),
              CustomTextField(
                label: "LinkedIn",
                controller: linkedInController,
                hintText: "LinkedIn url",
              ),
            ],
          ),
        ),
      ],
    );
  }
}