import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../providers/auth_provider.dart';

/// Login screen — handles Email/Password login.
///
/// Also contains the forgot-password bottom sheet so no extra screen is needed.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isLoading => ref.watch(authNotifierProvider).isLoading;

  Future<void> _loginWithEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final error = ref.read(authNotifierProvider).error;
    if (error != null) {
      showErrorSnackbar(context, error.toString());
    }
  }

  void _showForgotPassword() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ForgotPasswordSheet(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Blue/pink corner gradient wash — per Design.md hero treatment
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(gradient: AppGradients.heroBlue),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Opacity(
              opacity: 0.6,
              child: Container(
                decoration: const BoxDecoration(gradient: AppGradients.heroPink),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 160),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildEmailForm(),
                  const SizedBox(height: 28),
                  _buildRegisterLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back,', style: AppTextStyles.headlineMedium),
        Text(
          'Sign in to continue.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.charcoal),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          AppTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.stone,
            ),
            validator: (v) => v == null || !v.contains('@')
                ? 'Enter a valid email address.'
                : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Password',
            hint: '••••••••',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.stone),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.stone,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => v == null || v.length < 6
                ? 'Password must be at least 6 characters.'
                : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPassword,
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Sign In',
            onPressed: _loginWithEmail,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
        GestureDetector(
          onTap: () => context.go('/register'),
          child: Text('Sign up', style: AppTextStyles.link),
        ),
      ],
    );
  }
}

// ── Forgot Password Bottom Sheet ──────────────────────────────────────────────

class _ForgotPasswordSheet extends ConsumerStatefulWidget {
  const _ForgotPasswordSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<_ForgotPasswordSheet> {
  final _controller = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_controller.text.contains('@')) {
      showErrorSnackbar(context, 'Enter a valid email address.');
      return;
    }
    await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordResetEmail(_controller.text.trim());
    if (!mounted) return;
    final err = ref.read(authNotifierProvider).error;
    if (err != null) {
      showErrorSnackbar(context, err.toString());
    } else {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Reset Password', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          if (!_sent) ...[
            Text(
              'Enter your email and we\'ll send a reset link.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.stone,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Send Reset Link',
              onPressed: _send,
              isLoading: isLoading,
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Icon(
              Icons.mark_email_read_outlined,
              size: 56,
              color: AppColors.statusAccepted,
            ),
            const SizedBox(height: 16),
            Text(
              'Reset link sent! Check your inbox for ${_controller.text.trim()} and follow the instructions.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ],
      ),
    );
  }
}
