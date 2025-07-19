import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/location_type.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/features/auth/organization_view_model/edit_event_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/event_list_view_model.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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
  final _timeRangeInputKey = GlobalKey<CustomTextFieldState>();
  final _addressInputKey = GlobalKey<CustomTextFieldState>();
  final _onlineLinkInputKey = GlobalKey<CustomTextFieldState>();
  LocationType _selectedLocation = LocationType.location;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeRangeController = TextEditingController();
  final _addressController = TextEditingController();
  final _onlineLinkController = TextEditingController();
  bool _isFieldsUpdated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
      viewModel.fetchEvent(widget.eventId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeRangeController.dispose();
    _addressController.dispose();
    _onlineLinkController.dispose();
    super.dispose();
  }

  Future<Map<String, DateTime>?> _pickDateTimeRange() async {
    DateTime initialStartDate = DateTime.now();
    TimeOfDay initialStartTime = TimeOfDay.now();
    if (mounted) {
      final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
      if (viewModel.timeRange != null && viewModel.timeRange!.contains(' to ')) {
        initialStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(viewModel.timeRange!.split(' to ')[0]);
        initialStartTime = TimeOfDay.fromDateTime(initialStartDate);
      }
    }

    final theme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        onPrimary: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
        ),
      ),
    );

    final startDate = await showDatePicker(
      context: context,
      initialDate: initialStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );

    if (startDate == null || !mounted) return null;

    final startTime = await showTimePicker(
      context: context,
      initialTime: initialStartTime,
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );

    if (startTime == null || !mounted) return null;

    final endDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );

    if (endDate == null || !mounted) return null;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );

    if (endTime == null || !mounted) return null;

    final startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    return {'start': startDateTime, 'end': endDateTime};
  }

  void _submitEvent(BuildContext context) async {
  bool isValid = true;
  isValid &= _titleInputKey.currentState!.validate();
  isValid &= _descriptionInputKey.currentState!.validate();
  isValid &= _timeRangeInputKey.currentState!.validate();
  if (_selectedLocation == LocationType.location) {
    isValid &= _addressInputKey.currentState!.validate();
  } else {
    isValid &= _onlineLinkInputKey.currentState!.validate();
  }
  if (!mounted) return;
  final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
  if (viewModel.timeRange == null) {
    isValid = false;
    ToastCustom.show(
      context: context,
      title: 'Lỗi',
      description: 'Vui lòng chọn thời gian diễn ra',
      type: ToastificationType.error,
    );
    return;
  }
  if (_timeRangeController.text.isNotEmpty) {
    try {
      final dates = _timeRangeController.text.split(' - ');
      if (dates.length != 2) {
        isValid = false;
        if (mounted) {
          ToastCustom.show(
            context: context,
            title: 'Lỗi',
            description: 'Thời gian diễn ra không hợp lệ',
            type: ToastificationType.error,
          );
        }
        return;
      }
      final startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[0]);
      final endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[1]);
      if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
        isValid = false;
        if (mounted) {
          ToastCustom.show(
            context: context,
            title: 'Lỗi',
            description: 'Ngày kết thúc phải sau ngày bắt đầu',
            type: ToastificationType.error,
          );
        }
        return;
      }
    } catch (e) {
      isValid = false;
      if (mounted) {
        ToastCustom.show(
          context: context,
          title: 'Lỗi',
          description: 'Định dạng thời gian không hợp lệ',
          type: ToastificationType.error,
        );
      }
      return;
    }
  }
  if (!isValid) {
    if (mounted) {
      ToastCustom.show(
        context: context,
        title: 'Lỗi',
        description: 'Hãy điền đầy đủ thông tin bắt buộc trước khi cập nhật.',
        type: ToastificationType.error,
      );
    }
    return;
  }

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
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
  void _updateFields(Event event, EditEventViewModel viewModel) {
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    _timeRangeController.text = viewModel.timeRange ?? '';
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
      if (!mounted) return;
      _titleInputKey.currentState?.validate();
      _descriptionInputKey.currentState?.validate();
      _timeRangeInputKey.currentState?.validate();
      if (_selectedLocation == LocationType.location) {
        _addressInputKey.currentState?.validate();
      } else {
        _onlineLinkInputKey.currentState?.validate();
      }
    });
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
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        onActionPressed: () {
          if (mounted) {
            _submitEvent(context);
          }
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
                        if (mounted) {
                          viewModel.fetchEvent(widget.eventId);
                        }
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
                    hintText: "Nhập tên sự kiện",
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
                    hintText: "Nhập tổng quan",
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
                    key: _timeRangeInputKey,
                    label: "Thời gian diễn ra",
                    hintText: "YYYY-MM-DD HH:mm:ss to YYYY-MM-DD HH:mm:ss",
                    isRequired: true,
                    isBold: true,
                    controller: _timeRangeController,
                    readOnly: true,
                    onTap: () async {
                      final pickedRange = await _pickDateTimeRange();
                      if (pickedRange != null && mounted) {
                        final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
                        final timeRange =
                            '${DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedRange['start']!)} to ${DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedRange['end']!)}';
                        viewModel.setTimeRange(timeRange);
                        setState(() {
                          _timeRangeController.text = timeRange;
                          _timeRangeInputKey.currentState?.validate();
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Hãy chọn thời gian diễn ra";
                      }
                      final dates = value.split(' to ');
                      if (dates.length != 2) {
                        return "Thời gian diễn ra không hợp lệ";
                      }
                      try {
                        final startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[0]);
                        final endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[1]);
                        if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
                          return "Ngày kết thúc phải sau ngày bắt đầu";
                        }
                      } catch (e) {
                        return "Định dạng thời gian không hợp lệ";
                      }
                      return null;
                    },
                    onChanged: (value) => _timeRangeInputKey.currentState?.validate(),
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
                            hintText: "Nhập địa chỉ",
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
                        hintText: "Nhập link sự kiện",
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
            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null && mounted) {
              final viewModel = Provider.of<EditEventViewModel>(context, listen: false);
              await viewModel.uploadThumbnail(context, File(pickedFile.path));
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