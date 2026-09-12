// lib/core/router/app_router.dart
//
// go_router configuration.
// 5 bottom-nav tabs + auth guard + deep-link support.
// Auth state is watched via authStateProvider (defined in auth_service.dart).

import 'package:classscheduler/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/forgot_password_screen.dart';
import '../../presentation/schools/schools_screen.dart';
import '../../presentation/setup/setup_screen.dart';
import '../../presentation/constraints/constraints_screen.dart';
import '../../presentation/constraints/constraint_form_screen.dart';
import '../../presentation/schedule/schedule_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/shell/main_shell.dart';
import '../../data/models/app_models.dart';
import '../../data/services/analytics_service.dart';

// ── Route names (use these constants for navigation) ────────────────────────
abstract class AppRoutes {
  static const String login          = '/login';
  static const String register       = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String schools        = '/schools';
  static const String setup          = '/setup';
  static const String constraints    = '/constraints';
  static const String schedule       = '/schedule';
  static const String settings       = '/settings';

  // ── Sub-routes (pushed on top of shell) ──────────────────────────────
  static const String _constraintFormBase = '/constraint-form';

  /// Push path for add (id = 'new') or edit (id = existing constraint ID).
  static String constraintForm(String id) => '$_constraintFormBase/$id';
}

class ConstraintFormRouteArgs {
  final String schoolId;
  final ConstraintModel? existing;

  /// Editing a HARD daily limit: these live on ClassroomSubjectModel, not
  /// as a ConstraintModel document (see constraint_form_screen.dart doc),
  /// so they need their own way to open the form pre-filled for editing.
  final ClassroomSubjectModel? existingDailyLimit;

  /// For a NEW constraint: which kind to pre-select ('HARD' | 'SOFT'), taken
  /// from the tab the user is on. Ignored when editing.
  final String? initialKind;

  const ConstraintFormRouteArgs({
    required this.schoolId,
    this.existing,
    this.existingDailyLimit,
    this.initialKind,
  });

  static ConstraintFormRouteArgs? fromExtra(Object? extra) {
    if (extra is ConstraintFormRouteArgs) return extra;
    if (extra is ConstraintModel) {
      return ConstraintFormRouteArgs(
        schoolId: extra.schoolId,
        existing: extra,
      );
    }
    if (extra is String && extra.isNotEmpty) {
      return ConstraintFormRouteArgs(schoolId: extra);
    }
    return null;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Build the GoRouter ONCE. Auth changes are fed to it via a
  // refreshListenable so they only re-run `redirect` — recreating the whole
  // GoRouter on every rebuild tears down the StatefulShellRoute and blanks
  // the screen (e.g. after a locale/theme change).
  final authNotifier = ValueNotifier<AsyncValue<User?>>(const AsyncLoading());
  ref.onDispose(authNotifier.dispose);
  ref.listen<AsyncValue<User?>>(
    authStateProvider,
    (_, next) => authNotifier.value = next,
    fireImmediately: true,
  );

  return GoRouter(
    initialLocation: AppRoutes.schools,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    // Automatic screen_view events feed Firebase's built-in session /
    // engagement / retention reports (KPI #3 — see AnalyticsService).
    observers: [ref.read(analyticsServiceProvider).observer],
    redirect: (context, state) {
      final isLoggedIn = authNotifier.value.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.schools;
      return null;
    },
    routes: [
      // ── Auth routes (no shell) ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (ctx, state) => _fadeTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (ctx, state) => _slideTransition(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),

      // ── Constraint form (add / edit) — pushed on top of shell ──────────
      GoRoute(
        path: '/constraint-form/:id',
        name: 'constraintForm',
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id']!;
          final args = ConstraintFormRouteArgs.fromExtra(state.extra);
          final schoolId = args?.schoolId ?? '';
          final existing = args?.existing;
          final existingDailyLimit = args?.existingDailyLimit;
          return _slideTransition(
            key: state.pageKey,
            child: ConstraintFormScreen(
              schoolId: schoolId,
              existing: existing,
              existingDailyLimit: existingDailyLimit,
              initialKind: args?.initialKind,
            ),
          );
        },
      ),

      // ── Main shell (bottom nav) ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.schools,
              name: 'schools',
              builder: (ctx, state) => const SchoolsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.setup,
              name: 'setup',
              builder: (ctx, state) => const SetupScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.constraints,
              name: 'constraints',
              // ConstraintsScreen prompts for a school itself (like
              // SetupScreen) rather than bouncing to the Schools tab.
              builder: (ctx, state) => const ConstraintsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.schedule,
              name: 'schedule',
              // ScheduleScreen prompts for a school itself (like
              // SetupScreen/ConstraintsScreen) rather than bouncing to the
              // Schools tab.
              builder: (ctx, state) => const ScheduleScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              name: 'settings',
              builder: (ctx, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});

// ── Page transition helpers ──────────────────────────────────────────────────
CustomTransitionPage<void> _fadeTransition({
  required LocalKey key,
  required Widget child,
}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionsBuilder: (ctx, animation, _, c) =>
          FadeTransition(opacity: animation, child: c),
    );

CustomTransitionPage<void> _slideTransition({
  required LocalKey key,
  required Widget child,
}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionsBuilder: (ctx, animation, _, c) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: c),
      ),
    );
