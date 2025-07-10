import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:eventorize_app/data/repositories/payment_repository.dart';


class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;
  Timer? _statusCheckTimer;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;

  PaymentViewModel({
    required PaymentRepository paymentRepository,
  }) : _paymentRepository = paymentRepository;

  Future<void> captureAndSaveQRCode(String orderId, String qrData, GlobalKey boundaryKey) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();

    try {
      final permission = await _getPermission();
      if (!await permission.isGranted) {
        final status = await permission.request();
        if (!status.isGranted) {
          _errorTitle = 'Lỗi';
          _errorMessage = status.isPermanentlyDenied
              ? 'PERMISSION_DENIED_PERMANENTLY'
              : 'Quyền lưu ảnh bị từ chối. Vui lòng cấp quyền để lưu mã QR.';
          return;
        }
      }

      final imageBytes = await _capturePng(boundaryKey);
      final tempFile = File('${(await getTemporaryDirectory()).path}/$orderId-QR.png');
      await tempFile.writeAsBytes(imageBytes);

      final success = await GallerySaver.saveImage(tempFile.path, albumName: 'Eventorize');
      if (success == true) {
        _errorTitle = 'Thành công';
        _errorMessage = 'Đã lưu ảnh mã QR thành công!';
      } else {
        _errorTitle = 'Lỗi';
        _errorMessage = 'Lưu ảnh vào thư viện thất bại';
      }

      await tempFile.delete();
    } catch (e) {
      _errorTitle = 'Lỗi';
      _errorMessage = 'Đã xảy ra lỗi khi lưu ảnh: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Permission> _getPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      return sdkInt >= 33 ? Permission.photos : Permission.storage;
    }
    if (Platform.isIOS) return Permission.photos;
    throw Exception('Không hỗ trợ');
  }

  Future<Uint8List> _capturePng(GlobalKey boundaryKey) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('RenderRepaintBoundary not found');
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData?.buffer.asUint8List() ?? (throw Exception('Failed to convert image to byte data'));
  }

  void startPaymentStatusCheck(String orderId, String orderNo, BuildContext context) {
    _statusCheckTimer?.cancel();
    if (orderNo.isEmpty) {
      _errorTitle = 'Lỗi';
      _errorMessage = 'Mã đơn hàng không hợp lệ';
      notifyListeners();
      return;
    }
    _statusCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (!context.mounted) {
        timer.cancel();
        return;
      }
      try {
        final payment = await _paymentRepository.getPaymentStatus(orderNo);
        if (payment.status == 'success' && payment.qrStatus == 'PAID') {
          timer.cancel();
          if (context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/payment-success');
            });
          }
        } else if (payment.qrStatus == 'CANCELLED' || payment.qrStatus == 'EXPIRED') {
          timer.cancel();
          if (context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/payment-failed');
            });
          }
        }
      } catch (e) {
        if (context.mounted) {
          _errorTitle = 'Lỗi';
          _errorMessage = e.toString().contains('422')
              ? 'Mã đơn hàng không hợp lệ hoặc không tồn tại'
              : 'Không thể kiểm tra trạng thái thanh toán: $e';
          notifyListeners();
        }
      }
    });
  }

  Future<void> checkPaymentStatusOnce(String orderId, String orderNo, BuildContext context) async {
    if (orderNo.isEmpty) {
      _errorTitle = 'Lỗi';
      _errorMessage = 'Mã đơn hàng không hợp lệ';
      notifyListeners();
      return;
    }
    try {
      final payment = await _paymentRepository.getPaymentStatus(orderNo);
      if (payment.status == 'success' && payment.qrStatus == 'PAID') {
        if (context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/payment-success');
          });
        }
      } else if (payment.qrStatus == 'CANCELLED' || payment.qrStatus == 'EXPIRED') {
        if (context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/payment-failed');
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        _errorTitle = 'Lỗi';
        _errorMessage = e.toString().contains('422')
            ? 'Mã đơn hàng không hợp lệ hoặc không tồn tại'
            : 'Không thể kiểm tra trạng thái thanh toán: $e';
        notifyListeners();
      }
    }
  }

  void stopPaymentStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }
}