import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

class PaymentViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;

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
    throw Exception('Unsupported platform');
  }

  Future<Uint8List> _capturePng(GlobalKey boundaryKey) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('RenderRepaintBoundary not found');
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData?.buffer.asUint8List() ?? (throw Exception('Failed to convert image to byte data'));
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }
}