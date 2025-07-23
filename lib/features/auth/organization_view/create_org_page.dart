import 'package:dotted_border/dotted_border.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view_model/create_org_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
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
  final _nameInputKey = GlobalKey<CustomTextFieldState>();
  final _emailInputKey = GlobalKey<CustomTextFieldState>();
  final _phoneInputKey = GlobalKey<CustomTextFieldState>();
  final _descriptionInputKey = GlobalKey<CustomTextFieldState>();
  final _facebookInputKey = GlobalKey<CustomTextFieldState>();
  final _twitterInputKey = GlobalKey<CustomTextFieldState>();
  final _instagramInputKey = GlobalKey<CustomTextFieldState>();
  final _linkedinInputKey = GlobalKey<CustomTextFieldState>();
  final _cityInputKey = GlobalKey<CustomDropdownFieldState>();
  final _districtInputKey = GlobalKey<CustomDropdownFieldState>();
  final _wardInputKey = GlobalKey<CustomDropdownFieldState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();

  bool _isFieldsUpdated = false;
  File? _selectedImageFile;
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = Provider.of<CreateOrgViewModel>(context, listen: false);
      _updateFields(viewModel);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  void _updateFields(CreateOrgViewModel viewModel) {
    if (viewModel.name != null) _nameController.text = viewModel.name!;
    if (viewModel.email != null) _emailController.text = viewModel.email!;
    if (viewModel.phone != null) _phoneController.text = viewModel.phone!;
    if (viewModel.description != null) _descriptionController.text = viewModel.description!;
    if (viewModel.facebook != null) _facebookController.text = viewModel.facebook!;
    if (viewModel.twitter != null) _twitterController.text = viewModel.twitter!;
    if (viewModel.instagram != null) _instagramController.text = viewModel.instagram!;
    if (viewModel.linkedin != null) _linkedinController.text = viewModel.linkedin!;
    _isFieldsUpdated = true;
  }

  void _submitOrganizer(BuildContext context, CreateOrgViewModel viewModel) async {
    bool isValid = true;
    isValid &= _nameInputKey.currentState!.validate();
    isValid &= _emailInputKey.currentState!.validate();
    isValid &= _phoneInputKey.currentState!.validate();
    isValid &= _descriptionInputKey.currentState!.validate();
    isValid &= _cityInputKey.currentState!.validate();

    if (!isValid) {
      if (!mounted) return;
      ToastCustom.show(
        context: context,
        title: 'Lỗi',
        description: 'Hãy điền đầy đủ thông tin bắt buộc trước khi tạo.',
        type: ToastificationType.error,
      );
      return;
    }

    viewModel.setName(_nameController.text);
    viewModel.setEmail(_emailController.text);
    viewModel.setPhone(_phoneController.text);
    viewModel.setDescription(_descriptionController.text);
    viewModel.setFacebook(_facebookController.text);
    viewModel.setTwitter(_twitterController.text);
    viewModel.setInstagram(_instagramController.text);
    viewModel.setLinkedin(_linkedinController.text);

    final organizer = await viewModel.createOrganizer(context, _formKey);

    if (viewModel.isCreateSuccessful && organizer != null && mounted) {
      setState(() {
        _thumbnailUrl = organizer.logo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Tạo nhà tổ chức',
        actionIcon: Icons.check,
        onLeadingPressed: () {
          context.go('/account');
        },
        onActionPressed: () {
          if (!mounted) return;
          final viewModel = Provider.of<CreateOrgViewModel>(context, listen: false);
          _submitOrganizer(context, viewModel);
        },
      ),
      body: Consumer<SessionManager>(
        builder: (context, sessionManager, _) {
          if (sessionManager.errorMessage != null && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ToastCustom.show(
                context: context,
                title: sessionManager.errorTitle ?? 'Lỗi',
                description: sessionManager.errorMessage!,
                type: ToastificationType.error,
              );
              sessionManager.clearError();
              
            });
          }
          return Consumer<CreateOrgViewModel>(
            builder: (context, viewModel, _) {
              if (!_isFieldsUpdated) {
                _updateFields(viewModel);
              }
              if (viewModel.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ToastCustom.show(
                    context: context,
                    title: viewModel.errorTitle ?? 'Lỗi',
                    description: viewModel.errorMessage!,
                    type: ToastificationType.error,
                  );
                  viewModel.clearError();
                });
              }
              if (viewModel.isCreateSuccessful) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ToastCustom.show(
                    context: context,
                    title: 'Thành công',
                    description: 'Tạo nhà tổ chức thành công',
                    type: ToastificationType.success,
                  );
                  viewModel.clearCreateStatus();
                  if (mounted) {
                    context.go('/event-list');
                  }
                });
              }
              if (viewModel.isLoading || viewModel.isLoadingAnyLocation) {
                return SingleChildScrollView(
                  child: buildSkeletonContainer(MediaQuery.of(context).size),
                );
              }
              return SingleChildScrollView(
                child: buildMainContainer(MediaQuery.of(context).size, viewModel),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildMainContainer(Size screenSize, CreateOrgViewModel viewModel) {
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24, 
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  buildImagePicker(viewModel),
                  const SizedBox(height: 16),
                  CustomTextField(
                    key: _nameInputKey,
                    label: "Tên tổ chức",
                    controller: _nameController,
                    hintText: "Nhập tên tổ chức",
                    isRequired: true,
                    isBold: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tên tổ chức không được để trống';
                      if (value.length < 3) return 'Tên tổ chức phải có ít nhất 3 ký tự';
                      return null;
                    },
                    onChanged: (value) {
                      _nameInputKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    key: _descriptionInputKey,
                    label: "Tổng quan",
                    controller: _descriptionController,
                    hintText: "Nhập tổng quan",
                    isRequired: true,
                    isBold: true,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tổng quan không được để trống';
                      if (value.length < 20) return 'Tổng quan phải có ít nhất 20 ký tự';
                      return null;
                    },
                    onChanged: (value) {
                      _descriptionInputKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    key: _emailInputKey,
                    label: "Email",
                    controller: _emailController,
                    hintText: "Nhập email",
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
                    onChanged: (value) {
                      _emailInputKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    key: _phoneInputKey,
                    label: "Số điện thoại",
                    controller: _phoneController,
                    hintText: "Nhập số điện thoại",
                    isRequired: true,
                    isBold: true,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Số điện thoại không được để trống';
                      if (!RegExp(r'^\+?\d{10,12}$').hasMatch(value)) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _phoneInputKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  buildLocationSection(viewModel),
                  const SizedBox(height: 16),
                  buildSocialLinksSection(viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSkeletonContainer(Size screenSize) {
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24, 
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBase,
              highlightColor: AppColors.shimmerHighlight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
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
    );
  }

  Widget buildImagePicker(CreateOrgViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Thêm ảnh", style: AppTextStyles.bold),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 140,
          child: GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null && mounted) {
                final file = await MultipartFile.fromFile(pickedFile.path, filename: pickedFile.path.split('/').last);
                setState(() {
                  _selectedImageFile = File(pickedFile.path);
                  _thumbnailUrl = null;
                  viewModel.setImage(file, _selectedImageFile);
                });
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: double.infinity,
                height: 140,
                child: _selectedImageFile != null
                    ? Image.file(
                        _selectedImageFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.grey,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : _thumbnailUrl != null && _thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            _thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.grey,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : DottedBorder(
                            color: AppColors.grey,
                            dashPattern: const [6, 4],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(5),
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              color: AppColors.inputBackground,
                              child: Center(
                                child: Column(
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
                                      style: AppTextStyles.text.copyWith(color: AppColors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                key: _cityInputKey,
                label: "Thành phố",
                hintText: "Chọn thành phố",
                items: viewModel.provinces.map((p) => p.name!).toList(),
                selectedValue: viewModel.selectedCity,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng chọn thành phố';
                  return null;
                },
                onChanged: (value) {
                  viewModel.setCity(value);
                  _cityInputKey.currentState?.validate();
                },
                dropdownWidth: 345,
                menuHeight: 200,
              ),
              const SizedBox(height: 16),
              CustomDropdownField(
                key: _districtInputKey,
                label: "Quận",
                hintText: "Chọn quận",
                items: viewModel.districts.map((d) => d.name!).toList(),
                selectedValue: viewModel.selectedDistrict,
                onChanged: (value) {
                  viewModel.setDistrict(value);
                  _districtInputKey.currentState?.validate();
                },
                dropdownWidth: 345,
                menuHeight: 200,
              ),
              const SizedBox(height: 16),
              CustomDropdownField(
                key: _wardInputKey,
                label: "Phường/xã",
                hintText: "Chọn phường/xã",
                items: viewModel.wards.map((w) => w.name!).toList(),
                selectedValue: viewModel.selectedWard,
                onChanged: (value) {
                  viewModel.setWard(value);
                  _wardInputKey.currentState?.validate();
                },
                dropdownWidth: 345,
                menuHeight: 200,
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
        Text("Liên kết mạng xã hội", style: AppTextStyles.bold),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                key: _facebookInputKey,
                label: "Facebook",
                controller: _facebookController,
                hintText: "Nhập URL Facebook",
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(value)) {
                    return 'Vui lòng nhập URL hợp lệ';
                  }
                  return null;
                },
                onChanged: (value) {
                  _facebookInputKey.currentState?.validate();
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                key: _twitterInputKey,
                label: "Twitter",
                controller: _twitterController,
                hintText: "Nhập URL Twitter",
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(value)) {
                    return 'Vui lòng nhập URL hợp lệ';
                  }
                  return null;
                },
                onChanged: (value) {
                  _twitterInputKey.currentState?.validate();
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                key: _instagramInputKey,
                label: "Instagram",
                controller: _instagramController,
                hintText: "Nhập URL Instagram",
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(value)) {
                    return 'Vui lòng nhập URL hợp lệ';
                  }
                  return null;
                },
                onChanged: (value) {
                  _instagramInputKey.currentState?.validate();
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                key: _linkedinInputKey,
                label: "LinkedIn",
                controller: _linkedinController,
                hintText: "Nhập URL LinkedIn",
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(value)) {
                    return 'Vui lòng nhập URL hợp lệ';
                  }
                  return null;
                },
                onChanged: (value) {
                  _linkedinInputKey.currentState?.validate();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}