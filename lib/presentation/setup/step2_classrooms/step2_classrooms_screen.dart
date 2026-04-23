// lib/presentation/setup/step2_classrooms/step2_classrooms_screen.dart
//
// FR-CLS-01, FR-CLS-02. Max 10 classrooms per school.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_models.dart';
import '../../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../../data/repositories/subject_repositories.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/cs_button.dart';
import '../../widgets/cs_text_field.dart';
import '../setup_screen.dart';

// ── Stream providers ──────────────────────────────────────────────────────────
final classroomsStreamProvider =
    StreamProvider.family<List<ClassroomModel>, String>((ref, schoolId) {
  final uid = ref.watch(currentUserProvider)!.uid;
  return ClassroomRepository(uid: uid, schoolId: schoolId).watchAll();
});

class Step2ClassroomsScreen extends ConsumerWidget {
  const Step2ClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n    = AppLocalizations.of(context);
    final colors  = AppColors.of(context);
    final school  = ref.watch(activeSchoolProvider);
    if (school == null) return const SizedBox.shrink();

    final classroomsAsync = ref.watch(classroomsStreamProvider(school.id));

    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadH, vertical: 16),
      children: [
        Text(l10n.step2Description,
            style: AppTextStyles.bodyMedium.copyWith(color: colors.textMuted)),
        const SizedBox(height: 20),
        classroomsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(e.toString()),
          data: (classrooms) => Column(
            children: [
              ...classrooms.map((c) => _ClassroomTile(
                    classroom: c,
                    schoolId: school.id,
                    colors: colors,
                    l10n: l10n,
                    ref: ref,
                  )),
              const SizedBox(height: 12),
              if (classrooms.length < AppConstants.maxClassroomsPerSchool)
                OutlinedButton.icon(
                  onPressed: () =>
                      _showAddSheet(context, ref, school.id, classrooms.length),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addClassroom),
                )
              else
                Text(l10n.maxClassroomsReached,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: colors.warning)),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddSheet(
      BuildContext context, WidgetRef ref, String schoolId, int count) {
    final ctrl = TextEditingController();
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.addClassroom,
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              CsTextField(
                controller: ctrl,
                label: l10n.classroomName,
                autofocus: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              CsButton(
                label: l10n.save,
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  final uid = ref.read(currentUserProvider)!.uid;
                  await ClassroomRepository(uid: uid, schoolId: schoolId).save(
                    ClassroomModel(
                      id: const Uuid().v4(),
                      schoolId: schoolId,
                      name: ctrl.text.trim(),
                      sortOrder: count,
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassroomTile extends StatelessWidget {
  final ClassroomModel classroom;
  final String schoolId;
  final AppColors colors;
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _ClassroomTile({
    required this.classroom,
    required this.schoolId,
    required this.colors,
    required this.l10n,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.cardBg,
          border: Border.all(color: colors.borderDefault),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.class_outlined, color: colors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(classroom.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: colors.textPrimary)),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 18, color: colors.textMuted),
              onPressed: () => _rename(context),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
              onPressed: () => _delete(context),
            ),
          ],
        ),
      );

  void _rename(BuildContext context) {
    final ctrl = TextEditingController(text: classroom.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.renameSchool,
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              CsTextField(
                controller: ctrl,
                label: l10n.classroomName,
                autofocus: true,
              ),
              const SizedBox(height: 20),
              CsButton(
                label: l10n.save,
                onPressed: () async {
                  final uid = ref.read(currentUserProvider)!.uid;
                  await ClassroomRepository(uid: uid, schoolId: schoolId)
                      .rename(classroom.id, ctrl.text.trim());
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.classroomDeleted),
        content: Text('Delete "${classroom.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final uid = ref.read(currentUserProvider)!.uid;
              final repo = ClassroomRepository(uid: uid, schoolId: schoolId);
              await repo.delete(classroom.id);
              // Also clean up classroom subjects
              await ClassroomSubjectRepository(uid: uid, schoolId: schoolId)
                  .deleteForClassroom(classroom.id);
              // Clean up day capacities
              await DayCapacityRepository(uid: uid, schoolId: schoolId)
                  .deleteForClassroom(classroom.id);
            },
            child: Text(l10n.delete,
                style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}
