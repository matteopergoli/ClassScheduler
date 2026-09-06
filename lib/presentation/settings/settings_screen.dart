// lib/presentation/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/account_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/cs_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n       = AppLocalizations.of(context);
    final colors     = AppColors.of(context);
    final themeMode  = ref.watch(themeProvider);
    final locale     = ref.watch(localeProvider);
    final trialUsed  = ref.watch(trialUsedProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(l10n.settings,
                style: AppTextStyles.displayMedium
                    .copyWith(color: colors.textPrimary)),
            const SizedBox(height: 24),

            _SectionHeader(title: l10n.appearanceSection, colors: colors),
            _SettingTile(
              label: l10n.language,
              value: _getLanguageName(locale?.languageCode ?? 'en'),
              icon: Icons.translate_rounded,
              colors: colors,
              onTap: () {
                if (locale != null) {
                  _showLanguagePicker(context, ref, locale);
                }
              },
            ),
            _SettingTile(
              label: l10n.theme,
              value: themeMode == ThemeMode.system
                  ? l10n.themeSystem
                  : themeMode == ThemeMode.dark
                      ? l10n.themeDark
                      : l10n.themeLight,
              icon: Icons.dark_mode_outlined,
              colors: colors,
              onTap: () => _showThemePicker(context, ref, themeMode),
            ),

            const SizedBox(height: 24),
            _SectionHeader(title: l10n.account, colors: colors),
            _SettingTile(
              label: l10n.subscription,
              value: l10n.manage,
              icon: Icons.star_outline_rounded,
              colors: colors,
              onTap: () => context.push('/subscription'),
            ),

            const SizedBox(height: 24),
            _SectionHeader(title: l10n.supportSection, colors: colors),
            _SettingTile(
              label: l10n.contactSupport,
              icon: Icons.help_outline_rounded,
              colors: colors,
              onTap: () => _launchUrl('mailto:pergolimatteo@gmail.com'),
            ),

            const SizedBox(height: 32),
            CsButton(
              label: l10n.logOut,
              outline: true,
              onPressed: () => ref.read(authServiceProvider).signOut(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _confirmDeleteAccount(context, ref),
              child: Text(l10n.deleteAccount,
                  style: TextStyle(color: colors.error)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, Locale current) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: _LanguageDialog(
          currentLocale: current,
          onSelect: (langCode) {
            ref.read(localeProvider.notifier).setLocale(Locale(langCode));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode current) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.themeSystem),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.themeLight),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.themeDark),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'it': return 'Italiano';
      case 'en': return 'English';
      default:   return code.toUpperCase();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.actionCannotBeUndone),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => ref.read(authServiceProvider).deleteAccount(),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColors colors;
  const _SectionHeader({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(title.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: colors.textMuted)),
      );
}

class _SettingTile extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final AppColors colors;
  final VoidCallback onTap;

  const _SettingTile({
    required this.label,
    this.value,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderDefault),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: colors.primary, size: 20),
          title: Text(label, style: AppTextStyles.bodyLarge),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null) Text(value!, style: TextStyle(color: colors.textMuted)),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      );
}

class _LanguageDialog extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<String> onSelect;

  const _LanguageDialog({required this.currentLocale, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: const Text('English'), onTap: () => onSelect('en')),
        ListTile(title: const Text('Italiano'), onTap: () => onSelect('it')),
      ],
    );
  }
}