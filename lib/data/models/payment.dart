import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String status;
  final String? qrCode;
  final String? qrDataUrl;

  const Payment({
    required this.status,
    this.qrCode,
    this.qrDataUrl,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      status: json['status'] as String,
      qrCode: json['qr_code'] as String?,
      qrDataUrl: json['qr_data_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'qr_code': qrCode,
      'qr_data_url': qrDataUrl,
    };
  }

  @override
  List<Object?> get props => [status, qrCode, qrDataUrl];
}