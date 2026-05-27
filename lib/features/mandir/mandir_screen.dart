import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/widgets/mandir/mandir_top_bar.dart';
import 'package:bhakti_sadhana/widgets/mandir/virtual_mandir_shrine.dart';
import 'package:bhakti_sadhana/widgets/temple_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _MandirDeity {
  const _MandirDeity(this.id, this.nameHi);
  final String id;
  final String nameHi;
}

/// मंदिर फिक्स — सिर्फ गर्भगृह की फोटो स्वाइप से बदलती है।
class MandirScreen extends StatefulWidget {
  const MandirScreen({super.key, this.tabActive = true});

  /// मंदिर टैब दिख रहा हो तभी आरती थाली चले।
  final bool tabActive;

  @override
  State<MandirScreen> createState() => _MandirScreenState();
}

class _MandirScreenState extends State<MandirScreen> {
  static const _deities = [
    _MandirDeity('balaji', 'श्री बालाजी'),
    _MandirDeity('shiva', 'श्री शिव'),
    _MandirDeity('krishna', 'श्री कृष्ण'),
    _MandirDeity('ganesh', 'श्री गणेश'),
    _MandirDeity('lakshmi', 'श्री लक्ष्मी'),
    _MandirDeity('ram', 'श्री राम'),
    _MandirDeity('radha', 'श्री राधा'),
    _MandirDeity('vishnu', 'श्री विष्णु'),
    _MandirDeity('kali', 'माँ काली'),
    _MandirDeity('shani', 'श्री शनि'),
  ];

  late final PageController _photoController;
  late final List<String> _photoAssets;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
    _photoAssets = _deities.map((d) => AssetPaths.deityImage(d.id)).toList();
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  _MandirDeity get _current => _deities[_pageIndex];

  void _onPhotoPageChanged(int index) {
    if (_pageIndex == index) return;
    setState(() => _pageIndex = index);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TempleBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MandirTopBar(
                deityName: _current.nameHi,
                deityImagePath: _photoAssets[_pageIndex],
                pageIndex: _pageIndex,
                totalCount: _deities.length,
              ),
              Expanded(
                child: MediaQuery.removePadding(
                    context: context,
                    removeLeft: true,
                    removeRight: true,
                    child: VirtualMandirShrine(
                      photoController: _photoController,
                      photoAssetPaths: _photoAssets,
                      onPhotoPageChanged: _onPhotoPageChanged,
                      thaliInteractionEnabled: widget.tabActive,
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
