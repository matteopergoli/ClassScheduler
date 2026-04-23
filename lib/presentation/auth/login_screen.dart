// lib/presentation/auth/login_screen.dart
//
// FR-AUTH-01, FR-AUTH-02.
// Email/password, Google Sign-In, Apple Sign-In (iOS).
// Apple Sign-In is conditionally shown on iOS only per App Store guidelines.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/auth_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/cs_button.dart';
import '../widgets/cs_text_field.dart';
import '../widgets/cs_social_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      // Router redirect handles navigation after auth state change
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInApple() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInWithApple();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Logo / brand
                Text('ClassScheduler',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: colors.primary,
                      fontFamily: 'PlayfairDisplay',
                    )),
                const SizedBox(height: 8),
                Text(l10n.loginTitle,
                    style: AppTextStyles.displayMedium.copyWith(
                        color: colors.textPrimary)),
                const SizedBox(height: 6),
                Text(l10n.loginSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textMuted)),
                const SizedBox(height: 40),

                // Email
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

                // Password
                CsTextField(
                  controller: _passCtrl,
                  label: l10n.password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? l10n.password : null,
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: Text(l10n.forgotPassword,
                        style: AppTextStyles.labelMedium.copyWith(
                            color: colors.primaryLight)),
                  ),
                ),

                // Error message
                if (_error != null) ...[
                  const SizedBox(height: 8),
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
                const SizedBox(height: 24),

                // Sign in button
                CsButton(
                  label: l10n.signIn,
                  loading: _loading,
                  onPressed: _signIn,
                ),
                const SizedBox(height: 24),

                // Divider
                Row(children: [
                  Expanded(child: Divider(color: colors.borderDefault)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: colors.textMuted)),
                  ),
                  Expanded(child: Divider(color: colors.borderDefault)),
                ]),
                const SizedBox(height: 20),

                // Google
                CsSocialButton(
                  label: l10n.signInWithGoogle,
                  iconAsset: 'assets/icons/google.svg',
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: _loading ? null : _signInGoogle,
                ),

                // Apple — iOS only (FR-AUTH-02)
                if (Platform.isIOS) ...[
                  const SizedBox(height: 12),
                  CsSocialButton(
                    label: l10n.signInWithApple,
                    iconAsset: 'assets/icons/apple.svg',
                    icon: Icons.apple_rounded,
                    onPressed: _loading ? null : _signInApple,
                  ),
                ],
                const SizedBox(height: 32),

                // Register link
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(l10n.noAccount,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textMuted)),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 6)),
                    child: Text(l10n.createAccount,
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
