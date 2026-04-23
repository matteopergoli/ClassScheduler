// lib/presentation/schools/school_form_sheet.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/cs_button.dart';
import '../widgets/cs_text_field.dart';

class SchoolFormSheet extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final Future<void> Function(String name, String? description) onSave;

  const SchoolFormSheet({
    super.key,
    this.initialName,
    this.initialDescription,
    required this.onSave,
  });

  @override
  State<SchoolFormSheet> createState() => _SchoolFormSheetState();
}

class _SchoolFormSheetState extends State<SchoolFormSheet> {
  final _formKey  = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initialName ?? '');
  late final _descCtrl =
      TextEditingController(text: widget.initialDescription ?? '');
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.onSave(
        _nameCtrl.text.trim(),
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final isEdit = widget.initialName != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isEdit ? l10n.renameSchool : l10n.newSchool,
                style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary),
              ),
              const SizedBox(height: 20),
              CsTextField(
                controller: _nameCtrl,
                label: l10n.schoolName,
                autofocus: true,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.schoolName : null,
              ),
              const SizedBox(height: 14),
              CsTextField(
                controller: _descCtrl,
                label: l10n.schoolDescription,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              CsButton(
                label: l10n.save,
                loading: _loading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
