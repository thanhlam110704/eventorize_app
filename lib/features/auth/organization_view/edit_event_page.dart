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
  final _titleInputKey = GlobalKey<CustomTextFieldState>();
  final _descriptionInputKey = GlobalKey<CustomTextFieldState>();
  final _startDateInputKey = GlobalKey<CustomTextFieldState>();
  final _endDateInputKey = GlobalKey<CustomTextFieldState>();
  final _addressInputKey = GlobalKey<CustomTextFieldState>();
  final _onlineLinkInputKey = GlobalKey<CustomTextFieldState>();
  LocationType _selectedLocation = LocationType.location;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _onlineLinkController = TextEditingController();
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
        if (mounted) {
          setState(() {
            if (isStart) {
              viewModel.setDateRange(date, viewModel.endDate);
              _startDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
            } else {
              viewModel.setDateRange(viewModel.startDate, date);
              _endDateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
            }
            _startDateInputKey.currentState?.validate();
            _endDateInputKey.currentState?.validate();
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
          final currentContext = context;
          bool isValid = true;
          isValid &= _titleInputKey.currentState!.validate();
          isValid &= _descriptionInputKey.currentState!.validate();
          isValid &= _startDateInputKey.currentState!.validate();
          isValid &= _endDateInputKey.currentState!.validate();
          if (_selectedLocation == LocationType.location) {
            isValid &= _addressInputKey.currentState!.validate();
          } else {
            isValid &= _onlineLinkInputKey.currentState!.validate();
          }
          if (!isValid) {
            if (currentContext.mounted) {
              ToastCustom.show(
                context: currentContext,
                title: 'Lỗi',
                description: 'Hãy điền đầy đủ thông tin bắt buộc trước khi cập nhật.',
                type: ToastificationType.error,
              );
            }
            return;
          }
          if (Provider.of<EditEventViewModel>(context, listen: false).startDate == null ||
              Provider.of<EditEventViewModel>(context, listen: false).endDate == null) {
            Provider.of<EditEventViewModel>(context, listen: false).setError('', 'Vui lòng chọn cả ngày bắt đầu và ngày kết thúc');
            return;
          }
          _submitEvent(currentContext);
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
            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                ToastCustom.show(
                  context: context,
                  title: viewModel.errorTitle ?? 'Lỗi',
                  description: viewModel.errorMessage!,
                  type: ToastificationType.error,
                );
                viewModel.clearError();
              });
            }

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

  void _submitEvent(BuildContext context) async {
    final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
    final eventListViewModel = GetIt.instance<EventListViewModel>();
    final sessionManager = GetIt.instance<SessionManager>();
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

    if (viewModel.isUpdateSuccessful && !viewModel.isUploadingThumbnail && context.mounted) {
      ToastCustom.show(
        context: context,
        title: 'Thành công',
        description: 'Cập nhật sự kiện thành công!',
        type: ToastificationType.success,
      );
      viewModel.clearUpdateStatus();
      viewModel.clearError();
      await eventListViewModel.fetchEvents(
        organizerId: sessionManager.selectedOrganizerId!,
        page: 1,
        limit: 20,
        search: "",
      );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleInputKey.currentState?.validate();
      _descriptionInputKey.currentState?.validate();
      _startDateInputKey.currentState?.validate();
      _endDateInputKey.currentState?.validate();
      if (_selectedLocation == LocationType.location) {
        _addressInputKey.currentState?.validate();
      } else {
        _onlineLinkInputKey.currentState?.validate();
      }
    });
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
                    key: _titleInputKey,
                    label: "Tên sự kiện",
                    isRequired: true,
                    isBold: true,
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hãy nhập tên sự kiện";
                      }
                      return null;
                    },
                    onChanged: (value) => _titleInputKey.currentState?.validate(),
                  ),
                  CustomTextField(
                    key: _descriptionInputKey,
                    label: "Tổng quan",
                    isRequired: true,
                    maxLines: 4,
                    isBold: true,
                    controller: _descriptionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hãy nhập tổng quan";
                      }
                      if (value.length < 20) {
                        return "Tổng quan phải có ít nhất 20 ký tự";
                      }
                      return null;
                    },
                    onChanged: (value) => _descriptionInputKey.currentState?.validate(),
                  ),
                  CustomTextField(
                    key: _startDateInputKey,
                    label: "Ngày bắt đầu",
                    isRequired: true,
                    isBold: true,
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () => _pickDateTime(context, viewModel, true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hãy chọn ngày bắt đầu";
                      }
                      return null;
                    },
                    onChanged: (value) => _startDateInputKey.currentState?.validate(),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    key: _endDateInputKey,
                    label: "Ngày kết thúc",
                    isRequired: true,
                    isBold: true,
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _pickDateTime(context, viewModel, false),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hãy chọn ngày kết thúc";
                      }
                      final startDateText = _startDateController.text;
                      if (startDateText.isNotEmpty) {
                        try {
                          final startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(startDateText);
                          final endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
                          if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
                            return "Ngày kết thúc phải sau ngày bắt đầu";
                          }
                        } catch (e) {
                          return "Định dạng ngày không hợp lệ";
                        }
                      }
                      return null;
                    },
                    onChanged: (value) => _endDateInputKey.currentState?.validate(),
                  ),
                  Text("Vị trí", style: AppTextStyles.bold),
                  const SizedBox(height: 12),
                  LocationToggle(
                    selected: _selectedLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                        _addressInputKey.currentState?.validate();
                        _onlineLinkInputKey.currentState?.validate();
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
                            key: _addressInputKey,
                            label: "Địa chỉ",
                            isRequired: true,
                            controller: _addressController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Hãy nhập địa chỉ";
                              }
                              return null;
                            },
                            onChanged: (value) => _addressInputKey.currentState?.validate(),
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
                        key: _onlineLinkInputKey,
                        label: "Link sự kiện online",
                        hintText: "Link",
                        isRequired: true,
                        controller: _onlineLinkController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Hãy nhập link sự kiện";
                          }
                          if (!RegExp(r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$').hasMatch(value)) {
                            return "Hãy nhập link hợp lệ";
                          }
                        return null;
                        },
                        onChanged: (value) => _onlineLinkInputKey.currentState?.validate(),
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