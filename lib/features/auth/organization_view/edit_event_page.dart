import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/location_type.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/features/auth/organization_view_model/edit_event_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/event_list_view_model.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:toastification/toastification.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class EditEventPage extends StatefulWidget {
  final String eventId;
  const EditEventPage({super.key, required this.eventId});

  @override
  EditEventPageState createState() => EditEventPageState();
}

class EditEventPageState extends State<EditEventPage> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
      viewModel.fetchEvent(widget.eventId);
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

  Future<void> _pickDateTime(BuildContext context, EditEventViewModel viewModel, bool isStart) async {
    final initialDate = isStart ? viewModel.startDate : viewModel.endDate;
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365 * 2)),
      onConfirm: (date) {
        setState(() {
          if (isStart) {
            viewModel.setDateRange(date, viewModel.endDate);
            _startDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
          } else {
            viewModel.setDateRange(viewModel.startDate, date);
            _endDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
          }
        });
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Chỉnh sửa sự kiện',
        actionIcon: Icons.check,
        onLeadingPressed: () {
          Navigator.of(context).pop();
        },
        onActionPressed: () {
          if (!_formKey.currentState!.validate()) {
            ToastCustom.show(
              context: context,
              title: 'Lỗi',
              description: 'Hãy điền đầy đủ thông tin bắt buộc trước khi cập nhật.',
              type: ToastificationType.error,
            );
            return;
          }
          if (Provider.of<EditEventViewModel>(context, listen: false).startDate == null ||
              Provider.of<EditEventViewModel>(context, listen: false).endDate == null) {
            Provider.of<EditEventViewModel>(context, listen: false).setError('', 'Vui lòng chọn cả ngày bắt đầu và ngày kết thúc');
            return;
          }
          _submitEvent(context);
          _hasShownSuccessToast = false;
          _hasShownErrorToast = false;
        },
      ),
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Consumer<EditEventViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.event != null && !_isFieldsUpdated) {
              _updateFields(viewModel.event!, viewModel);
              _isFieldsUpdated = true;
            }
            _showToastIfNeeded(context, viewModel);

            if (viewModel.isLoading || viewModel.isUploadingThumbnail || viewModel.isLoadingAnyLocation) {
              return SingleChildScrollView(
                child: buildSkeletonContainer(isSmallScreen, screenSize),
              );
            }

            if (viewModel.event == null && viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.errorTitle ?? 'Lỗi',
                      style: AppTextStyles.bold.copyWith(color: AppColors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage!,
                      style: AppTextStyles.text,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.fetchEvent(widget.eventId);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
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

  void _showToastIfNeeded(BuildContext context, EditEventViewModel viewModel) {
    if (viewModel.isUpdateSuccessful && !_hasShownSuccessToast && !viewModel.isUploadingThumbnail) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final currentContext = context; 
        ToastCustom.show(
          context: currentContext,
          title: 'Cập nhật sự kiện thành công!',
          type: ToastificationType.success,
        );
        _hasShownSuccessToast = true;
        viewModel.clearUpdateStatus();
        viewModel.clearError();
        final eventListViewModel = GetIt.instance<EventListViewModel>();
        final sessionManager = GetIt.instance<SessionManager>();
        await eventListViewModel.fetchEvents(
          organizerId: sessionManager.selectedOrganizerId!,
          page: 1,
          limit: 20,
          search: "",
        );
        if (mounted && currentContext.mounted) {
          Navigator.of(currentContext).pop();
        }
      });
    } else if (viewModel.errorMessage != null && !_hasShownErrorToast) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentContext = context; 
        ToastCustom.show(
          context: currentContext,
          title: viewModel.errorTitle ?? 'Lỗi',
          description: viewModel.errorMessage!,
          type: ToastificationType.error,
        );
        _hasShownErrorToast = true;
        viewModel.clearError();
      });
    }
  }

  void _updateFields(Event event, EditEventViewModel viewModel) {
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    viewModel.setDateRange(event.startDate, event.endDate);
    _startDateController.text = viewModel.startDate != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(viewModel.startDate!)
        : '';
    _endDateController.text = viewModel.endDate != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(viewModel.endDate!)
        : '';
    _selectedLocation = event.isOnline ? LocationType.online : LocationType.location;
    if (event.isOnline) {
      _onlineLinkController.text = event.link ?? '';
    } else {
      _addressController.text = event.address ?? '';
      viewModel.setCity(event.city);
      viewModel.setDistrict(event.district);
      viewModel.setWard(event.ward);
    }
  }

  void _submitEvent(BuildContext context) async {
    final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
    await viewModel.updateEvent(
      context,
      _formKey,
      eventId: widget.eventId,
      title: _titleController.text,
      description: _descriptionController.text,
      link: _selectedLocation == LocationType.online ? _onlineLinkController.text : null,
      isOnline: _selectedLocation == LocationType.online,
      address: _selectedLocation == LocationType.location ? _addressController.text : null,
      district: _selectedLocation == LocationType.location ? viewModel.selectedDistrict : null,
      ward: _selectedLocation == LocationType.location ? viewModel.selectedWard : null,
      city: _selectedLocation == LocationType.location ? viewModel.selectedCity : null,
      country: _selectedLocation == LocationType.location ? viewModel.selectedCountry : null,
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, EditEventViewModel viewModel) {
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
                  buildImagePicker(viewModel.event?.thumbnail),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Tên sự kiện",
                    isRequired: true,
                    isBold: true,
                    controller: _titleController,
                    validator: (value) => value!.isEmpty ? "Hãy nhập tên sự kiện" : null,
                  ),
                  CustomTextField(
                    label: "Tổng quan",
                    isRequired: true,
                    maxLines: 4,
                    isBold: true,
                    controller: _descriptionController,
                    validator: (value) => value!.isEmpty ? "Hãy nhập tổng quan" : null,
                  ),
                  CustomTextField(
                    label: "Ngày bắt đầu",
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

  Widget buildImagePicker(String? thumbnail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ảnh", style: AppTextStyles.bold),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
            final currentContext = context; 
            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null && currentContext.mounted) {
              await viewModel.uploadThumbnail(currentContext, File(pickedFile.path));
              if (mounted) {
                setState(() {
                  _hasShownErrorToast = false;
                });
              }
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: thumbnail != null && thumbnail.isNotEmpty
                ? Image.network(
                    thumbnail,
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
                : Image.asset(
                    'assets/images/event2.png',
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }
}