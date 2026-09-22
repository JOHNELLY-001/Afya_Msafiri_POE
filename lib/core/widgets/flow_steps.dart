import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// Thin 4-step progress for the screening flow:
/// 1 Traveller → 2 Risk → 3 Decision → 4 Recorded.
/// Presentational only — no routing logic.
class FlowSteps extends StatelessWidget {
  final int current; // 1..4
  static const _labels = ['Traveller', 'Risk', 'Decision', 'Done'];

  const FlowSteps({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: List.generate(4, (i) {
        final step = i + 1;
        final done = step < current;
        final active = step == current;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done || active ? primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done || active
                        ? primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check,
                        size: 13, color: Colors.white)
                    : Text(
                        '$step',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _labels[i],
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: active
                                ? primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (step < 4)
                Expanded(
                  child: Container(
                    height: 2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: step < current
                          ? primary
                          : Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                      borderRadius: BorderRadius.circular(
                          AppRadius.full),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
