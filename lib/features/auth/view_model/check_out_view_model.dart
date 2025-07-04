import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/data/models/payment.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';
import 'package:eventorize_app/data/repositories/payment_repository.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';

class CheckOutViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final PaymentRepository _paymentRepository;
  final ErrorState _errorState = ErrorState();
  Order? _order;
  Payment? _payment;
  bool _isLoading = false;
  String? _paypalMessage;

  CheckOutViewModel(this._paymentRepository, this._orderRepository);

  Order? get order => _order;
  Payment? get payment => _payment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;
  String? get paypalMessage => _paypalMessage;
  String? get orderNo => _order?.orderNo;

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

  Future<void> generatePayosQr(String orderId) async {
    _isLoading = true;
    _paypalMessage = null; 
    notifyListeners();
    try {
      _payment = await _paymentRepository.generatePayosQr(orderId);
      ErrorHandler.clearError(_errorState);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi tạo mã QR', _errorState);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPaypalNotSupported() {
    _paypalMessage = 'Chưa hỗ trợ phương thức thanh toán Paypal';
    _payment = null; 
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }

  void clearError() {
    _paypalMessage = null;
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}