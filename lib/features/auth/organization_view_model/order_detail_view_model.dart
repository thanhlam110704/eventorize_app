import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class OrderDetailViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final SessionManager _sessionManager;
  Order? _order;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;

  Order? get order => _order;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;

  OrderDetailViewModel({
    required OrderRepository orderRepository,
    required SessionManager sessionManager,
  }) : _orderRepository = orderRepository, _sessionManager = sessionManager;

  Future<void> fetchOrderDetail(String orderId) async {
    if (_sessionManager.user == null) {
      _errorMessage = 'Vui lòng đăng nhập trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();

    try {
      _order = await _orderRepository.getOrderDetail(orderId);
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải chi tiết đơn hàng: $e';
      _errorTitle = 'Lỗi';
      if (kDebugMode) {
        print('Fetch order detail error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }
}