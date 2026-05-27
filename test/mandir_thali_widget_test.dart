import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/widgets/mandir/mandir_aarti_thali.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MandirAartiThali shows puja_thali asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200,
            child: MandirAartiThali(
              carpetHeight: 120,
              interactionEnabled: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == AssetPaths.mandirPujaThali,
      ),
      findsOneWidget,
    );
  });
}
