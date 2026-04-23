// lib/presentation/widgets/trial_banner.dart
//
// FR-TRIAL-IND-01, FR-TRIAL-IND-02.
//
// Shown persistently on the Schedule tab (and optionally Schools screen).
// Three display modes determined by subscription + trial state:
//
//   1. User has active subscription           → hidden (no banner)
//   2. Trial not yet used                     → "1 free generation remaining"
//      (dismissible, re-appears on next session)
//   3. Trial used, no subscription            → "Trial used. Subscribe."
//      (persistent, cannot be dismissed, Generate button disabled elsewhere)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/services/subscription_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../settings/subscription_screen.dart';

class TrialBanner extends ConsumerStatefulWidget {
  const TrialBanner({super.key});

  @override
  ConsumerState<TrialBanner> createState() => _TrialBannerState();
}

class _TrialBannerState extends ConsumerState<TrialBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context);
    final colors   = AppColors.of(context);
    final trialUsed = ref.watch(trialUsedProvider);
    final subAsync  = ref.watch(subscriptionServiceProvider);
    final isActive  = subAsync.valueOrNull?.isActive ?? false;

    // Subscribed users see no banner
    if (isActive) return const SizedBox.shrink();

    // Trial unused and dismissed by user → hide until next session
    if (!trialUsed && _dismissed) return const SizedBox.shrink();

    final bannerColor  = trialUsed ? colors.error : colors.primaryLight;
    final bannerBg     = trialUsed
        ? colors.error.withOpacity(0.10)
        : colors.trialBg;
    final bannerBorder = trialUsed
        ? colors.error.withOpacity(0.25)
        : colors.trialBorder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bannerBg,
          border: Border.all(color: bannerBorder),
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(children: [
          Text(
            trialUsed ? '🔒' : '✨',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trialUsed
                      ? l10n.trialBannerUsed
                      : l10n.trialBannerRemaining,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: bannerColor),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => _openSubscription(context),
                  child: Text(
                    l10n.subscribeForUnlimited,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: colors.textPlaceholder,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
          // Dismiss (only when trial not yet used)
          if (!trialUsed)
            GestureDetector(
              onTap: () => setState(() => _dismissed = true),
              child: Icon(Icons.close_rounded,
                  size: 16, color: colors.textPlaceholder),
            ),
        ]),
      ),
    );
  }

  void _openSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const SubscriptionScreen()),
    );
  }
}
