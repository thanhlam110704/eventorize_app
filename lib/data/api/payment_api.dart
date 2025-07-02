import 'package:dio/dio.dart';
import 'package:eventorize_app/core/constants/api_url.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/models/payment.dart';

class PaymentApi {
  final DioClient _dioClient;

  PaymentApi(this._dioClient);

  Future<Payment> generatePayosQr(String orderId) async {
    try {
      final response = await _dioClient.get(
        ApiUrl.generatePayosQr,
        queryParameters: {'order_id': orderId},
      );
      return Payment.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception('Failed to generate PayOS QR code: $errorMessage');
    }
  }
}