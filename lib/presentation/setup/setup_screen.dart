// lib/presentation/setup/setup_screen.dart
//
// 4-step setup stepper (§6.2.2).
// Steps: 1-Periods → 2-Classrooms → 3-DailyCapacity → 4-Subjects
// The stepper order fixes the circular dependency:
//   Step 3 requires Step 1 (periods) AND Step 2 (classrooms).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../core/router/app_router.dart';
import '../../data/repositories/school_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import 'step1_periods/step1_periods_screen.dart';
import 'step2_classrooms/step2_classrooms_screen.dart';
import 'step3_capacity/step3_capacity_screen.dart';
import 'step4_subjects/step4_subjects_screen.dart';

// ── Active school provider ─────────────────────────────────────────────────
// The selected school for the current setup session.
final activeSchoolProvider = StateProvider<SchoolModel?>((ref) => null);

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _currentStep = 0;

  final List<Widget> _stepScreens = const [
    Step1PeriodsScreen(),
    Step2ClassroomsScreen(),
    Step3CapacityScreen(),
    Step4SubjectsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context);
    final colors      = AppColors.of(context);
    final activeSchool = ref.watch(activeSchoolProvider);
    final schools     = ref.watch(schoolsStreamProvider);

    // If no school selected, prompt user to pick or create one
    if (activeSchool == null) {
      return Scaffold(
        body: SafeArea(
          child: schools.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Center(child: Text(e.toString())),
            data:    (list) => list.isEmpty
                ? _NoSchoolPrompt(colors: colors, l10n: l10n)
                : _SchoolPicker(
                    schools: list,
                    colors: colors,
                    l10n: l10n,
                    onSelect: (s) =>
                        ref.read(activeSchoolProvider.notifier).state = s,
                  ),
          ),
        ),
      );
    }

    final stepTitles = [
      l10n.step1Title,
      l10n.step2Title,
      l10n.step3Title,
      l10n.step4Title,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header + school name ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.setupTitle,
                            style: AppTextStyles.labelSmall.copyWith(
                                color: colors.textMuted,
                                letterSpacing: 0.08)),
                        Text(activeSchool.name,
                            style: AppTextStyles.titleMedium.copyWith(
                                color: colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  // Change school
                  TextButton(
                    onPressed: () => ref
                        .read(activeSchoolProvider.notifier)
                        .state = null,
                    child: Text('Change',
                        style: AppTextStyles.labelMedium.copyWith(
                            color: colors.primaryLight)),
                  ),
                ],
              ),
            ),

            // ── Progress stepper ────────────────────────────────────────
            _StepperIndicator(
              steps: stepTitles,
              currentIndex: _currentStep,
              colors: colors,
              onTap: (i) => setState(() => _currentStep = i),
            ),

            // ── Step content ─────────────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: _stepScreens,
              ),
            ),

            // ── Navigation buttons ───────────────────────────────────────
            _StepNavBar(
              currentStep: _currentStep,
              totalSteps: _stepScreens.length,
              l10n: l10n,
              colors: colors,
              onBack: () => setState(() => _currentStep--),
              onNext: () => setState(() => _currentStep++),
              onDone: () => context.go(AppRoutes.schedule),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stepper indicator ────────────────────────────────────────────────────────
class _StepperIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentIndex;
  final AppColors colors;
  final void Function(int) onTap;

  const _StepperIndicator({
    required this.steps,
    required this.currentIndex,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final passed    = stepIndex < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: passed ? colors.primary : colors.borderDefault,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final active    = stepIndex == currentIndex;
          final done      = stepIndex < currentIndex;
          return GestureDetector(
            onTap: () => onTap(stepIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 32 : 28,
              height: active ? 32 : 28,
              decoration: BoxDecoration(
                color: done
                    ? colors.primary
                    : active
                        ? colors.primary.withOpacity(0.15)
                        : colors.borderDefault,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active || done
                      ? colors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: active
                              ? colors.primary
                              : colors.textMuted,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Step navigation bar ──────────────────────────────────────────────────────
class _StepNavBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final AppLocalizations l10n;
  final AppColors colors;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onDone;

  const _StepNavBar({
    required this.currentStep,
    required this.totalSteps,
    required this.l10n,
    required this.colors,
    required this.onBack,
    required this.onNext,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderSubtle)),
        ),
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: Text(l10n.back),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: currentStep < totalSteps - 1 ? onNext : onDone,
                child: Text(currentStep < totalSteps - 1
                    ? l10n.next
                    : l10n.done),
              ),
            ),
          ],
        ),
      );
}

// ── Pickers for school selection ─────────────────────────────────────────────
class _NoSchoolPrompt extends StatelessWidget {
  final AppColors colors;
  final AppLocalizations l10n;
  const _NoSchoolPrompt({required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_outlined, size: 64, color: colors.textMuted),
              const SizedBox(height: 16),
              Text('No schools yet.',
                  style: AppTextStyles.titleMedium.copyWith(
                      color: colors.textPrimary)),
              const SizedBox(height: 8),
              Text('Go to the Schools tab to create your first school.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textMuted)),
            ],
          ),
        ),
      );
}

class _SchoolPicker extends StatelessWidget {
  final List<SchoolModel> schools;
  final AppColors colors;
  final AppLocalizations l10n;
  final void Function(SchoolModel) onSelect;

  const _SchoolPicker({
    required this.schools,
    required this.colors,
    required this.l10n,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Select a school to set up',
                style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: schools.length,
              itemBuilder: (_, i) => ListTile(
                leading: Icon(Icons.school_outlined, color: colors.primary),
                title: Text(schools[i].name,
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: colors.textPrimary)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: colors.textMuted),
                onTap: () => onSelect(schools[i]),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
}
