import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _loading = false;
  String? _error;
  bool _showEmailForm = false;
  bool _emailLinkSent = false;
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _useEmailLink = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();

      final syncService = ref.read(firebaseSyncServiceProvider);
      final db = ref.read(databaseProvider);
      await syncService.pullAndMerge(db);
      await syncService.pushAllProgress(db);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address');
      return;
    }

    if (_useEmailLink) {
      setState(() { _loading = true; _error = null; });
      try {
        final authService = ref.read(authServiceProvider);
        await authService.sendSignInLink(email);
        setState(() => _emailLinkSent = true);
      } catch (e) {
        setState(() => _error = e.toString());
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    final password = _passwordController.text;
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    if (_isSignUp && password != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final authService = ref.read(authServiceProvider);

      if (_isSignUp) {
        await authService.createAccountWithEmail(
          email: email,
          password: password,
        );
      } else {
        await authService.signInWithEmailPassword(
          email: email,
          password: password,
        );
      }

      final syncService = ref.read(firebaseSyncServiceProvider);
      final db = ref.read(databaseProvider);
      await syncService.pullAndMerge(db);
      await syncService.pushAllProgress(db);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithApple();

      final syncService = ref.read(firebaseSyncServiceProvider);
      final db = ref.read(databaseProvider);
      await syncService.pullAndMerge(db);
      await syncService.pushAllProgress(db);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.cloud_sync_outlined,
              size: 64,
              color: AppColors.accentLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Sync Your Progress',
              style: AppTextStyles.statMedium(
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to sync your learning progress across devices.',
              style: AppTextStyles.bodySmall(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _error!,
                  style: AppTextStyles.bodySmall(color: AppColors.error),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_emailLinkSent) ...[
              Icon(
                Icons.mark_email_read_outlined,
                size: 48,
                color: AppColors.accentLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Check your email',
                style: AppTextStyles.statMedium(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a sign-in link to ${_emailController.text.trim()}',
                style: AppTextStyles.bodySmall(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() {
                  _emailLinkSent = false;
                  _showEmailForm = false;
                }),
                child: const Text('Back to sign in'),
              ),
            ] else if (_showEmailForm) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (!_useEmailLink) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Use email link (passwordless)'),
                  const Spacer(),
                  Switch(
                    value: _useEmailLink,
                    onChanged: (v) => setState(() => _useEmailLink = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _signInWithEmail,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _useEmailLink
                      ? 'Send sign-in link'
                      : _isSignUp
                          ? 'Create account'
                          : 'Sign in',
                ),
              ),
              if (!_useEmailLink) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign in'
                        : 'Don\'t have an account? Sign up',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _showEmailForm = false),
                child: const Text('Back'),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              if (Platform.isIOS || Platform.isMacOS) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _signInWithApple,
                  icon: const Icon(Icons.apple, size: 24),
                  label: const Text('Continue with Apple'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _showEmailForm = true),
                icon: const Icon(Icons.email_outlined, size: 24),
                label: const Text('Continue with Email'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip — use offline only'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
