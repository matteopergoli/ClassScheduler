// lib/presentation/auth/forgot_password_screen.dart

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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading    = false;
  bool _sent       = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).sendPasswordReset(_emailCtrl.text);
      setState(() => _sent = true);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: _sent
              ? _SuccessView(l10n: l10n, colors: colors,
                  onBack: () => context.pop())
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.forgotPasswordTitle,
                          style: AppTextStyles.displayMedium.copyWith(
                              color: colors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(l10n.forgotPasswordSubtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textMuted)),
                      const SizedBox(height: 36),
                      CsTextField(
                        controller: _emailCtrl,
                        label: l10n.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _send(),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Enter a valid email.' : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: colors.error)),
                      ],
                      const SizedBox(height: 28),
                      CsButton(
                        label: l10n.sendResetLink,
                        loading: _loading,
                        onPressed: _send,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColors colors;
  final VoidCallback onBack;
  const _SuccessView({required this.l10n, required this.colors, required this.onBack});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.mark_email_read_outlined, size: 64, color: colors.success),
      const SizedBox(height: 20),
      Text(l10n.resetLinkSent,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary)),
      const SizedBox(height: 32),
      CsButton(label: l10n.back, onPressed: onBack),
    ],
  );
}
