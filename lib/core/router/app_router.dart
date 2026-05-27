import 'package:bhakti_sadhana/features/category/deity_select_screen.dart';
import 'package:bhakti_sadhana/features/content/worship_content_screen.dart';
import 'package:bhakti_sadhana/features/shell/main_shell_screen.dart';
import 'package:bhakti_sadhana/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

int _shellTabIndex(Uri uri) {
  final tab = uri.queryParameters['tab'];
  return switch (tab) {
    'puja' || 'home' => 0,
    'mandir' => 1,
    'live' || 'darshan' || 'live-darshan' => 2,
    'daan' || 'donation' => 3,
    _ => 1,
  };
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: MainShellScreen(
          initialIndex: _shellTabIndex(state.uri),
          highlightCauseId: state.uri.queryParameters['cause'],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/donation',
      redirect: (context, state) {
        final cause = state.uri.queryParameters['cause'];
        if (cause != null && cause.isNotEmpty) {
          return '/?tab=daan&cause=$cause';
        }
        return '/?tab=daan';
      },
    ),
    GoRoute(
      path: '/select/:categoryId',
      pageBuilder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: DeitySelectScreen(categoryId: categoryId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/content/:categoryId/:deityId',
      pageBuilder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        final deityId = state.pathParameters['deityId']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: WorshipContentScreen(
            categoryId: categoryId,
            deityId: deityId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
