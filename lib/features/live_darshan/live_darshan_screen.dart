import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/live_temple.dart';
import 'package:bhakti_sadhana/data/repositories/live_darshan_repository.dart';
import 'package:bhakti_sadhana/config/live_darshan_config.dart';
import 'package:bhakti_sadhana/widgets/live_darshan/live_darshan_player_panel.dart';
import 'package:bhakti_sadhana/widgets/temple_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bhakti_sadhana/services/live_darshan/youtube_launcher.dart';

/// भारत के प्रसिद्ध मंदिरों का लाइव दर्शन (YouTube एम्बेड)।
class LiveDarshanScreen extends StatefulWidget {
  const LiveDarshanScreen({
    super.key,
    this.inTab = false,
    this.tabActive = true,
  });

  final bool inTab;
  final bool tabActive;

  @override
  State<LiveDarshanScreen> createState() => _LiveDarshanScreenState();
}

class _LiveDarshanScreenState extends State<LiveDarshanScreen> {
  List<LiveTemple>? _temples;
  var _selectedIndex = 0;
  var _loadError = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LiveDarshanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabActive && !oldWidget.tabActive) {
      _load(refresh: true);
    }
  }

  Future<void> _load({bool refresh = false}) async {
    try {
      final list =
          await LiveDarshanRepository.instance.loadTemples(refresh: refresh);
      if (!mounted) return;
      setState(() {
        _temples = list;
        _loadError = list.isEmpty;
        if (_selectedIndex >= list.length) {
          _selectedIndex = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = true);
    }
  }

  Future<void> _openExternal(LiveTemple temple) async {
    final ok = await YoutubeLauncher.openUrl(temple.openUrl);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.liveDarshanOpenError,
            style: BhaktiTheme.bodyHi,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TempleScaffold(
      title: AppStrings.liveDarshanTitle,
      showBackButton: !widget.inTab,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_temples == null) {
      return const Center(
        child: CircularProgressIndicator(color: BhaktiTheme.saffron),
      );
    }
    if (_loadError || _temples!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppStrings.errorLoadContent,
            textAlign: TextAlign.center,
            style: BhaktiTheme.bodyHi,
          ),
        ),
      );
    }

    final temples = _temples!;
    final selected = temples[_selectedIndex.clamp(0, temples.length - 1)];
    const playerToolbarHeight = 42.0;
    final videoHeight = (MediaQuery.sizeOf(context).width - 32) * 9 / 16;
    final playerHeight = videoHeight + playerToolbarHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: _LivePlayerFrame(
            height: playerHeight,
            child: LiveDarshanPlayerPanel(
              key: ValueKey(selected.id),
              temple: selected,
              pollWhenVisible: widget.tabActive,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: BhaktiTheme.saffron,
            onRefresh: () => _load(refresh: true),
            child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const _LiveHeroBanner(),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.liveDarshanPickTemple,
                    style: BhaktiTheme.titleHi.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 116,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: temples.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final t = temples[index];
                        return _TemplePickCard(
                          temple: t,
                          selected: index == _selectedIndex,
                          onTap: () {
                            if (_selectedIndex == index) return;
                            HapticFeedback.selectionClick();
                            setState(() => _selectedIndex = index);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _TempleInfoCard(temple: selected),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openExternal(selected),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(
                        AppStrings.liveDarshanOpenYoutube,
                        overflow: TextOverflow.ellipsis,
                        style: BhaktiTheme.titleHi.copyWith(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BhaktiTheme.goldLight,
                        side: BorderSide(
                          color: BhaktiTheme.gold.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  if (!LiveDarshanConfig.hasYoutubeApiKey) ...[
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.liveDarshanApiKeyHint,
                      textAlign: TextAlign.center,
                      style: BhaktiTheme.labelSub.copyWith(
                        fontSize: 11,
                        color: BhaktiTheme.saffron.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.liveDarshanDisclaimer,
                    textAlign: TextAlign.center,
                    style: BhaktiTheme.labelSub.copyWith(
                      fontSize: 11,
                      color: BhaktiTheme.cream.withValues(alpha: 0.55),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
        ),
      ],
    );
  }
}

class _LivePlayerFrame extends StatelessWidget {
  const _LivePlayerFrame({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: BhaktiTheme.gold.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: BhaktiTheme.diyaGlow.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LiveHeroBanner extends StatelessWidget {
  const _LiveHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B1E14),
            Color(0xFF3A0C0C),
            Color(0xFF240606),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.liveDarshanLiveBadge,
                style: BhaktiTheme.labelSub.copyWith(
                  color: const Color(0xFFFF8A80),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.liveDarshanHeroTitle,
            textAlign: TextAlign.center,
            style: BhaktiTheme.displayHi.copyWith(
              fontSize: 22,
              color: BhaktiTheme.saffronLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.liveDarshanHeroSubtitle,
            textAlign: TextAlign.center,
            style: BhaktiTheme.bodyHi.copyWith(
              fontSize: 13,
              color: BhaktiTheme.cream.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplePickCard extends StatelessWidget {
  const _TemplePickCard({
    required this.temple,
    required this.selected,
    required this.onTap,
  });

  final LiveTemple temple;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 132,
          height: 116,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF7A3018), Color(0xFF4A1414)],
                  )
                : null,
            color: selected ? null : BhaktiTheme.maroon.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? BhaktiTheme.goldLight.withValues(alpha: 0.7)
                  : BhaktiTheme.gold.withValues(alpha: 0.2),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.temple_hindu_rounded,
                size: 20,
                color: selected
                    ? BhaktiTheme.goldLight
                    : BhaktiTheme.cream.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      temple.nameHi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BhaktiTheme.titleHi.copyWith(
                        fontSize: 11,
                        height: 1.2,
                        color: selected
                            ? BhaktiTheme.goldLight
                            : BhaktiTheme.cream.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      temple.locationHi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BhaktiTheme.labelSub.copyWith(
                        fontSize: 9,
                        height: 1.15,
                        color: BhaktiTheme.cream.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TempleInfoCard extends StatelessWidget {
  const _TempleInfoCard({required this.temple});

  final LiveTemple temple;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BhaktiTheme.maroonDeep.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            temple.nameHi,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: BhaktiTheme.titleHi.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          _InfoRow(Icons.place_outlined, temple.locationHi),
          const SizedBox(height: 4),
          _InfoRow(Icons.auto_awesome, temple.deityHi),
          if (temple.sourceHi != null) ...[
            const SizedBox(height: 8),
            Text(
              temple.sourceHi!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: BhaktiTheme.labelSub.copyWith(
                fontSize: 11,
                color: BhaktiTheme.cream.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: BhaktiTheme.saffron.withValues(alpha: 0.85)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: BhaktiTheme.bodyHi.copyWith(
              fontSize: 13,
              color: BhaktiTheme.cream.withValues(alpha: 0.78),
            ),
          ),
        ),
      ],
    );
  }
}
