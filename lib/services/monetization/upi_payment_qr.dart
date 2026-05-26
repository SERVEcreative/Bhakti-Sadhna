import 'package:bhakti_sadhana/config/donation_config.dart';

/// UPI QR payload — GPay / PhonePe / Paytm scan se pay.
abstract final class UpiPaymentQr {
  static String buildPayload({
    required String transactionNote,
    required int amountInr,
  }) {
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': DonationConfig.upiId,
        'pn': DonationConfig.payeeName,
        'am': amountInr.toString(),
        'cu': 'INR',
        'tn': transactionNote,
      },
    ).toString();
  }
}
