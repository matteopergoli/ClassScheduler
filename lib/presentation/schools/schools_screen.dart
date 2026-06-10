// lib/presentation/schools/schools_screen.dart
//
// FR-SCH-01, FR-SCH-02, FR-SCH-03.
// Matches the ClassScheduler_Homepage.jsx mockup exactly:
//   - School cards with gradient accent bar, quality ring, feasibility bar
//   - Trial status banner (FR-TRIAL-IND-01/02)
//   - FAB to create new school
//   - Long-press / swipe for rename, duplicate, delete

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/school_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/quality_ring.dart';
import '../widgets/trial_banner.dart';
import 'school_form_sheet.dart';
import '../../providers/selected_school_provider.dart';

class SchoolsScreen extends ConsumerWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n    = AppLocalizations.of(context);
    final colors  = AppColors.of(context);
    final schools = ref.watch(schoolsStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadH, 20,
                    AppDimensions.screenPadH, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.goodMorning,
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: colors.textPlaceholder,
                                  letterSpacing: 0.06,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('ClassScheduler',
                              style: AppTextStyles.displayLarge.copyWith(
                                  color: colors.textPrimary)),
                        ],
                      ),
                    ),
                    // Add school button
                    _GradientFab(
                      onTap: () => _showCreateSheet(context, ref),
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ),

            // ── Trial banner ─────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    AppDimensions.screenPadH, 20,
                    AppDimensions.screenPadH, 0),
                child: TrialBanner(),
              ),
            ),

            // ── Section header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadH, 24,
                    AppDimensions.screenPadH, 12),
                child: schools.when(
                  data: (list) => Text(
                    l10n.yourSchoolsCount(list.length),
                    style: AppTextStyles.overline
                        .copyWith(color: colors.textMuted),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── School cards ─────────────────────────────────────────────
            schools.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text(e.toString())),
              ),
              data: (list) => list.isEmpty
                  ? SliverToBoxAdapter(child: _EmptyState(l10n: l10n, colors: colors))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.screenPadH),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppDimensions.cardGap),
                            child: SchoolCard(
                              school: list[i],
                              paletteIndex: i,
                              onGenerate: () {
                              ref.read(selectedSchoolIdProvider.notifier)
                                  .state = list[i].id;
                              context.go('/schedule');
                            },
                              onOptions: () => _showOptions(
                                  context, ref, list[i]),
                            ),
                          ),
                          childCount: list.length,
                        ),
                      ),
                    ),
            ),

            // ── Add school dashed card ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadH, 4,
                    AppDimensions.screenPadH, 32),
                child: _DashedAddCard(
                  label: l10n.addSchool,
                  colors: colors,
                  onTap: () => _showCreateSheet(context, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SchoolFormSheet(
        onSave: (name, desc) async {
          await ref.read(schoolRepositoryProvider).create(
                name: name,
                description: desc,
              );
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, SchoolModel school) {
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.edit_outlined,
              label: l10n.renameSchool,
              colors: colors,
              onTap: () {
                Navigator.pop(context);
                _showRenameSheet(context, ref, school);
              },
            ),
            _OptionTile(
              icon: Icons.copy_outlined,
              label: l10n.duplicateSchool,
              colors: colors,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(schoolRepositoryProvider).duplicate(school);
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: l10n.deleteSchool,
              colors: colors,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, school);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRenameSheet(
      BuildContext context, WidgetRef ref, SchoolModel school) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SchoolFormSheet(
        initialName: school.name,
        initialDescription: school.description,
        onSave: (name, description) async {
          await ref
              .read(schoolRepositoryProvider)
              .updateNameAndDescription(school.id, name, description);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, SchoolModel school) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSchool),
        content: Text(l10n.deleteSchoolConfirm(school.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(schoolRepositoryProvider).delete(school.id);
              if (context.mounted) context.go('/schools');
            },
            child: Text(l10n.delete,
                style: TextStyle(
                    color: AppColors.of(context).error)),
          ),
        ],
      ),
    );
  }
}

// ── Riverpod stream provider ────────────────────────────────────────────────
final schoolsStreamProvider = StreamProvider<List<SchoolModel>>((ref) {
  return ref.watch(schoolRepositoryProvider).watchAll();
});

// ── SchoolCard ───────────────────────────────────────────────────────────────
class SchoolCard extends StatefulWidget {
  final SchoolModel school;
  final int paletteIndex;
  final VoidCallback onGenerate;
  final VoidCallback onOptions;

  const SchoolCard({
    super.key,
    required this.school,
    required this.paletteIndex,
    required this.onGenerate,
    required this.onOptions,
  });

  @override
  State<SchoolCard> createState() => _SchoolCardState();
}

class _SchoolCardState extends State<SchoolCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors  = AppColors.of(context);
    final palette = colors.palettes[widget.paletteIndex % colors.palettes.length];
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: _hovered ? colors.cardBgHovered : colors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(
            color: _hovered ? colors.borderHovered : colors.borderDefault,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          child: Stack(
            children: [
              // Gradient accent bar at top
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: palette),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.cardPaddingH, 20,
                    AppDimensions.cardPaddingH, AppDimensions.cardPaddingV),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: status badge + quality ring
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatusBadge(school: widget.school, colors: colors),
                              const SizedBox(height: 6),
                              Text(widget.school.name,
                                  style: AppTextStyles.headingLarge.copyWith(
                                      color: colors.textPrimary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              if (widget.school.description != null &&
                                  widget.school.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.school.description!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.textMuted),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        QualityRing(score: null, size: 52, palette: palette),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats row
                    Row(
                      children: [
                        _StatCol(label: 'Last run',
                            value: widget.school.updatedAt
                                .toLocal()
                                .toString()
                                .substring(0, 10)),
                        const SizedBox(width: 20),
                        const _StatCol(label: 'Updated', value: '—'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _GradientCardButton(
                            label: '⚡ Generate',
                            palette: palette,
                            onTap: widget.onGenerate,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _OptionsButton(
                          colors: colors,
                          onTap: widget.onOptions,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final SchoolModel school;
  final AppColors colors;
  const _StatusBadge({required this.school, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = colors.textMuted;
    final bg    = colors.borderSubtle;
    const label = 'Draft';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                  color: color, letterSpacing: 0.04)),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: colors.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.labelMedium.copyWith(
                color: colors.textSecondary)),
      ],
    );
  }
}

class _GradientCardButton extends StatelessWidget {
  final String label;
  final List<Color> palette;
  final VoidCallback onTap;
  const _GradientCardButton(
      {required this.label, required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: palette),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: palette.first.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Center(
              child: Text(label,
                  style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ),
        ),
      );
}

class _OptionsButton extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;
  const _OptionsButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 40, height: 40,
        child: Material(
          color: colors.borderSubtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Center(
              child: Text('···',
                  style: AppTextStyles.titleSmall.copyWith(
                      color: colors.textMuted, letterSpacing: 2)),
            ),
          ),
        ),
      );
}

class _GradientFab extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;
  const _GradientFab({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
      );
}

class _DashedAddCard extends StatelessWidget {
  final String label;
  final AppColors colors;
  final VoidCallback onTap;
  const _DashedAddCard(
      {required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.borderDefault,
              style: BorderStyle.solid,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: colors.textPlaceholder, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.labelLarge.copyWith(
                      color: colors.textPlaceholder)),
            ],
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColors colors;
  const _EmptyState({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 64, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(l10n.yourSchools,
                style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary)),
            const SizedBox(height: 8),
            Text('Add your first school to get started.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textMuted)),
          ],
        ),
      );
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  final bool isDestructive;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon,
            color: isDestructive ? colors.error : colors.textSecondary),
        title: Text(label,
            style: AppTextStyles.bodyLarge.copyWith(
                color: isDestructive ? colors.error : colors.textPrimary)),
        onTap: onTap,
      );
}
