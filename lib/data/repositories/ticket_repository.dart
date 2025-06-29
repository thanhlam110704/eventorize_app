import 'package:eventorize_app/data/api/ticket_api.dart';
import 'package:eventorize_app/data/models/ticket.dart';

class TicketRepository {
  final TicketApi _ticketApi;

  TicketRepository(this._ticketApi);

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
    return await _ticketApi.getEventTickets(
      eventId: eventId,
      page: page,
      limit: limit,
      query: query,
      search: search,
      fields: fields,
      sortBy: sortBy,
      orderBy: orderBy,
    );
  }

  Future<Ticket> getTicketDetail({
    required String eventId,
    required String ticketId,
    String? fields,
  }) async {
    return await _ticketApi.getTicketDetail(
      eventId: eventId,
      ticketId: ticketId,
      fields: fields,
    );
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
    return await _ticketApi.createTicket(
      eventId: eventId,
      title: title,
      description: description,
      quantity: quantity,
      startSaleDate: startSaleDate,
      endSaleDate: endSaleDate,
      price: price,
      minPerUser: minPerUser,
      maxPerUser: maxPerUser,
      status: status,
    );
  }

  Future<Map<String, dynamic>> buyTicket({
    required String eventId,
    String? promotionCode,
    double? overrideAmount,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    return await _ticketApi.buyTicket(
      eventId: eventId,
      promotionCode: promotionCode,
      overrideAmount: overrideAmount,
      orderItems: orderItems,
    );
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
    return await _ticketApi.editTicket(
      eventId: eventId,
      ticketId: ticketId,
      title: title,
      description: description,
      quantity: quantity,
      startSaleDate: startSaleDate,
      endSaleDate: endSaleDate,
      price: price,
      minPerUser: minPerUser,
      maxPerUser: maxPerUser,
      status: status,
    );
  }

  Future<void> deleteTicket(String ticketId) async {
    await _ticketApi.deleteTicket(ticketId);
  }
}