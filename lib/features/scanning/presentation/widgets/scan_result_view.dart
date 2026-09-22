import 'package:flutter/material.dart';

import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';

/// One consistent result pattern for every scan outcome:
/// hero icon → title → message → booking-ref chip → actions.
class ScanResultView extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconForeground;
  final String title;
  final String message;
  final String? bookingReference;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? footer;

  const ScanResultView({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconForeground,
    required this.title,
    required this.message,
    this.bookingReference,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // Hero icon with soft glow ring so outcome reads instantly.
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconForeground.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            iconForeground.withValues(alpha: 0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconForeground, size: 44),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: text.bodyMedium, textAlign: TextAlign.center),
            if (bookingReference != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.base),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 16, color: colors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        bookingReference!,
                        style: text.titleMedium
                            ?.copyWith(letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.md),
              footer!,
            ],
            const Spacer(),
            AppButton(
                label: primaryLabel, icon: primaryIcon, onPressed: onPrimary),
            if (secondaryLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
