// lib/presentation/widgets/cs_social_button.dart
//
// Social sign-in button. Uses Icon widgets instead of SVG assets
// so no asset files are needed. Replace Icon with SvgPicture.asset
// once you add google.svg / apple.svg to assets/icons/.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CsSocialButton extends StatelessWidget {
  final String  label;
  final String  iconAsset;   // kept for API compatibility; currently unused
  final IconData icon;
  final VoidCallback? onPressed;

  const CsSocialButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.borderDefault),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          backgroundColor: colors.cardBg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 10),
            Text(label,
                style: AppTextStyles.button.copyWith(
                    color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
