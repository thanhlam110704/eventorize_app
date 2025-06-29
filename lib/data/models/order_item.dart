import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String ticketId;
  final String status;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.ticketId,
    required this.status,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.createdBy,
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
      status: json['status'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      createdAt: parseDateTime(json['created_at'] as String),
      createdBy: json['created_by'] as String,
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
      'status': status,
      'quantity': quantity,
      'price': price,
      'created_at': formatDateTime(createdAt),
      'created_by': createdBy,
      'updated_at': formatDateTime(updatedAt),
      'updated_by': updatedBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        ticketId,
        status,
        quantity,
        price,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
      ];
}