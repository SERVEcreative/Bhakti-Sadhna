import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/router/app_router.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BhaktiApp extends StatefulWidget {
  const BhaktiApp({super.key});

  @override
  State<BhaktiApp> createState() => _BhaktiAppState();
}

class _BhaktiAppState extends State<BhaktiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _keepScreenOn(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keepScreenOn(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ऐप सामने हो तो स्क्रीन बंद न हो (मंदिर/पूजा पढ़ते समय)।
    final inApp = state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    _keepScreenOn(inApp);
  }

  void _keepScreenOn(bool on) {
    if (on) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      locale: const Locale('hi', 'IN'),
      theme: BhaktiTheme.dark,
      routerConfig: appRouter,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: BhaktiTheme.maroonDeep,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
