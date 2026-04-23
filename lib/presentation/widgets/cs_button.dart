// lib/presentation/widgets/cs_button.dart
// Primary gradient button used across the app.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outline;
  final IconData? prefixIcon;
  final double? width;

  const CsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outline = false,
    this.prefixIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (outline) {
      return SizedBox(
        width: width,
        height: 48,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: _child(colors),
        ),
      );
    }

    return Container(
      width: width,
      height: 48,
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? null
            : LinearGradient(
                colors: [colors.primary, colors.primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: onPressed == null ? colors.borderDefault : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: colors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: _child(colors)),
        ),
      ),
    );
  }

  Widget _child(AppColors colors) => loading
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: AppTextStyles.button.copyWith(
                  color: outline ? colors.textSecondary : Colors.white,
                )),
          ],
        );
}
