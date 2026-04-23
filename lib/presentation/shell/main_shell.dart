// lib/presentation/shell/main_shell.dart
//
// Persistent bottom navigation shell wrapping the 5 main sections.
// Uses NavigationBar (Material 3) with custom dark/light styling.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(icon: Icons.school_outlined,      activeIcon: Icons.school,           label: l10n.navSchools),
      _NavItem(icon: Icons.tune_outlined,         activeIcon: Icons.tune,             label: l10n.navSetup),
      _NavItem(icon: Icons.lock_outline_rounded,  activeIcon: Icons.lock_rounded,     label: l10n.navConstraints),
      _NavItem(icon: Icons.calendar_month_outlined,activeIcon: Icons.calendar_month,  label: l10n.navSchedule),
      _NavItem(icon: Icons.settings_outlined,     activeIcon: Icons.settings,         label: l10n.navSettings),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.navBarBg,
          border: Border(
            top: BorderSide(color: colors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item    = items[i];
                final active  = navigationShell.currentIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => navigationShell.goBranch(
                      i,
                      initialLocation: i == navigationShell.currentIndex,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Active indicator dot
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: active ? 4 : 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: active
                                  ? colors.primaryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            active ? item.activeIcon : item.icon,
                            size: 22,
                            color: active ? colors.primaryLight : colors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: active ? colors.primaryLight : colors.textMuted,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
