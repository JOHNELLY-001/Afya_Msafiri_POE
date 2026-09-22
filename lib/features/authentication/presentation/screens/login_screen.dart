import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config.dart';
import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _localError = 'Please enter both username and password.';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    final success = await ref.read(sessionProvider.notifier).login(
      username: username,
      password: password,
    );

    if (!mounted || !success) return;
    context.go(AppRoutes.pointOfEntry);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final displayError = _localError ?? session.error;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          // Institutional header matching splash.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 56, AppSpacing.lg, AppSpacing.lg),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // Guide: Deep Slate → Primary Blue institutional header.
                colors: [AppTheme.deepSlate, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Image(
                        image: AssetImage(
                            'assets/images/coat-of-arms-of-tanzania-seeklogo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('AfyaMsafiri',
                      style: text.headlineMedium?.copyWith(
                          color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text('Point of Entry Health Screening',
                      style: text.bodyMedium?.copyWith(
                          color:
                              Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 4),
                  Text('Wizara ya Afya • Tanzania',
                      style: text.labelSmall?.copyWith(
                          color:
                              Colors.white.withValues(alpha: 0.65),
                          letterSpacing: 0.6)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Sign in',
                              style: text.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                              'Use your officer credentials.',
                              style: text.bodyMedium),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _usernameController,
                            label: 'Username',
                            hint: 'Enter your username',
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                          ),
                          if (displayError != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                  AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(
                                    AppRadius.base),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(displayError,
                                        style: text.bodySmall
                                            ?.copyWith(
                                                color: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .onErrorContainer,
                                                fontWeight:
                                                    FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            label: 'Sign In',
                            icon: Icons.login_outlined,
                            loading: session.loading,
                            onPressed: _login,
                          ),
                          if (AppConfig.bypassAuth) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  ref
                                      .read(sessionProvider
                                          .notifier)
                                      .continueWithoutLogin();
                                  context
                                      .go(AppRoutes.pointOfEntry);
                                },
                                child: const Text(
                                    'Continue without login (dev bypass)'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text('Authorized personnel only • v1.0.0',
                style: text.labelSmall),
          ),
        ],
      ),
    );
  }
}
