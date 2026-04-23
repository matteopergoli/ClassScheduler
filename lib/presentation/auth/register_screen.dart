// lib/presentation/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/auth_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/cs_button.dart';
import '../widgets/cs_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading      = false;
  bool _obscure      = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).registerWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.registerTitle,
                    style: AppTextStyles.displayMedium.copyWith(
                        color: colors.textPrimary)),
                const SizedBox(height: 6),
                Text(l10n.registerSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textMuted)),
                const SizedBox(height: 36),

                CsTextField(
                  controller: _emailCtrl,
                  label: l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.email;
                    if (!v.contains('@')) return 'Enter a valid email.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CsTextField(
                  controller: _passCtrl,
                  label: l10n.password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.password;
                    if (v.length < 6) return 'At least 6 characters required.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CsTextField(
                  controller: _confirmCtrl,
                  label: l10n.confirmPassword,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  validator: (v) {
                    if (v != _passCtrl.text) return l10n.passwordMismatch;
                    return null;
                  },
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.error.withOpacity(0.3)),
                    ),
                    child: Text(_error!,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: colors.error)),
                  ),
                ],
                const SizedBox(height: 28),

                CsButton(
                  label: l10n.createAccount,
                  loading: _loading,
                  onPressed: _register,
                ),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(l10n.alreadyHaveAccount,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textMuted)),
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 6)),
                    child: Text(l10n.signIn,
                        style: AppTextStyles.labelMedium.copyWith(
                            color: colors.primaryLight)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
