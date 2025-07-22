import 'package:dotted_border/dotted_border.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/location_type.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/features/auth/organization_view_model/create_event_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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
  final _titleInputKey = GlobalKey<CustomTextFieldState>();
  final _descriptionInputKey = GlobalKey<CustomTextFieldState>();
  final _timeRangeInputKey = GlobalKey<CustomTextFieldState>();
  final _addressInputKey = GlobalKey<CustomTextFieldState>();
  final _onlineLinkInputKey = GlobalKey<CustomTextFieldState>();
  final _cityInputKey = GlobalKey<CustomDropdownFieldState>();
  final _districtInputKey = GlobalKey<CustomDropdownFieldState>();
  final _wardInputKey = GlobalKey<CustomDropdownFieldState>();
  LocationType _selectedLocation = LocationType.location;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeRangeController = TextEditingController();
  final _addressController = TextEditingController();
  final _onlineLinkController = TextEditingController();
  bool _isFieldsUpdated = false;
  File? _selectedImageFile;
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = Provider.of<CreateEventViewModel>(context, listen: false);
      _updateFields(viewModel);
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

  void _updateFields(CreateEventViewModel viewModel) {
    if (viewModel.timeRange != null) {
      _timeRangeController.text = viewModel.timeRange!;
    }
    _isFieldsUpdated = true;
  }

  Future<Map<String, DateTime>?> _pickDateTimeRange() async {
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );

    if (startDate == null || !mounted) return null;

    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  void _submitEvent(BuildContext context, CreateEventViewModel viewModel) async {
    bool isValid = true;
    isValid &= _titleInputKey.currentState!.validate();
    isValid &= _descriptionInputKey.currentState!.validate();
    isValid &= _timeRangeInputKey.currentState!.validate();
    if (_selectedLocation == LocationType.location) {
      isValid &= _addressInputKey.currentState!.validate();
      isValid &= _cityInputKey.currentState!.validate();
    } else {
      isValid &= _onlineLinkInputKey.currentState!.validate();
    }
    if (viewModel.timeRange == null) {
      isValid = false;
      if (!mounted) return;
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
        final dates = _timeRangeController.text.split(' to ');
        if (dates.length != 2) {
          isValid = false;
          if (!mounted) return;
          ToastCustom.show(
            context: context,
            title: 'Lỗi',
            description: 'Thời gian diễn ra không hợp lệ',
            type: ToastificationType.error,
          );
          return;
        }
        final startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[0]);
        final endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[1]);
        if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
          isValid = false;
          if (!mounted) return;
          ToastCustom.show(
            context: context,
            title: 'Lỗi',
            description: 'Ngày kết thúc phải sau ngày bắt đầu',
            type: ToastificationType.error,
          );
          return;
        }
      } catch (e) {
        isValid = false;
        if (!mounted) return;
        ToastCustom.show(
          context: context,
          title: 'Lỗi',
          description: 'Định dạng thời gian không hợp lệ',
          type: ToastificationType.error,
        );
        return;
      }
    }
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
          if (!mounted) return;
          final viewModel = Provider.of<CreateEventViewModel>(context, listen: false);
          _submitEvent(context, viewModel);
        },
      ),
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Consumer<CreateEventViewModel>(
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
                  description: 'Tạo sự kiện thành công',
                  type: ToastificationType.success,
                );
                viewModel.clearCreateStatus();
                if (mounted) {
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
                    key: _titleInputKey,
                    label: "Tên sự kiện",
                    hintText: "Nhập tên sự kiện",
                    isRequired: true,
                    isBold: true,
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên sự kiện';
                      }
                      if (value.length < 3) {
                        return 'Tên sự kiện phải có ít nhất 3 ký tự';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9À-ỹ\s'-]{3,}$").hasMatch(value)) {
                        return 'Tên sự kiện chỉ chứa chữ cái, số, khoảng trắng, dấu gạch ngang hoặc dấu nháy đơn';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _titleInputKey.currentState?.validate();
                    },
                  ),
                  CustomTextField(
                    key: _descriptionInputKey,
                    label: "Tổng quan",
                    hintText: "Nhập tổng quan",
                    isRequired: true,
                    maxLines: 4,
                    isBold: true,
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tổng quan';
                      }
                      if (value.length < 20) {
                        return 'Tổng quan phải có ít nhất 20 ký tự';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _descriptionInputKey.currentState?.validate();
                    },
                  ),
                  CustomTextField(
                    key: _timeRangeInputKey,
                    label: "Thời gian diễn ra",
                    hintText: "YYYY-MM-DD HH:mm:ss đến YYYY-MM-DD HH:mm:ss",
                    isRequired: true,
                    isBold: true,
                    controller: _timeRangeController,
                    readOnly: true,
                    onTap: () async {
                      final pickedRange = await _pickDateTimeRange();
                      if (pickedRange != null && mounted) {
                        final viewModel = Provider.of<CreateEventViewModel>(context, listen: false);
                        final timeRange =
                            '${DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedRange['start']!)} đến ${DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedRange['end']!)}';
                        viewModel.setTimeRange(timeRange);
                        setState(() {
                          _timeRangeController.text = timeRange;
                          _timeRangeInputKey.currentState?.validate();
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn thời gian diễn ra';
                      }
                      final dates = value.split(' đến ');
                      if (dates.length != 2) {
                        return 'Thời gian diễn ra không hợp lệ';
                      }
                      try {
                        final startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[0]);
                        final endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[1]);
                        if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
                          return 'Ngày kết thúc phải sau ngày bắt đầu';
                        }
                      } catch (e) {
                        return 'Định dạng thời gian không hợp lệ';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _timeRangeInputKey.currentState?.validate();
                    },
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
                        _cityInputKey.currentState?.validate();
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
                            keyboardType: TextInputType.streetAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập địa chỉ';
                              }
                              if (value.length < 5) {
                                return 'Địa chỉ phải có ít nhất 5 ký tự';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _addressInputKey.currentState?.validate();
                            },
                          ),
                          CustomDropdownField(
                            key: _cityInputKey,
                            label: "Thành phố",
                            hintText: "Chọn thành phố",
                            items: viewModel.provinces
                                .map((p) => p.name)
                                .where((name) => name != null)
                                .cast<String>()
                                .toList(),
                            selectedValue: viewModel.selectedCity,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn thành phố';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              viewModel.setCity(value);
                              _cityInputKey.currentState?.validate();
                            },
                            dropdownWidth: 345,
                            menuHeight: 200,
                          ),
                          CustomDropdownField(
                            key: _districtInputKey,
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
                              _districtInputKey.currentState?.validate();
                            },
                            dropdownWidth: 345,
                            menuHeight: 200,
                          ),
                          CustomDropdownField(
                            key: _wardInputKey,
                            label: "Phường/xã",
                            hintText: "Chọn phường/xã",
                            items: viewModel.wards
                                .map((w) => w.name)
                                .where((name) => name != null)
                                .cast<String>()
                                .toList(),
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
                  if (_selectedLocation == LocationType.online)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: CustomTextField(
                        key: _onlineLinkInputKey,
                        label: "Link sự kiện online",
                        hintText: "Nhập link sự kiện",
                        isRequired: true,
                        controller: _onlineLinkController,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập link sự kiện';
                          }
                          if (!RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(value)) {
                            return 'Vui lòng nhập URL hợp lệ (bắt đầu bằng http:// hoặc https://)';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _onlineLinkInputKey.currentState?.validate();
                        },
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