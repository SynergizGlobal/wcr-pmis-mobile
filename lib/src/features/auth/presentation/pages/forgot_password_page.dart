import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/app/theme/app_theme.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/login_page.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/widgets/auth_flow_scaffold.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/widgets/auth_form_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  static const String routeName = 'forgot-password';
  static const String routePath = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showError(Failure failure) async {
    await AppDialog.show(
      context: context,
      title: failure.code ?? 'Request Failed',
      message: failure.message,
      type: AppDialogType.error,
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final Failure? failure = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .sendOtp(_emailController.text.trim());
    if (!mounted || failure == null) {
      return;
    }
    await _showError(failure);
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final Failure? failure = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .verifyOtp(_otpController.text.trim());
    if (!mounted || failure == null) {
      return;
    }
    await _showError(failure);
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final Failure? failure = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .resetPassword(
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
    if (!mounted) {
      return;
    }
    if (failure != null) {
      await _showError(failure);
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Password Reset',
      message: 'Your password has been reset successfully. Please login.',
      type: AppDialogType.success,
    );
    if (!mounted) {
      return;
    }
    context.go(LoginPage.routePath);
  }

  Future<void> _resendOtp() async {
    final Failure? failure = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .resendOtp();
    if (!mounted) {
      return;
    }
    if (failure != null) {
      await _showError(failure);
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'OTP Sent',
      message: 'A new verification code has been sent to your email.',
      type: AppDialogType.info,
    );
  }

  void _handleBack(ForgotPasswordState state) {
    if (state.step == ForgotPasswordStep.email) {
      context.pop();
      return;
    }
    ref.read(forgotPasswordControllerProvider.notifier).goBack();
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordState flowState = ref.watch(
      forgotPasswordControllerProvider,
    );
    final AppPalette palette =
        Theme.of(context).extension<AppPalette>() ?? AppPalette.light;
    final int stepIndex = switch (flowState.step) {
      ForgotPasswordStep.email => 0,
      ForgotPasswordStep.otp => 1,
      ForgotPasswordStep.reset => 2,
    };

    return AuthFlowScaffold(
      stepIndex: stepIndex,
      onBack: () => _handleBack(flowState),
      title: switch (flowState.step) {
        ForgotPasswordStep.email => 'Forgot Password',
        ForgotPasswordStep.otp => 'Verify OTP',
        ForgotPasswordStep.reset => 'Reset Password',
      },
      subtitle: switch (flowState.step) {
        ForgotPasswordStep.email =>
          'Enter your registered email to receive a one-time password.',
        ForgotPasswordStep.otp =>
          'Enter the 6-digit code sent to ${flowState.email}.',
        ForgotPasswordStep.reset =>
          'Choose a new password for ${flowState.email}.',
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            switch (flowState.step) {
              ForgotPasswordStep.email => _buildEmailStep(flowState),
              ForgotPasswordStep.otp => _buildOtpStep(flowState, palette),
              ForgotPasswordStep.reset => _buildResetStep(flowState),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep(ForgotPasswordState flowState) {
    final bool canSubmit =
        _emailController.text.trim().isNotEmpty && !flowState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthFormField(
          controller: _emailController,
          hintText: 'Email address',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          validator: _validateEmail,
        ),
        const SizedBox(height: 18),
        AuthPrimaryButton(
          label: 'Send OTP',
          isLoading: flowState.isLoading,
          onPressed: canSubmit ? _sendOtp : null,
        ),
      ],
    );
  }

  Widget _buildOtpStep(ForgotPasswordState flowState, AppPalette palette) {
    final bool canSubmit =
        _otpController.text.trim().length == 6 && !flowState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthFormField(
          controller: _otpController,
          hintText: '6-digit OTP',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          textAlign: TextAlign.center,
          letterSpacing: 10,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (_) => setState(() {}),
          validator: _validateOtp,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: flowState.isLoading ? null : _resendOtp,
            child: Text(
              'Resend OTP',
              style: TextStyle(color: palette.actionLink),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AuthPrimaryButton(
          label: 'Verify OTP',
          isLoading: flowState.isLoading,
          onPressed: canSubmit ? _verifyOtp : null,
        ),
      ],
    );
  }

  Widget _buildResetStep(ForgotPasswordState flowState) {
    final bool canSubmit =
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        !flowState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthFormField(
          controller: _newPasswordController,
          hintText: 'New password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureNewPassword,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          validator: _validateNewPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
            icon: Icon(
              _obscureNewPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        const SizedBox(height: 14),
        AuthFormField(
          controller: _confirmPasswordController,
          hintText: 'Confirm password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          validator: _validateConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        const SizedBox(height: 18),
        AuthPrimaryButton(
          label: 'Reset Password',
          isLoading: flowState.isLoading,
          onPressed: canSubmit ? _resetPassword : null,
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    final RegExp pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!pattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    final String otp = value?.trim() ?? '';
    if (otp.length != 6) {
      return 'Enter the 6-digit OTP';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
