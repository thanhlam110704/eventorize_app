import 'package:eventorize_app/data/api/payment_api.dart';
import 'package:eventorize_app/data/models/payment.dart';

class PaymentRepository {
  final PaymentApi _paymentApi;

  PaymentRepository(this._paymentApi);

  Future<Payment> generatePayosQr(String orderId) async {
    return await _paymentApi.generatePayosQr(orderId);
  }
}