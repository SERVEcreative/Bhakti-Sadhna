import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('puja_thali.png is in asset bundle', () async {
    final data = await rootBundle.load(AssetPaths.mandirPujaThali);
    expect(data.lengthInBytes, greaterThan(1000));
  });
}
