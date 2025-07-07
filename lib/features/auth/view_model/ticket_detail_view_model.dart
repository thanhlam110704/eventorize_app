import 'package:flutter/material.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';

class TicketDetailViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;

  Order? _order;
  bool _isLoading = false;
  String? _errorMessage;

  Order? get order => _order;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TicketDetailViewModel({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  Future<void> fetchOrderDetail(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await _orderRepository.getOrderDetail(orderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}