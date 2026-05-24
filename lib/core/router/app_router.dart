import 'package:bhakti_sadhana/features/donation/donation_screen.dart';
import 'package:bhakti_sadhana/features/category/deity_select_screen.dart';
import 'package:bhakti_sadhana/features/content/worship_content_screen.dart';
import 'package:bhakti_sadhana/features/home/home_screen.dart';
import 'package:bhakti_sadhana/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/donation',
      pageBuilder: (context, state) {
        final causeId = state.uri.queryParameters['cause'];
        return CustomTransitionPage(
          key: state.pageKey,
          child: DonationScreen(highlightCauseId: causeId),
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
