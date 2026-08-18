// lib/core/router/app_router.dart
//
// go_router configuration.
// 5 bottom-nav tabs + auth guard + deep-link support.
// Auth state is watched via authStateProvider (defined in auth_service.dart).

import 'package:classscheduler/providers/auth_providers.dart';
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
import '../../providers/selected_school_provider.dart';

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

  const ConstraintFormRouteArgs({
    required this.schoolId,
    this.existing,
    this.existingDailyLimit,
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
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.schools,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
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
              builder: (ctx, state) => Consumer(
                builder: (ctx, ref, _) {
                  final schoolId =
                      ref.watch(selectedSchoolIdProvider) ?? '';
                  return schoolId.isEmpty
                      ? const _NoSchoolSelectedScreen()
                      : ScheduleScreen(schoolId: schoolId);
                },
              ),
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

class _NoSchoolSelectedScreen extends StatelessWidget {
  const _NoSchoolSelectedScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.school_outlined, size: 64, color: Color(0xFF64748B)),
        const SizedBox(height: 16),
        const Text('No school selected',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Go to the Schools tab and tap a school.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go(AppRoutes.schools),
          child: const Text('Go to Schools'),
        ),
      ]),
    )),
  );
}
