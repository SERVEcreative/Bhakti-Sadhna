/// दान — UPI / संस्था विवरण (भविष्य में भरें)।
abstract final class DonationConfig {
  /// UPI ID — खाली हो तो ऐप सिर्फ विवरण कॉपी करेगा।
  static const String upiId = '';

  static const String payeeName = 'भक्ति साधना सेवा';

  static const List<int> presetAmounts = [51, 101, 201, 501, 1101, 2101];

  static bool get hasUpi => upiId.trim().isNotEmpty;
}
