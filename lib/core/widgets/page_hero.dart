import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// Gradient hero banner used at the top of flow screens so the UI
/// speaks before the data does. Presentational only.
class PageHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color from;
  final Color to;

  const PageHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [from, to],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius:
                  BorderRadius.circular(AppRadius.md),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: text.titleLarge
                        ?.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: text.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
