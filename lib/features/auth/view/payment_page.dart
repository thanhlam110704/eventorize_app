import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:eventorize_app/features/auth/view_model/payment_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:permission_handler/permission_handler.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final String qrCode;
  final String qrDataUrl;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.qrCode,
    required this.qrDataUrl,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;
  static const countdownDuration = Duration(minutes: 5);

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _qrKey = GlobalKey();
  Timer? _timer;
  Duration _remainingTime = countdownDuration;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() => _remainingTime -= const Duration(seconds: 1));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;
    final isShortScreen = screenSize.height < 600;

    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel(),
      child: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.errorMessage != null && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.errorMessage == 'PERMISSION_DENIED_PERMANENTLY') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cần cấp quyền'),
                    content: const Text('Quyền lưu ảnh bị từ chối vĩnh viễn. Vui lòng vào cài đặt ứng dụng để cấp quyền.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                      TextButton(
                        onPressed: () {
                          openAppSettings();
                          Navigator.pop(context);
                        },
                        child: const Text('Mở cài đặt'),
                      ),
                    ],
                  ),
                );
              } else {
                ToastCustom.show(
                  context: context,
                  title: viewModel.errorTitle ?? 'Lỗi',
                  description: viewModel.errorMessage!,
                  type: viewModel.errorTitle == 'Thành công' ? ToastificationType.success : ToastificationType.error,
                );
              }
              viewModel.clearError();
            });
          }

          final isExpired = _remainingTime.inSeconds <= 0;

          return Scaffold(
            backgroundColor: AppColors.whiteBackground,
            body: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isSmallScreen ? 16 : 24,
                        isShortScreen ? 24 : isSmallScreen ? 40 : 80,
                        isSmallScreen ? 16 : 24,
                        0,
                      ),
                      child: const TopNavBar(title: 'Thanh toán', showBackButton: true),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Container(
                          width: screenSize.width,
                          color: AppColors.whiteBackground,
                          padding: EdgeInsets.fromLTRB(
                            isSmallScreen ? 16 : 24,
                            isSmallScreen ? 20 : 40,
                            isSmallScreen ? 16 : 24,
                            isSmallScreen ? 24 : 32,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: maxContentWidth),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (!isExpired) ...[
                                    const SizedBox(height: 20),
                                    Text(
                                      'Quét mã để thanh toán',
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildQrCode(),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Thời gian còn lại: ${(_remainingTime.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                                      style: AppTextStyles.text.copyWith(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  if (isExpired) ...[
                                    Image.asset('assets/images/warning.png', height: 120, width: 120),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Đơn hàng của bạn đã hết hạn',
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: isSmallScreen ? 16 : 24,
                        right: isSmallScreen ? 16 : 24,
                        bottom: isSmallScreen ? 24 : 32,
                        top: screenSize.height * 0.05,
                      ),
                      child: SizedBox(
                        width: isSmallScreen ? double.infinity : screenSize.width * 0.9,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading || isExpired
                              ? null
                              : () => viewModel.captureAndSaveQRCode(
                                    widget.orderId,
                                    widget.qrCode.isNotEmpty ? widget.qrCode : widget.qrDataUrl,
                                    _qrKey,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: viewModel.isLoading
                              ? const SpinKitFadingCircle(color: Colors.white, size: 24.0)
                              : Text('Tải mã QR', style: AppTextStyles.button),
                        ),
                      ),
                    ),
                  ],
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withAlpha(128),
                    child: const Center(
                      child: SpinKitFadingCircle(
                        color: AppColors.primary,
                        size: 50.0,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrCode() {
    return RepaintBoundary(
      key: _qrKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: QrImageView(
          data: widget.qrCode.isNotEmpty ? widget.qrCode : widget.qrDataUrl,
          version: QrVersions.auto,
          size: 300,
          backgroundColor: Colors.white,
          dataModuleStyle: const QrDataModuleStyle(
            color: Color.fromRGBO(37, 0, 78, 1),
            dataModuleShape: QrDataModuleShape.circle,
          ),
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
        ),
      ),
    );
  }
}