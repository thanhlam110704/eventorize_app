import 'dart:ui';
import 'package:eventorize_app/common/components/custom_fields.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view_model/select_org_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:get_it/get_it.dart';

class SelectOrgPage extends StatefulWidget {
  const SelectOrgPage({super.key});

  @override
  State<SelectOrgPage> createState() => _SelectOrgPageState();
}

class _SelectOrgPageState extends State<SelectOrgPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showPopup = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionManager = GetIt.instance<SessionManager>();
      final viewModel = Provider.of<SelectOrgViewModel>(context, listen: false);
      if (sessionManager.user != null) {
        viewModel.resetAndFetchOrganizers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, sessionManager, _) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.whiteBackground,
          appBar: TopNavOrgBar(
            leadingIcon: Icons.menu,
            onLeadingPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            title: 'Chọn nhà tổ chức',
            actionIcon: Icons.search,
            onActionPressed: null,
          ),
          body: SafeArea(
            child: Consumer<SelectOrgViewModel>(
              builder: (context, viewModel, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _handleErrors(context, sessionManager, viewModel);
                  if (sessionManager.user != null &&
                      !viewModel.isLoading &&
                      viewModel.organizers.isEmpty) {
                    context.go('/create-org');
                  }
                });

                if (sessionManager.isCheckingSession ||
                    sessionManager.isLoading ||
                    viewModel.isLoading) {
                  return Stack(
                    children: [
                      const SizedBox.expand(),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Container(
                            color: Colors.black.withAlpha(128),
                            child: const Center(
                              child: SpinKitFadingCircle(
                                color: AppColors.white,
                                size: 50.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }


                if (viewModel.organizers.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Stack(
                  children: [
                    const SizedBox.expand(),
                    if (showPopup) _buildOrganizerPopup(viewModel),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: _buildFAB(),
        );
      },
    );
  }

  void _handleErrors(
    BuildContext context,
    SessionManager session,
    SelectOrgViewModel viewModel,
  ) {

    if (viewModel.errorMessage != null) {
      ToastCustom.show(
        context: context,
        title: viewModel.errorTitle ?? 'Lỗi',
        description: viewModel.errorMessage!,
        type: ToastificationType.error,
      );
      viewModel.clearError();
    }
  }

  Widget _buildOrganizerPopup(SelectOrgViewModel viewModel) {
    String? selectedOrganizerName;
    if (viewModel.selectedOrganizerId != null) {
      try {
        selectedOrganizerName = viewModel.organizers
            .firstWhere((org) => org.id == viewModel.selectedOrganizerId)
            .name;
      } catch (e) {
        selectedOrganizerName = null;
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        Center(
          child: Transform.translate(
            offset: const Offset(0, -40),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey, width: 1),
                ),
                clipBehavior: Clip.none,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lựa chọn nhà tổ chức',
                          style: AppTextStyles.bold.copyWith(fontSize: 20),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chọn nhà tổ chức quản lý sự kiện',
                      style: AppTextStyles.text.copyWith(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                    ),
                    CustomDropdownField(
                      label: '',
                      hintText: 'Chọn nhà tổ chức',
                      items: viewModel.organizers.map((org) => org.name).toList(),
                      selectedValue: selectedOrganizerName,
                      dropdownWidth: 310,
                      onChanged: (value) async {
                        if (!mounted || value == null) return;
                        try {
                          final selectedOrg = viewModel.organizers
                              .firstWhere((org) => org.name == value);
                          await viewModel.selectOrganizer(selectedOrg.id);
                          await Future.delayed(const Duration(milliseconds: 100));
                          if (mounted) context.go('/event-list');
                        } catch (_) {
                          if (mounted) {
                            ToastCustom.show(
                              context: context,
                              title: 'Lỗi',
                              description: 'Lỗi khi chọn nhà tổ chức',
                              type: ToastificationType.error,
                            );
                          }
                        }
                      },
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

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 50),
      child: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: showPopup ? null : () => context.go('/create-event'),
          backgroundColor: const Color(0xFF194185),
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}