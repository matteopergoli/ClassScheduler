// lib/data/services/analytics_service.dart
//
// Thin wrapper around FirebaseAnalytics for the KPIs used to decide when the
// app has enough of an audience to justify going paid / opening a partita
// IVA: sign-ups/logins (reach), successful schedule generation (activation),
// same-school regeneration (short-term retention proxy), distinct schools
// touched (multi-tenant signal), and premium-interest taps (fake-door
// willingness-to-pay signal shown while AppConstants.subscriptionsEnabled is
// false). Screen views (session/engagement data feeding Firebase's built-in
// retention reports) are collected via the `observer` wired into GoRouter.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService());

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logSignUp(String method) => _safeLog(
        () => _analytics.logSignUp(signUpMethod: method),
      );

  Future<void> logLogin(String method) => _safeLog(
        () => _analytics.logLogin(loginMethod: method),
      );

  Future<void> logSchoolCreated(String schoolId) => _safeLog(
        () => _analytics.logEvent(
          name: 'school_created',
          parameters: {'school_id': schoolId},
        ),
      );

  /// Logged after every real schedule-generation attempt. `priorScheduleCount`
  /// (schedules that already existed for this school before this attempt)
  /// lets activation (first success) be told apart from same-year retention
  /// (a later attempt on a school that already had one) downstream.
  Future<void> logScheduleGenerated({
    required String schoolId,
    required bool success,
    required String status,
    required int priorScheduleCount,
  }) =>
      _safeLog(
        () => _analytics.logEvent(
          name: 'schedule_generated',
          parameters: {
            'school_id': schoolId,
            'success': success ? 1 : 0,
            'status': status,
            'is_regeneration': priorScheduleCount > 0 ? 1 : 0,
          },
        ),
      );

  Future<void> logPremiumInterest(String source) => _safeLog(
        () => _analytics.logEvent(
          name: 'premium_interest_tap',
          parameters: {'source': source},
        ),
      );

  /// Analytics is instrumentation, never allowed to break the feature it's
  /// observing — swallow any failure (e.g. no network) silently.
  Future<void> _safeLog(Future<void> Function() call) async {
    try {
      await call();
    } catch (_) {}
  }
}
