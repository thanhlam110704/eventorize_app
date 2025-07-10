import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/data/models/order_item.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';

class TicketViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;

  List<OrderItem> _tickets = [];
  List<Order> _orders = []; 
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderItem> get tickets => _tickets;
  List<Order> get orders => _orders; 
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TicketViewModel({required OrderRepository orderRepository})
      : _orderRepository = orderRepository {
    fetchTickets();
  }

  Future<void> fetchTickets({
    int page = 1,
    int limit = 20,
    String search = "",
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderRepository.getAll(
        page: page,
        limit: limit,
        search: "active",
      );
      _orders = response['data'] as List<Order>;
      _tickets = _orders.expand((order) => order.orderItems).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatEventTime(DateTime startDate, DateTime endDate) {
    final formatter = DateFormat('EEEE, MMM d, HH:mm');
    final startFormatted = formatter.format(startDate);
    final endFormatted = formatter.format(endDate);
    return '$startFormatted - $endFormatted';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}