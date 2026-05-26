/// दान — UPI विवरण।
abstract final class DonationConfig {
  /// UPI ID — `--dart-define=DONATION_UPI_ID=...` se override ho sakta hai।
  static const String upiId = String.fromEnvironment(
    'DONATION_UPI_ID',
    defaultValue: 'Q133302176@ybl',
  );

  static const String payeeName = 'भक्ति साधना सेवा';

  static const List<int> presetAmounts = [51, 101, 201, 501, 1101, 2101];

  static bool get hasUpi => upiId.trim().isNotEmpty;
}
