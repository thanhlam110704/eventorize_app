import 'package:dotted_border/dotted_border.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/location_type.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/api/event_api.dart';
import 'package:eventorize_app/features/auth/organization_view_model/create_event_view_model.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';

class CreateEventPage extends StatefulWidget {
  final String organizerId; // Add organizerId parameter

  const CreateEventPage({super.key, required this.organizerId});

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends State<CreateEventPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final overviewController = TextEditingController();
  final dateRangeController = TextEditingController(text: '2025-07-10 to 2025-07-11'); // Hard-coded
  final addressController = TextEditingController();
  final linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Consumer<SessionManager>(
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
                    context.pushReplacement('/login');
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
              create: (_) => CreateEventViewModel(
                eventRepository: EventRepository(EventApi(DioClient())),
                sessionManager: sessionManager,
                organizerId: widget.organizerId, // Pass organizerId
              ),
              child: Consumer<CreateEventViewModel>(
                builder: (context, viewModel, _) {
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
                  return Scaffold(
                    appBar: buildAppBar(viewModel, context),
                    backgroundColor: AppColors.whiteBackground,
                    body: SafeArea(
                      child: SingleChildScrollView(
                        child: buildMainContainer(
                          MediaQuery.of(context).size.width <= smallScreenThreshold,
                          MediaQuery.of(context).size,
                          viewModel,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar(CreateEventViewModel viewModel, BuildContext context) {
    return TopNavOrgBar(
      leadingIcon: Icons.arrow_back_ios,
      title: 'Tạo sự kiện',
      actionIcon: Icons.check,
      onLeadingPressed: () {
        if (titleController.text.isNotEmpty || overviewController.text.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text('Bạn có muốn thoát mà không lưu?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/eventlist/${widget.organizerId}'); // Return to EventListPage with organizerId
                    }
                  },
                  child: const Text('Thoát'),
                ),
              ],
            ),
          );
        } else {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/eventlist/${widget.organizerId}');
          }
        }
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

        viewModel.updateTitle(titleController.text);
        viewModel.updateDescription(overviewController.text);
        viewModel.updateDateRange(dateRangeController.text);
        viewModel.updateAddress(addressController.text);
        viewModel.updateLink(linkController.text);
        viewModel.updateIsOnline(viewModel.isOnline);
        viewModel.updateCity(viewModel.selectedCity);
        viewModel.updateDistrict(viewModel.selectedDistrict);
        viewModel.updateWard(viewModel.selectedWard);

        await viewModel.createEvent();

        if (viewModel.event != null && context.mounted) {
          ToastCustom.show(
            context: context,
            title: 'Success',
            description: 'Tạo sự kiện thành công!',
            type: ToastificationType.success,
          );
          context.go('/eventlist/${widget.organizerId}');
        } else if (viewModel.errorMessage != null && context.mounted) {
          ToastCustom.show(
            context: context,
            title: viewModel.errorTitle ?? 'Lỗi',
            description: viewModel.errorMessage!,
            type: ToastificationType.error,
          );
        }
      },
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, CreateEventViewModel viewModel) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    label: "Tên sự kiện",
                    controller: titleController,
                    hintText: "Tên sự kiện",
                    isRequired: true,
                    isBold: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tên sự kiện không được để trống';
                      if (value.length < 5) return 'Tên sự kiện phải có ít nhất 5 ký tự';
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: "Tổng quan",
                    controller: overviewController,
                    hintText: "Tổng quan",
                    isRequired: true,
                    maxLines: 4,
                    isBold: true,
                  ),
                  CustomTextField(
                    label: "Thời gian",
                    controller: dateRangeController,
                    hintText: "YYYY-MM-DD to YYYY-MM-DD",
                    isRequired: true,
                    isBold: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Thời gian không được để trống';
                      if (!RegExp(r'^\d{4}-\d{2}-\d{2} to \d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                        return 'Định dạng thời gian không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  Text("Vị trí", style: AppTextStyles.bold),
                  const SizedBox(height: 12),
                  LocationToggle(
                    selected: viewModel.isOnline ? LocationType.online : LocationType.location,
                    onChanged: (value) {
                      viewModel.updateIsOnline(value == LocationType.online);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!viewModel.isOnline)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: "Địa chỉ",
                            controller: addressController,
                            hintText: "Địa chỉ",
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Địa chỉ không được để trống';
                              return null;
                            },
                          ),
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
                  if (viewModel.isOnline)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: CustomTextField(
                        label: "Link sự kiện online",
                        controller: linkController,
                        hintText: "Link",
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Link không được để trống';
                          return null;
                        },
                      ),
                    ),
                  if (viewModel.isLoading) const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePicker(CreateEventViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Thêm ảnh", style: AppTextStyles.bold),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              final file = await MultipartFile.fromFile(pickedFile.path);
              viewModel.setThumbnail(file);
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
                      viewModel.thumbnailFile != null ? "Image selected" : "Kéo và thả ảnh hoặc tải ảnh lên",
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
}