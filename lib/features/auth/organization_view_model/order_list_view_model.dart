import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class OrderListViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final SessionManager _sessionManager;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;
  int _currentPage = 1;
  int _currentLimit = 20;
  String _currentSearch = "";

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;

  OrderListViewModel({
    required OrderRepository orderRepository,
    required SessionManager sessionManager,
  }) : _orderRepository = orderRepository, _sessionManager = sessionManager;

  Future<void> fetchOrders({
    int page = 1,
    int limit = 20,
    String search = "",
  }) async {
    if (_sessionManager.user == null) {
      _errorMessage = 'Vui lòng đăng nhập trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderRepository.getAll(
        page: page,
        limit: limit,
        search: search,
      );

      _orders = response['data'] as List<Order>;
      _currentPage = page;
      _currentLimit = limit;
      _currentSearch = search;
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách đơn hàng: $e';
      _errorTitle = 'Lỗi';
      if (kDebugMode) {
        print('Fetch orders error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    if (_sessionManager.user == null) {
      _errorMessage = 'Vui lòng đăng nhập trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final originalOrders = List<Order>.from(_orders);
    _orders = _orders.where((order) => order.id != orderId).toList();
    notifyListeners();

    try {
      await _orderRepository.deleteOrder(orderId);
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _orders = originalOrders;
      _errorMessage = 'Xóa đơn hàng thất bại: $e';
      _errorTitle = 'Lỗi';
      await fetchOrders(
        page: _currentPage,
        limit: _currentLimit,
        search: _currentSearch,
      );
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