import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/widgets/temple_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TempleScaffold extends StatelessWidget {
  const TempleScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingAction,
  });

  final String title;
  final Widget body;
  final Widget? floatingAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: floatingAction,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(title, style: BhaktiTheme.titleHi.copyWith(fontSize: 20)),
      ),
      body: TempleBackground(
        child: SafeArea(
          child: body,
        ),
      ),
    );
  }
}
