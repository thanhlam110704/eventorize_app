import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';

class CheckOutViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final ErrorState _errorState = ErrorState();
  Order? _order;
  bool _isLoading = false;

  CheckOutViewModel(this._orderRepository);

  Order? get order => _order;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  Future<void> fetchOrderDetail(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _order = await _orderRepository.getOrderDetail(orderId);
      ErrorHandler.clearError(_errorState);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi tải chi tiết đơn hàng', _errorState);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _order = await _orderRepository.acceptOrder(orderId);
      ErrorHandler.clearError(_errorState);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi xác nhận đơn hàng', _errorState);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}