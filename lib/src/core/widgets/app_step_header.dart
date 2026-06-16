import 'package:flutter/material.dart';

class AppStepHeader extends StatelessWidget {
  const AppStepHeader({
    super.key,
    required this.title,
    required this.stepTitles,
    required this.currentStep,
    this.chipLabels,
    this.compact = false,
  });

  final String title;
  final List<String> stepTitles;
  final int currentStep;
  final List<String>? chipLabels;

  /// Compact layout: current step name as title, round step badge, numbered dots only.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final int safeStep = currentStep.clamp(0, stepTitles.length - 1);
    final String headerTitle = compact ? stepTitles[safeStep] : title;
    final String stepBadge = compact
        ? 'step ${safeStep + 1}/${stepTitles.length}'
        : 'Step ${safeStep + 1}/${stepTitles.length}';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  headerTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stepBadge,
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (compact)
            _CompactStepDots(
              stepCount: stepTitles.length,
              currentStep: safeStep,
            )
          else
            _LabeledStepChips(
              stepTitles: stepTitles,
              labels: chipLabels ?? stepTitles,
              safeStep: safeStep,
            ),
        ],
      ),
    );
  }
}

class _CompactStepDots extends StatelessWidget {
  const _CompactStepDots({
    required this.stepCount,
    required this.currentStep,
  });

  final int stepCount;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(stepCount * 2 - 1, (int i) {
        if (i.isOdd) {
          final int leftIndex = i ~/ 2;
          final bool filled = currentStep > leftIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: filled
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.45),
            ),
          );
        }

        final int index = i ~/ 2;
        final bool done = currentStep > index;
        final bool current = currentStep == index;
        final bool active = currentStep >= index;
        final Color fillColor =
            active ? cs.primary : cs.surfaceContainerHighest;
        final Color contentColor =
            active ? cs.onPrimary : cs.onSurfaceVariant;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: Border.all(
              color: current
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.7),
              width: current ? 2 : 1,
            ),
            boxShadow: current
                ? <BoxShadow>[
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.24),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: done
                ? Icon(Icons.check_rounded, size: 18, color: contentColor)
                : Text(
                    '${index + 1}',
                    style: tt.labelLarge?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

class _LabeledStepChips extends StatelessWidget {
  const _LabeledStepChips({
    required this.stepTitles,
    required this.labels,
    required this.safeStep,
  });

  final List<String> stepTitles;
  final List<String> labels;
  final int safeStep;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Row(
      children: List<Widget>.generate(stepTitles.length, (int index) {
        final bool done = index < safeStep;
        final bool current = index == safeStep;
        final bool active = index <= safeStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == stepTitles.length - 1 ? 0 : 8),
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
    );
  }
}
