import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String ticketId;
  final String ticketTitle;
  final String eventId;
  final String eventTitle;
  final String eventAddress;
  final String status;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final String createdBy;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final DateTime? updatedAt;
  final String? updatedBy;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.ticketId,
    required this.ticketTitle,
    required this.eventId,
    required this.eventTitle,
    required this.eventAddress,
    required this.status,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.createdBy,
    required this.eventStartDate,
    required this.eventEndDate,
    this.updatedAt,
    this.updatedBy,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(String dateStr) {
      return DateTime.parse(dateStr).toLocal();
    }

    return OrderItem(
      id: json['_id'] as String,
      orderId: json['order_id'] as String,
      ticketId: json['ticket_id'] as String,
      ticketTitle: json['ticket_title'] as String,
      eventId: json['event_id'] as String,
      eventTitle: json['event_title'] as String,
      eventAddress: json['event_address'] as String,
      status: json['status'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      createdAt: parseDateTime(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      eventStartDate: parseDateTime(json['event_start_date'] as String),
      eventEndDate: parseDateTime(json['event_end_date'] as String),
      updatedAt: json['updated_at'] != null ? parseDateTime(json['updated_at'] as String) : null,
      updatedBy: json['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    String? formatDateTime(DateTime? date) {
      if (date == null) return null;
      final offset = const Duration(hours: 7);
      final adjusted = date.toUtc().add(offset);
      return adjusted.toIso8601String();
    }

    return {
      '_id': id,
      'order_id': orderId,
      'ticket_id': ticketId,
      'ticket_title': ticketTitle,
      'event_id': eventId,
      'event_title': eventTitle,
      'event_address': eventAddress,
      'status': status,
      'quantity': quantity,
      'price': price,
      'created_at': formatDateTime(createdAt),
      'created_by': createdBy,
      'event_start_date': formatDateTime(eventStartDate),
      'event_end_date': formatDateTime(eventEndDate),
      'updated_at': formatDateTime(updatedAt),
      'updated_by': updatedBy,
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
        eventAddress,
        status,
        quantity,
        price,
        createdAt,
        createdBy,
        eventStartDate,
        eventEndDate,
        updatedAt,
        updatedBy,
      ];
}