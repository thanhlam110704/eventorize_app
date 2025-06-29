import 'package:equatable/equatable.dart';

class Ticket extends Equatable {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final int quantity;
  final DateTime startSaleDate;
  final DateTime endSaleDate;
  final int price;
  final int minPerUser;
  final int maxPerUser;
  final String status;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.quantity,
    required this.startSaleDate,
    required this.endSaleDate,
    required this.price,
    required this.minPerUser,
    required this.maxPerUser,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(String dateStr) {
      return DateTime.parse(dateStr).toLocal();
    }

    return Ticket(
      id: json['_id'] as String,
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as int,
      startSaleDate: parseDateTime(json['start_sale_date'] as String),
      endSaleDate: parseDateTime(json['end_sale_date'] as String),
      price: json['price'] as int,
      minPerUser: json['min_per_user'] as int,
      maxPerUser: json['max_per_user'] as int,
      status: json['status'] as String,
      createdAt: parseDateTime(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      updatedAt: json['updated_at'] != null ? parseDateTime(json['updated_at'] as String) : null,
      updatedBy: json['updated_by'] as String?,
      deletedAt: json['deleted_at'] != null ? parseDateTime(json['deleted_at'] as String) : null,
      deletedBy: json['deleted_by'] as String?,
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
      'event_id': eventId,
      'title': title,
      'description': description,
      'quantity': quantity,
      'start_sale_date': formatDateTime(startSaleDate),
      'end_sale_date': formatDateTime(endSaleDate),
      'price': price,
      'min_per_user': minPerUser,
      'max_per_user': maxPerUser,
      'status': status,
      'created_at': formatDateTime(createdAt),
      'created_by': createdBy,
      'updated_at': formatDateTime(updatedAt),
      'updated_by': updatedBy,
      'deleted_at': formatDateTime(deletedAt),
      'deleted_by': deletedBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        title,
        description,
        quantity,
        startSaleDate,
        endSaleDate,
        price,
        minPerUser,
        maxPerUser,
        status,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];
}