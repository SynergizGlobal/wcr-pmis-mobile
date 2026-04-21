import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const String routeName = 'login';
  static const String routePath = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareLoginForm());
  }

  /// Fills username/password from disk when not already restored into session.
  Future<void> _prepareLoginForm() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    if (ref.read(authControllerProvider).valueOrNull != null) {
      return;
    }
    final AuthLocalSnapshot snapshot = await ref
        .read(authLocalDataSourceProvider)
        .readSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _rememberMe = snapshot.rememberMe;
      _userIdController.text = snapshot.userId ?? '';
      _passwordController.text = snapshot.password ?? '';
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Failure? failure = await ref
        .read(authControllerProvider.notifier)
        .login(
          userId: _userIdController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

    if (!mounted) {
      return;
    }

    if (failure != null) {
      await AppDialog.show(
        context: context,
        title: failure.code ?? 'Login Failed',
        message: failure.message,
        type: AppDialogType.error,
      );
      return;
    }
    // [GoRouter.redirect] sends authenticated users to the dashboard.
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AuthSession?> authState = ref.watch(
      authControllerProvider,
    );
    final bool isLoading = authState.isLoading;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const Color screenBackground = Color(0xFFA4B7D4);
    const Color titleColor = Color(0xFF111111);
    const Color secondaryText = Color(0xFF5D677A);
    const Color actionBlue = Color(0xFF1229D9);
    const Color buttonColor = Color(0xFF565DA8);
    final bool hasUsername = _userIdController.text.trim().isNotEmpty;
    final bool hasPassword = _passwordController.text.isNotEmpty;
    final bool canSubmit = hasUsername && hasPassword && !isLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: screenBackground,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                'assets/app_icon.png',
                                width: 86,
                                height: 86,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Login to continue to WCR PMIS',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: secondaryText),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _userIdController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: TextStyle(
                                color: secondaryText,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: secondaryText,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _userIdController.text.trim().isNotEmpty
                                      ? colorScheme.primary
                                      : Colors.white,
                                  width: _userIdController.text.trim().isNotEmpty
                                      ? 1.4
                                      : 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: secondaryText,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: secondaryText,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _passwordController.text.isNotEmpty
                                      ? colorScheme.primary
                                      : Colors.white,
                                  width: _passwordController.text.isNotEmpty
                                      ? 1.4
                                      : 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: _rememberMe,
                                side: BorderSide(
                                  color: secondaryText.withValues(alpha: 0.8),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onChanged: (bool? value) async {
                                  final bool next = value ?? false;
                                  setState(() {
                                    _rememberMe = next;
                                  });
                                  if (!next) {
                                    await ref
                                        .read(authLocalDataSourceProvider)
                                        .clearSensitiveOnly();
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      _passwordController.clear();
                                    });
                                  }
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  'Remember me',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                AppDialog.show(
                                  context: context,
                                  title: 'Information',
                                  message:
                                      'Forgot password flow will be connected shortly.',
                                  type: AppDialogType.info,
                                );
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(color: actionBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: canSubmit ? _submit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(45),
                              disabledBackgroundColor: buttonColor.withValues(
                                alpha: 0.70,
                              ),
                              disabledForegroundColor: Colors.white70,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.6,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
