import 'package:dio/dio.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/models/order.dart';

class OrderApi {
  final DioClient _dioClient;

  OrderApi(this._dioClient);

  Map<String, dynamic> _buildQueryParams({
    int page = 1,
    int limit = 10,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
    String? startDate,
    String? endDate,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (query != null) 'query': query,
      if (search != null) 'search': search,
      if (fields != null) 'fields': fields,
      if (sortBy != null) 'sort_by': sortBy,
      if (orderBy != null) 'order_by': orderBy,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };
  }

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
    try {
      final response = await _dioClient.get(
        ApiUrl.getOrders,
        queryParameters: _buildQueryParams(
          page: page,
          limit: limit,
          query: query,
          search: search,
          fields: fields,
          sortBy: sortBy,
          orderBy: orderBy,
          startDate: startDate,
          endDate: endDate,
        ),
      );
      return {
        'data': (response.data['results'] as List)
            .map((json) => Order.fromJson(json))
            .toList(),
        'total': response.data['total_items'] as int,
        'total_page': response.data['total_page'] as int,
        'records_per_page': response.data['records_per_page'] as int,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch orders: $errorMessage');
    }
  }

  Future<List<Order>> exportOrders({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.exportOrders,
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );
      return (response.data as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to export orders: $errorMessage');
    }
  }

  Future<Order> getOrderDetail(String id, {String? fields}) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getOrderDetail(id),
        queryParameters: fields != null ? {'fields': fields} : null,
      );
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch order detail: $errorMessage');
    }
  }

  Future<Order> acceptOrder(String id) async {
    try {
      final response = await _dioClient.post(
        ApiUrl.acceptOrder(id),
      );
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to accept order: $errorMessage');
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _dioClient.delete(ApiUrl.deleteOrder(id));
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to delete order: $errorMessage');
    }
  }
}