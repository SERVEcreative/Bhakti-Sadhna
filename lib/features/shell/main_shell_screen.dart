import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/features/donation/donation_screen.dart';
import 'package:bhakti_sadhana/features/home/home_screen.dart';
import 'package:bhakti_sadhana/features/mandir/mandir_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom nav: बाएँ पूजा | बीच मंदिर | दाएँ दान।
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.highlightCauseId,
  });

  final int initialIndex;
  final String? highlightCauseId;

  @override
  State<MainShellScreen> createState() => MainShellScreenState();
}

class MainShellScreenState extends State<MainShellScreen> {
  late int _index = widget.initialIndex.clamp(0, 2);

  void goToTab(int index) {
    final i = index.clamp(0, 2);
    if (_index == i) return;
    setState(() => _index = i);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          MandirScreen(tabActive: _index == 1),
          DonationScreen(inTab: true, highlightCauseId: widget.highlightCauseId),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: BhaktiTheme.maroonDeep,
          border: Border(
            top: BorderSide(color: BhaktiTheme.gold.withValues(alpha: 0.35)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: goToTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: BhaktiTheme.goldLight,
            unselectedItemColor: BhaktiTheme.cream.withValues(alpha: 0.55),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: BhaktiTheme.titleHi.copyWith(fontSize: 12),
            unselectedLabelStyle: BhaktiTheme.labelSub.copyWith(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism_outlined),
                activeIcon: Icon(Icons.volunteer_activism_rounded),
                label: AppStrings.navPuja,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.temple_hindu_outlined),
                activeIcon: Icon(Icons.temple_hindu_rounded),
                label: AppStrings.navMandir,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: AppStrings.navDaan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
