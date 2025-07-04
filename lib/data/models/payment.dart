import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String status;
  final String? qrCode;
  final String? qrDataUrl;
  final String? qrId;
  final String? qrStatus;
  final int? amount;
  final int? amountPaid;
  final int? amountRemaining;

  const Payment({
    required this.status,
    this.qrCode,
    this.qrDataUrl,
    this.qrId,
    this.qrStatus,
    this.amount,
    this.amountPaid,
    this.amountRemaining,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      status: json['status'] as String,
      qrCode: json['qr_code'] as String?,
      qrDataUrl: json['qr_data_url'] as String?,
      qrId: json['qr_id'] as String?,
      qrStatus: json['qr_status'] as String?,
      amount: json['amount'] as int?,
      amountPaid: json['amount_paid'] as int?,
      amountRemaining: json['amount_remaining'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'qr_code': qrCode,
      'qr_data_url': qrDataUrl,
      'qr_id': qrId,
      'qr_status': qrStatus,
      'amount': amount,
      'amount_paid': amountPaid,
      'amount_remaining': amountRemaining,
    };
  }

  @override
  List<Object?> get props => [
        status,
        qrCode,
        qrDataUrl,
        qrId,
        qrStatus,
        amount,
        amountPaid,
        amountRemaining,
      ];
}