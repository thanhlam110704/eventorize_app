import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/features/auth/organization_view_model/edit_ticket_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/ticket_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/components/ticket_range_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class EditTicketPage extends StatefulWidget {
  final String eventId;
  final String ticketId;

  const EditTicketPage({super.key, required this.eventId, required this.ticketId});

  @override
  EditTicketPageState createState() => EditTicketPageState();
}

class EditTicketPageState extends State<EditTicketPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final _formKey = GlobalKey<FormState>();
  final _titleInputKey = GlobalKey<CustomTextFieldState>();
  final _descriptionInputKey = GlobalKey<CustomTextFieldState>();
  final _quantityInputKey = GlobalKey<CustomTextFieldState>();
  final _dateRangeInputKey = GlobalKey<CustomTextFieldState>();
  final _priceInputKey = GlobalKey<CustomTextFieldState>();
  final _statusInputKey = GlobalKey<CustomDropdownFieldState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateRangeController = TextEditingController();
  String? _selectedStatus;
  double _minPer = 1;
  double _maxPer = 10;
  bool _hasShownUpdateToast = false;

  static const Map<String, String> statusDisplayToValue = {
    'Hoạt động': 'active',
    'Đã bán hết': 'sold out',
    'Dừng lại': 'paused',
    'Ẩn': 'hidden',
  };
  static const Map<String, String> statusValueToDisplay = {
    'active': 'Hoạt động',
    'sold out': 'Đã bán hết',
    'paused': 'Dừng lại',
    'hidden': 'Ẩn',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = GetIt.instance<EditTicketViewModel>();
      viewModel.fetchTicket(widget.eventId, widget.ticketId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return ChangeNotifierProvider<EditTicketViewModel>.value(
      value: GetIt.instance<EditTicketViewModel>(),
      child: Consumer<EditTicketViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.ticket != null) {
            _titleController.text = viewModel.ticket!.title;
            _descriptionController.text = viewModel.ticket!.description ?? '';
            _quantityController.text = viewModel.ticket!.quantity.toString();
            _priceController.text = viewModel.ticket!.price.toString();
            _selectedStatus = statusValueToDisplay[viewModel.ticket!.status] ?? viewModel.ticket!.status;
            _minPer = viewModel.ticket!.minPerUser.toDouble();
            _maxPer = viewModel.ticket!.maxPerUser.toDouble();
            _dateRangeController.text = viewModel.saleDateRange ?? '';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _titleInputKey.currentState?.validate();
                _descriptionInputKey.currentState?.validate();
                _quantityInputKey.currentState?.validate();
                _dateRangeInputKey.currentState?.validate();
                _priceInputKey.currentState?.validate();
                _statusInputKey.currentState?.validate();
              }
            });
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && viewModel.isUpdateSuccessful && !_hasShownUpdateToast) {
              _hasShownUpdateToast = true;
              ToastCustom.show(
                context: context,
                title: 'Thành công',
                description: 'Chỉnh sửa vé thành công',
                type: ToastificationType.success,
              );
              viewModel.clearUpdateStatus();
              final ticketListViewModel = GetIt.instance<TicketListViewModel>();
              ticketListViewModel.fetchTickets(
                eventId: widget.eventId,
                page: 1,
                limit: 20,
                search: "",
              );
              context.go('/ticket-list/${widget.eventId}');
            }
            if (mounted && viewModel.errorMessage != null) {
              ToastCustom.show(
                context: context,
                title: viewModel.errorTitle ?? 'Lỗi',
                description: viewModel.errorMessage!,
                type: ToastificationType.error,
              );
              viewModel.clearError();
            }
          });

          return Scaffold(
            appBar: TopNavOrgBar(
              leadingIcon: Icons.arrow_back_ios,
              title: 'Chỉnh sửa vé',
              actionIcon: Icons.check,
              onLeadingPressed: () {
                Navigator.of(context).pop();
              },
              onActionPressed: () {
                _submit(context, viewModel);
              },
            ),
            backgroundColor: AppColors.whiteBackground,
            body: SafeArea(
              child: SingleChildScrollView(
                child: viewModel.isLoading
                    ? buildSkeletonContainer(isSmallScreen, screenSize)
                    : buildMainContainer(isSmallScreen, screenSize, viewModel),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, EditTicketViewModel viewModel) {
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
                  CustomTextField(
                    key: _titleInputKey,
                    label: "Tên vé",
                    hintText: "Tên vé",
                    isRequired: true,
                    isBold: true,
                    controller: _titleController,
                    onChanged: (value) {
                      _titleInputKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên vé';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    key: _descriptionInputKey,
                    label: "Tổng quan",
                    hintText: "Tổng quan",
                    isRequired: true,
                    maxLines: 4,
                    isBold: true,
                    controller: _descriptionController,
                    onChanged: (value) {
                      _descriptionInputKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tổng quan';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    key: _quantityInputKey,
                    label: "Số lượng",
                    hintText: "0",
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    isBold: true,
                    controller: _quantityController,
                    onChanged: (value) {
                      _quantityInputKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số lượng';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Số lượng phải là số nguyên dương';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    key: _dateRangeInputKey,
                    label: "Thời gian",
                    hintText: "YYYY-MM-DD HH:MM:SS đến YYYY-MM-DD HH:MM:SS",
                    isRequired: true,
                    isBold: true,
                    controller: _dateRangeController,
                    onTap: () async {
                      final pickedRange = await _pickDateTimeRange(context);
                      if (pickedRange != null) {
                        viewModel.setDateRange(pickedRange['start'], pickedRange['end']);
                        _dateRangeInputKey.currentState?.validate();
                      }
                    },
                    readOnly: true,
                    onChanged: (value) {
                      _dateRangeInputKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (viewModel.saleDateRange == null || value == null || value.isEmpty) {
                        return 'Vui lòng chọn thời gian bán vé';
                      }
                      final dates = value.split(' đến ');
                      if (dates.length != 2) {
                        return 'Thời gian bán vé không hợp lệ';
                      }
                      try {
                        final startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[0]);
                        final endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dates[1]);
                        if (endDate.isBefore(startDate)) {
                          return 'Thời gian kết thúc phải sau thời gian bắt đầu';
                        }
                      } catch (e) {
                        return 'Định dạng thời gian không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    key: _priceInputKey,
                    label: "Giá vé",
                    hintText: "0 VND",
                    isRequired: true,
                    isBold: true,
                    controller: _priceController,
                    onChanged: (value) {
                      _priceInputKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập giá vé';
                      }
                      final number = int.tryParse(value.replaceAll('.', ''));
                      if (number == null || number < 0) {
                        return 'Giá vé phải là số không âm';
                      }
                      return null;
                    },
                  ),
                  CustomDropdownField(
                    key: _statusInputKey,
                    label: "Trạng thái",
                    hintText: "Hoạt động",
                    items: statusDisplayToValue.keys.toList(),
                    selectedValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _statusInputKey.currentState?.validate();
                      });
                    },
                    dropdownWidth: 345,
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lòng chọn trạng thái';
                      }
                      return null;
                    },
                  ),
                  PerRangeSlider(
                    minPer: _minPer,
                    maxPer: _maxPer,
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minPer = values.start;
                        _maxPer = values.end;
                      });
                    },
                  ),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator()),
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

  Future<Map<String, DateTime>?> _pickDateTimeRange(BuildContext context) async {
    if (!mounted) return null;

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
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (startDate == null || !context.mounted) return null;

    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (startTime == null || !context.mounted) return null;

    final endDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (endDate == null || !context.mounted) return null;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (endTime == null || !context.mounted) return null;

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

  void _submit(BuildContext context, EditTicketViewModel viewModel) async {
    bool isValid = true;
    if (_titleInputKey.currentState?.validate() != true) isValid = false;
    if (_descriptionInputKey.currentState?.validate() != true) isValid = false;
    if (_quantityInputKey.currentState?.validate() != true) isValid = false;
    if (_dateRangeInputKey.currentState?.validate() != true) isValid = false;
    if (_priceInputKey.currentState?.validate() != true) isValid = false;
    if (_statusInputKey.currentState?.validate() != true) isValid = false;

    if (isValid) {
      await viewModel.updateTicket(
        context,
        _formKey,
        eventId: widget.eventId,
        ticketId: widget.ticketId,
        title: _titleController.text,
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        price: int.parse(_priceController.text.replaceAll('.', '')),
        minPerUser: _minPer.round(),
        maxPerUser: _maxPer.round(),
        status: statusDisplayToValue[_selectedStatus] ?? viewModel.ticket?.status ?? 'active',
      );
    }
  }

  @override
  void didUpdateWidget(covariant EditTicketPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasShownUpdateToast = false;
  }
}