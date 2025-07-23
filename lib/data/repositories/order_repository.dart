import 'package:eventorize_app/data/api/order_api.dart';
import 'package:eventorize_app/data/models/order.dart';

class OrderRepository {
  final OrderApi _orderApi;

  OrderRepository(this._orderApi);

  Future<Map<String, dynamic>> getAll({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
    String? startDate,
    String? endDate,
  }) async {
    return await _orderApi.getAll(
      page: page,
      limit: limit,
      query: query,
      search: search,
      fields: fields,
      sortBy: sortBy,
      orderBy: orderBy,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<Order>> exportOrders({
    String? startDate,
    String? endDate,
  }) async {
    return await _orderApi.exportOrders(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Order> getOrderDetail(String id, {String? fields}) async {
    return await _orderApi.getOrderDetail(id, fields: fields);
  }

  Future<Order> acceptOrder(String id) async {
    return await _orderApi.acceptOrder(id);
  }

  Future<void> deleteOrder(String id) async {
    await _orderApi.deleteOrder(id);
  }
}