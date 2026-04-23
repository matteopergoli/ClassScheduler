// lib/data/services/subscription_service.dart
//
// FR-SUB-IAP-01 through FR-SUB-IAP-05
//
// Wraps RevenueCat (purchases_flutter) to provide:
//   - Initialisation at app launch
//   - Subscription status stream (active / expired / unknown)
//   - Purchase flow
//   - Restore purchases
//   - 30-day offline grace period (FR-SUB-IAP-03)
//
// Exposed via Riverpod providers consumed by TrialBanner,
// SubscriptionScreen, and GenerationService.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

// ── Subscription status ───────────────────────────────────────────────────

enum SubscriptionStatus {
  /// Verified active subscription.
  active,
  /// No active subscription and no offline grace period remaining.
  inactive,
  /// Could not verify online; honouring cached status for ≤30 days.
  offlineGrace,
  /// Not yet determined (loading).
  unknown,
}

class SubscriptionState {
  final SubscriptionStatus status;
  final DateTime?          expiresAt;
  final String?            productId;
  final String?            errorMessage;

  const SubscriptionState({
    this.status       = SubscriptionStatus.unknown,
    this.expiresAt,
    this.productId,
    this.errorMessage,
  });

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.offlineGrace;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    DateTime?           expiresAt,
    String?             productId,
    String?             errorMessage,
  }) =>
      SubscriptionState(
        status:       status       ?? this.status,
        expiresAt:    expiresAt    ?? this.expiresAt,
        productId:    productId    ?? this.productId,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Provider ─────────────────────────────────────────────────────────────

final subscriptionServiceProvider =
    StateNotifierProvider<SubscriptionService, AsyncValue<SubscriptionState>>(
  (ref) => SubscriptionService(),
);

const _kLastKnownActive = 'sub_last_known_active';
const _kLastCheckedAt   = 'sub_last_checked_at';

class SubscriptionService extends StateNotifier<AsyncValue<SubscriptionState>> {
  SubscriptionService() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _initRevenueCat();
    try {
      final result = await _checkStatus();
      if (mounted) state = AsyncValue.data(result);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  static bool _configured = false;

  Future<void> _initRevenueCat() async {
    if (_configured) return;
    try {
      final apiKey = Platform.isIOS
          ? AppConstants.rcApiKeyIos
          : AppConstants.rcApiKeyAndroid;
      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
      _configured = true;
    } catch (_) {
      // RevenueCat init failed (e.g. placeholder keys) — continue without IAP
    }
  }

  Future<SubscriptionState> _checkStatus() async {
    try {
      final info        = await Purchases.getCustomerInfo();
      final entitlement = info.entitlements.active[AppConstants.rcEntitlementId];
      final isActive    = entitlement != null;
      final expiresAt   = entitlement?.expirationDate != null
          ? DateTime.tryParse(entitlement!.expirationDate!) : null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kLastKnownActive, isActive);
      await prefs.setString(_kLastCheckedAt, DateTime.now().toIso8601String());

      return SubscriptionState(
        status:    isActive ? SubscriptionStatus.active : SubscriptionStatus.inactive,
        expiresAt: expiresAt,
        productId: entitlement?.productIdentifier,
      );
    } catch (_) {
      return _offlineFallback();
    }
  }

  Future<SubscriptionState> _offlineFallback() async {
    final prefs          = await SharedPreferences.getInstance();
    final lastActive     = prefs.getBool(_kLastKnownActive) ?? false;
    final lastCheckedStr = prefs.getString(_kLastCheckedAt);
    if (!lastActive || lastCheckedStr == null) {
      return const SubscriptionState(status: SubscriptionStatus.inactive);
    }
    final lastChecked = DateTime.tryParse(lastCheckedStr);
    if (lastChecked == null) {
      return const SubscriptionState(status: SubscriptionStatus.inactive);
    }
    final daysSince = DateTime.now().difference(lastChecked).inDays;
    return daysSince <= AppConstants.subscriptionOfflineDays
        ? const SubscriptionState(status: SubscriptionStatus.offlineGrace)
        : const SubscriptionState(status: SubscriptionStatus.inactive);
  }

  Future<void> purchase() async {
    state = const AsyncValue.loading();
    try {
      final offerings = await Purchases.getOfferings();
      final pkg = offerings.current?.availablePackages
          .where((p) => p.storeProduct.identifier == AppConstants.rcProductId)
          .firstOrNull ?? offerings.current?.annual;
      if (pkg == null) throw Exception('Subscription product not found.');
      await Purchases.purchasePackage(pkg);
      final result = await _checkStatus();
      if (mounted) state = AsyncValue.data(result);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        final result = await _checkStatus();
        if (mounted) state = AsyncValue.data(result);
      } else {
        if (mounted) {
          state = AsyncValue.data(SubscriptionState(
          status: SubscriptionStatus.inactive,
          errorMessage: _rcErrorMessage(e),
        ));
        }
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.data(SubscriptionState(
        status: SubscriptionStatus.inactive,
        errorMessage: e.toString(),
      ));
      }
    }
  }

  Future<void> restore() async {
    state = const AsyncValue.loading();
    try {
      await Purchases.restorePurchases();
      final result = await _checkStatus();
      if (mounted) state = AsyncValue.data(result);
    } catch (e) {
      if (mounted) {
        state = AsyncValue.data(SubscriptionState(
        status: SubscriptionStatus.inactive,
        errorMessage: e.toString(),
      ));
      }
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final result = await _checkStatus();
      if (mounted) state = AsyncValue.data(result);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  String _rcErrorMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device.';
      default:
        return 'Purchase failed. Please try again.';
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
