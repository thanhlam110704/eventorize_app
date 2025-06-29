import 'package:equatable/equatable.dart';
import 'package:eventorize_app/data/models/order_item.dart';

class Order extends Equatable {
  final String id;
  final String orderNo;
  final String status;
  final int amount;
  final int? discountAmount;
  final double taxRate;
  final double vatAmount;
  final double totalAmount;
  final String? promotionCode;
  final String? notes;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final List<OrderItem> orderItems;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  const Order({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.amount,
    this.discountAmount,
    required this.taxRate,
    required this.vatAmount,
    required this.totalAmount,
    this.promotionCode,
    this.notes,
    this.userName,
    this.userEmail,
    this.userPhone,
    required this.orderItems,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(String dateStr) {
      return DateTime.parse(dateStr).toLocal();
    }

    return Order(
      id: json['_id'] as String,
      orderNo: json['order_no'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      discountAmount: json['discount_amount'] as int?,
      taxRate: (json['tax_rate'] as num).toDouble(),
      vatAmount: (json['vat_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      promotionCode: json['promotion_code'] as String?,
      notes: json['notes'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      userPhone: json['user_phone'] as String?,
      orderItems: (json['order_items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
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
      'order_no': orderNo,
      'status': status,
      'amount': amount,
      'discount_amount': discountAmount,
      'tax_rate': taxRate,
      'vat_amount': vatAmount,
      'total_amount': totalAmount,
      'promotion_code': promotionCode,
      'notes': notes,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'order_items': orderItems.map((item) => item.toJson()).toList(),
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
        orderNo,
        status,
        amount,
        discountAmount,
        taxRate,
        vatAmount,
        totalAmount,
        promotionCode,
        notes,
        userName,
        userEmail,
        userPhone,
        orderItems,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        deletedAt,
        deletedBy,
      ];
}