import 'package:dio/dio.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/models/ticket.dart';

class TicketApi {
  final DioClient _dioClient;

  TicketApi(this._dioClient);

  Map<String, dynamic> _buildQueryParams({
    int page = 1,
    int limit = 20,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (query != null) 'query': query,
      if (search != null) 'search': search,
      if (fields != null) 'fields': fields,
      if (sortBy != null) 'sort_by': sortBy,
      if (orderBy != null) 'order_by': orderBy,
    };
  }

  Future<Map<String, dynamic>> getEventTickets({
    required String eventId,
    int page = 1,
    int limit = 20,
    String? query,
    String? search,
    String? fields,
    String? sortBy,
    String? orderBy,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getEventTickets(eventId),
        queryParameters: _buildQueryParams(
          page: page,
          limit: limit,
          query: query,
          search: search,
          fields: fields,
          sortBy: sortBy,
          orderBy: orderBy,
        ),
      );
      return {
        'data': (response.data['results'] as List)
            .map((json) => Ticket.fromJson(json))
            .toList(),
        'total': response.data['total_items'] as int,
        'total_page': response.data['total_page'] as int,
        'records_per_page': response.data['records_per_page'] as int,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      final errorType = e.response?.data?['type'] ?? '';
      throw Exception('Failed to fetch event tickets: $errorMessage ($errorType)');
    }
  }

  Future<Ticket> getTicketDetail({
    required String eventId,
    required String ticketId,
    String? fields,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.getTicketDetail(eventId, ticketId),
        queryParameters: fields != null ? {'fields': fields} : null,
      );
      return Ticket.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to fetch ticket detail: $errorMessage');
    }
  }

  Future<Ticket> createTicket({
    required String eventId,
    required String title,
    String? description,
    required int quantity,
    required DateTime startSaleDate,
    required DateTime endSaleDate,
    required int price,
    required int minPerUser,
    required int maxPerUser,
    required String status,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'quantity': quantity,
        'start_sale_date': startSaleDate.toIso8601String(),
        'end_sale_date': endSaleDate.toIso8601String(),
        'price': price,
        'min_per_user': minPerUser,
        'max_per_user': maxPerUser,
        'status': status,
      };

      final response = await _dioClient.post(
        ApiUrl.createTicket(eventId),
        data: data,
      );
      return Ticket.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to create ticket: $errorMessage');
    }
  }

   Future<Map<String, dynamic>> buyTicket({
    required String eventId,
    String? promotionCode,
    double? overrideAmount,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    try {
      final data = {
        if (promotionCode != null) 'promotion_code': promotionCode,
        if (overrideAmount != null) 'override_amount': overrideAmount,
        'order_items': orderItems.map((item) => {
              'ticket_id': item['ticket_id'],
              'quantity': item['quantity'],
              if (item['notes'] != null) 'notes': item['notes'],
            }).toList(),
      };

      final response = await _dioClient.post(
        ApiUrl.buyTicket(eventId),
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to buy ticket: $errorMessage');
    }
  }

  Future<Ticket> editTicket({
    required String eventId,
    required String ticketId,
    String? title,
    String? description,
    int? quantity,
    DateTime? startSaleDate,
    DateTime? endSaleDate,
    int? price,
    int? minPerUser,
    int? maxPerUser,
    String? status,
  }) async {
    try {
      final data = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (quantity != null) 'quantity': quantity,
        if (startSaleDate != null) 'start_sale_date': startSaleDate.toIso8601String(),
        if (endSaleDate != null) 'end_sale_date': endSaleDate.toIso8601String(),
        if (price != null) 'price': price,
        if (minPerUser != null) 'min_per_user': minPerUser,
        if (maxPerUser != null) 'max_per_user': maxPerUser,
        if (status != null) 'status': status,
      };

      final response = await _dioClient.put(
        ApiUrl.editTicket(eventId, ticketId),
        data: data,
      );
      return Ticket.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to update ticket: $errorMessage');
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      await _dioClient.delete(ApiUrl.deleteTicket(ticketId));
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to delete ticket: $errorMessage');
    }
  }
}