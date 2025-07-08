import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String ticketId;
  final String? ticketTitle; 
  final String eventId;
  final String? eventTitle;
  final String? eventThumbnail; 
  final String? eventAddress; 
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final String? status; 
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.ticketId,
    this.ticketTitle,
    required this.eventId,
    this.eventTitle,
    this.eventThumbnail,
    this.eventAddress,
    required this.eventStartDate,
    required this.eventEndDate,
    this.status,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] as String,
      orderId: json['order_id'] as String,
      ticketId: json['ticket_id'] as String,
      ticketTitle: json['ticket_title'] as String?,
      eventId: json['event_id'] as String,
      eventTitle: json['event_title'] as String?,
      eventThumbnail: json['event_thumbnail'] as String?,
      eventAddress: json['event_address'] as String?,
      eventStartDate: DateTime.parse(json['event_start_date'] as String).toLocal(),
      eventEndDate: DateTime.parse(json['event_end_date'] as String).toLocal(),
      status: json['status'] as String?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order_id': orderId,
      'ticket_id': ticketId,
      'ticket_title': ticketTitle,
      'event_id': eventId,
      'event_title': eventTitle,
      'event_thumbnail': eventThumbnail,
      'event_address': eventAddress,
      'event_start_date': eventStartDate.toIso8601String(),
      'event_end_date': eventEndDate.toIso8601String(),
      'status': status,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        ticketId,
        ticketTitle,
        eventId,
        eventTitle,
        eventThumbnail,
        eventAddress,
        eventStartDate,
        eventEndDate,
        status,
        quantity,
        price,
      ];
}