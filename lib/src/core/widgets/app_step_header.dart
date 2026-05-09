import 'package:flutter/material.dart';

class AppStepHeader extends StatelessWidget {
  const AppStepHeader({
    super.key,
    required this.title,
    required this.stepTitles,
    required this.currentStep,
    this.chipLabels,
  });

  final String title;
  final List<String> stepTitles;
  final int currentStep;
  final List<String>? chipLabels;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<String> labels = chipLabels ?? stepTitles;
    final int safeStep = currentStep.clamp(0, stepTitles.length - 1);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Step ${safeStep + 1}/${stepTitles.length}',
                  style: tt.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List<Widget>.generate(stepTitles.length, (int index) {
              final bool done = index < safeStep;
              final bool current = index == safeStep;
              final bool active = index <= safeStep;
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: index == stepTitles.length - 1 ? 0 : 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: active
                          ? cs.primaryContainer.withValues(alpha: current ? 0.78 : 0.45)
                          : cs.surface,
                      border: Border.all(
                        color: active
                            ? cs.primary.withValues(alpha: 0.45)
                            : cs.outlineVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? cs.primary : cs.surfaceContainerHighest,
                          ),
                          child: Center(
                            child: done
                                ? Icon(Icons.check_rounded, size: 14, color: cs.onPrimary)
                                : Text(
                                    '${index + 1}',
                                    style: tt.labelMedium?.copyWith(
                                      color: active ? cs.onPrimary : cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            labels[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: tt.bodySmall?.copyWith(
                              fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                              color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
