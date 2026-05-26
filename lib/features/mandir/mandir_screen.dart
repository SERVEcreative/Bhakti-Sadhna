import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/services/temple_bell/temple_bell_service.dart';
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
  bool _bellPlaying = false;

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

  Future<void> _ringBell() async {
    if (_bellPlaying) return;
    setState(() => _bellPlaying = true);
    HapticFeedback.mediumImpact();
    await TempleBellService.instance.playWithRetry();
    if (mounted) setState(() => _bellPlaying = false);
  }

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
              _MandirTopBar(playing: _bellPlaying, onBell: _ringBell),
              Expanded(
                child: ClipRect(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeLeft: true,
                    removeRight: true,
                    child: VirtualMandirShrine(
                      deityName: _current.nameHi,
                      photoController: _photoController,
                      photoAssetPaths: _photoAssets,
                      onPhotoPageChanged: _onPhotoPageChanged,
                    ),
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

class _MandirTopBar extends StatelessWidget {
  const _MandirTopBar({
    required this.playing,
    required this.onBell,
  });

  final bool playing;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BhaktiTheme.maroonDeep.withValues(alpha: 0.96),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Row(
          children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BhaktiTheme.goldShimmer,
              border: Border.all(color: BhaktiTheme.gold, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              'ॐ',
              style: BhaktiTheme.displayHi.copyWith(
                fontSize: 20,
                color: BhaktiTheme.maroonDeep,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.mandirTitle,
              style: BhaktiTheme.titleHi.copyWith(fontSize: 20),
            ),
          ),
          IconButton(
            onPressed: playing ? null : onBell,
            tooltip: AppStrings.mandirBellButton,
            style: IconButton.styleFrom(
              backgroundColor: BhaktiTheme.maroon.withValues(alpha: 0.6),
              side: BorderSide(color: BhaktiTheme.gold.withValues(alpha: 0.4)),
            ),
            icon: Icon(
              Icons.notifications_active_rounded,
              color: playing ? BhaktiTheme.saffronLight : BhaktiTheme.goldLight,
            ),
          ),
          ],
        ),
      ),
    );
  }
}
