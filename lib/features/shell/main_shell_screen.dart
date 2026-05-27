import 'package:bhakti_sadhana/features/donation/donation_screen.dart';
import 'package:bhakti_sadhana/features/home/home_screen.dart';
import 'package:bhakti_sadhana/features/live_darshan/live_darshan_screen.dart';
import 'package:bhakti_sadhana/features/mandir/mandir_screen.dart';
import 'package:bhakti_sadhana/widgets/shell/bhakti_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom nav: पूजा | मंदिर | लाइव दर्शन | दान।
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 1,
    this.highlightCauseId,
  });

  final int initialIndex;
  final String? highlightCauseId;

  @override
  State<MainShellScreen> createState() => MainShellScreenState();
}

class MainShellScreenState extends State<MainShellScreen> {
  late int _index = widget.initialIndex.clamp(0, 3);

  void goToTab(int index) {
    final i = index.clamp(0, 3);
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
          // WebView सिर्फ लाइव टैब पर — दूसरे पेजों पर overflow/bleed नहीं।
          if (_index == 2)
            LiveDarshanScreen(
              key: const ValueKey('live_darshan_tab'),
              inTab: true,
              tabActive: true,
            )
          else
            const SizedBox.shrink(key: ValueKey('live_darshan_off')),
          DonationScreen(inTab: true, highlightCauseId: widget.highlightCauseId),
        ],
      ),
      bottomNavigationBar: BhaktiBottomNavBar(
        currentIndex: _index,
        onTap: goToTab,
      ),
    );
  }
}
