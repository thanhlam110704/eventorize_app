import 'package:dotted_border/dotted_border.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/location_type.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/features/auth/organization_view_model/create_event_view_model.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

class CreateEventPage extends StatefulWidget {
  final String organizerId;
  const CreateEventPage({super.key, required this.organizerId});

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends State<CreateEventPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final _formKey = GlobalKey<FormState>();
  LocationType _selectedLocation = LocationType.location;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _onlineLinkController = TextEditingController();
  bool _hasShownSuccessToast = false;
  bool _hasShownErrorToast = false;
  bool _isFieldsUpdated = false;
  File? _selectedImageFile;
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CreateEventViewModel>(context, listen: false);
      _updateFields(viewModel);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _addressController.dispose();
    _onlineLinkController.dispose();
    super.dispose();
  }

  void _updateFields(CreateEventViewModel viewModel) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    if (viewModel.startDate != null) {
      _startDateController.text = dateFormat.format(viewModel.startDate!);
    }
    if (viewModel.endDate != null) {
      _endDateController.text = dateFormat.format(viewModel.endDate!);
    }
    _isFieldsUpdated = true;
  }

  Future<void> _pickDateTime(BuildContext context, CreateEventViewModel viewModel, bool isStart) async {
    final initialDate = isStart ? viewModel.startDate : viewModel.endDate;
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365 * 2)),
      onConfirm: (date) {
        if (mounted) {
          setState(() {
            final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
            if (isStart) {
              viewModel.setDateRange(date, viewModel.endDate);
              _startDateController.text = dateFormat.format(date);
            } else {
              viewModel.setDateRange(viewModel.startDate, date);
              _endDateController.text = dateFormat.format(date);
            }
          });
        }
      },
      currentTime: initialDate ?? DateTime.now(),
      locale: LocaleType.vi,
      theme: const DatePickerTheme(
        backgroundColor: AppColors.whiteBackground,
        itemStyle: TextStyle(color: AppColors.primary),
        cancelStyle: TextStyle(color: AppColors.grey),
        doneStyle: TextStyle(color: AppColors.primary),
      ),
    );
  }

  void _submitEvent(BuildContext context, CreateEventViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ToastCustom.show(
          context: context,
          title: 'Lỗi',
          description: 'Hãy điền đầy đủ thông tin bắt buộc trước khi tạo.',
          type: ToastificationType.error,
        );
      }
      return;
    }
    if (viewModel.startDate == null || viewModel.endDate == null) {
      viewModel.setError('', 'Vui lòng chọn cả ngày bắt đầu và ngày kết thúc');
      return;
    }
    final event = await viewModel.createEvent(
      context,
      _formKey,
      organizerId: widget.organizerId,
      title: _titleController.text,
      description: _descriptionController.text,
      link: _selectedLocation == LocationType.online ? _onlineLinkController.text : null,
      isOnline: _selectedLocation == LocationType.online,
      address: _selectedLocation == LocationType.location ? _addressController.text : null,
      district: _selectedLocation == LocationType.location ? viewModel.selectedDistrict : null,
      ward: _selectedLocation == LocationType.location ? viewModel.selectedWard : null,
      city: _selectedLocation == LocationType.location ? viewModel.selectedCity : null,
      country: _selectedLocation == LocationType.location ? viewModel.selectedCountry : null,
      imageFile: _selectedImageFile,
    );
    if (viewModel.isCreateSuccessful && event != null && mounted) {
      setState(() {
        _thumbnailUrl = event.thumbnail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Tạo sự kiện',
        actionIcon: Icons.check,
        onLeadingPressed: () {
          Navigator.of(context).pop();
        },
        onActionPressed: () {
          final viewModel = Provider.of<CreateEventViewModel>(context, listen: false);
          _submitEvent(context, viewModel);
          _hasShownSuccessToast = false;
          _hasShownErrorToast = false;
        },
      ),
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Consumer<CreateEventViewModel>(
          builder: (context, viewModel, _) {
            if (!_isFieldsUpdated) {
              _updateFields(viewModel);
            }
            if (viewModel.errorMessage != null && !_hasShownErrorToast) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
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

            if (viewModel.isCreateSuccessful && !_hasShownSuccessToast) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ToastCustom.show(
                  context: context,
                  title: 'Thành công',
                  description: 'Tạo sự kiện thành công',
                  type: ToastificationType.success,
                );
                _hasShownSuccessToast = true;
                viewModel.clearCreateStatus();
                if (mounted && context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            }

            if (viewModel.isLoading || viewModel.isLoadingAnyLocation) {
              return SingleChildScrollView(
                child: buildSkeletonContainer(isSmallScreen, screenSize),
              );
            }

            return SingleChildScrollView(
              child: buildMainContainer(isSmallScreen, screenSize, viewModel),
            );
          },
        ),
      ),
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
                    hintText: "Tên sự kiện",
                    isRequired: true,
                    isBold: true,
                    controller: _titleController,
                    validator: (value) => value!.isEmpty ? "Hãy nhập tên sự kiện" : null,
                  ),
                  CustomTextField(
                    label: "Tổng quan",
                    hintText: "Tổng quan",
                    isRequired: true,
                    maxLines: 4,
                    isBold: true,
                    controller: _descriptionController,
                    validator: (value) => value!.isEmpty ? "Hãy nhập tổng quan" : null,
                  ),
                  CustomTextField(
                    label: "Ngày bắt đầu",
                    hintText: "YYYY-MM-DD HH:mm:ss",
                    isRequired: true,
                    isBold: true,
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () => _pickDateTime(context, viewModel, true),
                    validator: (value) => value!.isEmpty ? "Hãy chọn ngày bắt đầu" : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Ngày kết thúc",
                    hintText: "YYYY-MM-DD HH:mm:ss",
                    isRequired: true,
                    isBold: true,
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _pickDateTime(context, viewModel, false),
                    validator: (value) => value!.isEmpty ? "Hãy chọn ngày kết thúc" : null,
                  ),
                  Text("Vị trí", style: AppTextStyles.bold),
                  const SizedBox(height: 12),
                  LocationToggle(
                    selected: _selectedLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedLocation == LocationType.location)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: "Địa chỉ",
                            hintText: "Địa chỉ",
                            controller: _addressController,
                            validator: (value) => value!.isEmpty ? "Hãy nhập địa chỉ" : null,
                          ),
                          CustomDropdownField(
                            label: "Thành phố",
                            hintText: "Chọn thành phố",
                            items: viewModel.provinces
                                .map((p) => p.name)
                                .where((name) => name != null)
                                .cast<String>()
                                .toList(),
                            selectedValue: viewModel.selectedCity,
                            onChanged: (value) {
                              viewModel.setCity(value);
                            },
                            dropdownWidth: 345,
                          ),
                          CustomDropdownField(
                            label: "Quận",
                            hintText: "Chọn quận",
                            items: viewModel.districts
                                .map((d) => d.name)
                                .where((name) => name != null)
                                .cast<String>()
                                .toList(),
                            selectedValue: viewModel.selectedDistrict,
                            onChanged: (value) {
                              viewModel.setDistrict(value);
                            },
                            dropdownWidth: 345,
                          ),
                          CustomDropdownField(
                            label: "Phường/huyện",
                            hintText: "Chọn phường/huyện",
                            items: viewModel.wards
                                .map((w) => w.name)
                                .where((name) => name != null)
                                .cast<String>()
                                .toList(),
                            selectedValue: viewModel.selectedWard,
                            onChanged: (value) {
                              viewModel.setWard(value);
                            },
                            dropdownWidth: 345,
                          ),
                        ],
                      ),
                    ),
                  if (_selectedLocation == LocationType.online)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: CustomTextField(
                        label: "Link sự kiện online",
                        hintText: "Link",
                        controller: _onlineLinkController,
                        validator: (value) => value!.isEmpty ? "Hãy nhập link sự kiện" : null,
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

  Widget buildSkeletonContainer(bool isSmallScreen, Size screenSize) {
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
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedLocation == LocationType.location) ...[
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
                  if (_selectedLocation == LocationType.online)
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

  Widget buildImagePicker(CreateEventViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Thêm ảnh", style: AppTextStyles.bold),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null && mounted) {
              setState(() {
                _selectedImageFile = File(pickedFile.path);
                _thumbnailUrl = null;
              });
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: _selectedImageFile != null
                ? Image.file(
                    _selectedImageFile!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 140,
                      color: AppColors.grey,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : _thumbnailUrl != null && _thumbnailUrl!.isNotEmpty
                    ? Image.network(
                        _thumbnailUrl!,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 140,
                          color: AppColors.grey,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : DottedBorder(
                        color: AppColors.grey,
                        dashPattern: [6, 4],
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
      ],
    );
  }
}