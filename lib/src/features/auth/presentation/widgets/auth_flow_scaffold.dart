import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/app/theme/app_theme.dart';

class AuthFlowScaffold extends StatelessWidget {
  const AuthFlowScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepIndex,
    required this.child,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final int stepIndex;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette =
        Theme.of(context).extension<AppPalette>() ?? AppPalette.light;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: palette.loginBackground),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              if (onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: palette.loginTitle,
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                'assets/app_icon.png',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _StepIndicator(
                            currentStep: stepIndex,
                            palette: palette,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: palette.loginTitle,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: palette.loginSecondaryText),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 22),
                          child,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.palette,
  });

  final int currentStep;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (int index) {
        final bool isActive = index <= currentStep;
        final bool isCurrent = index == currentStep;
        return Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isCurrent ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive
                    ? palette.loginButton
                    : palette.loginSecondaryText.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            if (index < 2) const SizedBox(width: 8),
          ],
        );
      }),
    );
  }
}
