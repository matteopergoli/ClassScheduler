// lib/presentation/settings/subscription_screen.dart
//
// FR-SUB-IAP-01 through FR-SUB-IAP-05
//
// Full-screen paywall shown when:
//   - Trial is consumed and user taps "Subscribe" in the banner
//   - User navigates to Settings → Subscription
//
// Displays:
//   - Annual price (€14.90 / €14.99 depending on store tier)
//   - Feature list (unlimited generation, all other features free)
//   - Purchase button
//   - Restore Purchases link (FR-SUB-IAP-04)
//   - Offline grace-period notice when applicable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/subscription_service.dart';
import '../../l10n/generated/app_localizations.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n    = AppLocalizations.of(context);
    final colors  = AppColors.of(context);
    final subAsync = ref.watch(subscriptionServiceProvider);
    final subState = subAsync.valueOrNull;
    final isActive = subState?.isActive ?? false;
    final loading  = subAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscription),
        backgroundColor: colors.scaffoldBg,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),

              // Headline
              Text(
                isActive
                    ? l10n.subscriptionActive
                    : l10n.subscriptionHeadline,
                style: AppTextStyles.displayMedium.copyWith(
                    color: colors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isActive
                    ? l10n.subscriptionActiveSubtitle
                    : l10n.subscriptionSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Offline grace notice
              if (subState?.status ==
                  SubscriptionStatus.offlineGrace) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.warning.withOpacity(0.10),
                    border: Border.all(
                        color: colors.warning.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd),
                  ),
                  child: Row(children: [
                    Icon(Icons.wifi_off_rounded,
                        color: colors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.subscriptionOfflineGrace,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: colors.warning),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              // Price card
              if (!isActive) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withOpacity(0.15),
                        colors.primaryLight.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: colors.primary.withOpacity(0.3),
                        width: 1.5),
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg),
                  ),
                  child: Column(children: [
                    Text(
                      l10n.subscriptionPriceLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: colors.textMuted,
                          letterSpacing: 0.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.subscriptionPrice,
                      style: AppTextStyles.displayMedium.copyWith(
                          color: colors.primaryLight,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      l10n.subscriptionPriceSuffix,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: colors.textMuted),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
              ],

              // Feature list
              _FeatureList(colors: colors, l10n: l10n),
              const SizedBox(height: 28),

              // Error message
              if (subState?.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.errorBg,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd),
                    border: Border.all(
                        color: colors.error.withOpacity(0.3)),
                  ),
                  child: Text(subState!.errorMessage!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: colors.error),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 16),
              ],

              // Purchase button (hidden if already active)
              if (!isActive)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: loading
                        ? null
                        : () => ref
                            .read(subscriptionServiceProvider
                                .notifier)
                            .purchase(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd),
                      ),
                    ),
                    child: loading
                        ? SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.textMuted),
                          )
                        : Text(l10n.subscribeNow,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: Colors.white)),
                  ),
                ),

              if (isActive) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.success.withOpacity(0.10),
                    border: Border.all(
                        color: colors.success.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: colors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.subscriptionActive,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: colors.success)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Restore purchases
              TextButton(
                onPressed: loading
                    ? null
                    : () => ref
                        .read(subscriptionServiceProvider
                            .notifier)
                        .restore(),
                child: Text(
                  l10n.restorePurchases,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: colors.textMuted,
                      decoration: TextDecoration.underline),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                l10n.subscriptionLegalNote,
                style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feature list ──────────────────────────────────────────────────────────

class _FeatureList extends StatelessWidget {
  final AppColors        colors;
  final AppLocalizations l10n;
  const _FeatureList({required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.bolt_rounded,            l10n.featureUnlimitedGeneration),
      (Icons.picture_as_pdf_outlined, l10n.featurePdfExcel),
      (Icons.edit_outlined,           l10n.featureManualEditing),
      (Icons.cloud_outlined,          l10n.featureCloudSync),
      (Icons.school_outlined,         l10n.featureMultipleSchools),
    ];

    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(f.$1, size: 16, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(f.$2,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary)),
          ),
          Icon(Icons.check_rounded,
              size: 16, color: colors.success),
        ]),
      )).toList(),
    );
  }
}
