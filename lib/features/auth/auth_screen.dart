import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_snackbar.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

// =============================================================================
// 1. SPLASH SCREEN
// =============================================================================

/// Animated splash screen shown once at app launch.
///
/// Plays a zoom-in + fade animation on the logo, then routes to /login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.forward().whenComplete(_navigate);
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // ── Gradient wash ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(gradient: AppGradients.heroBlue),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.6,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.heroPink,
                ),
              ),
            ),
          ),

          // ── Animated logo + wordmark ──
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/img/Munasabat Logo.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your wedding, perfectly planned.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.brandInk,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. LOGIN SCREEN & FORGOT PASSWORD SHEET
// =============================================================================

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

// =============================================================================
// 3. REGISTER SCREEN
// =============================================================================

/// Registration screen — creates a new host account with email, password, and
/// an optional phone number (stored as a profile field, no OTP required).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isLoading => ref.watch(authNotifierProvider).isLoading;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authNotifierProvider.notifier)
        .registerWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

    if (!mounted) return;
    final error = ref.read(authNotifierProvider).error;
    if (error != null) {
      showErrorSnackbar(context, error.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully! Please log in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(gradient: AppGradients.heroBlue),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
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
                  const SizedBox(height: 150),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
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
        Text('Create account', style: AppTextStyles.headlineMedium),
        Text(
          'Plan your perfect day, start here.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.charcoal),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            label: 'Full Name',
            hint: 'Your name',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(
              Icons.person_outlined,
              color: AppColors.stone,
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Please enter your name.'
                : null,
          ),
          const SizedBox(height: 16),
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
            label: 'Phone Number (optional)',
            hint: '+880 1XXX XXXXXX',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: AppColors.stone,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Password',
            hint: 'Minimum 6 characters',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
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
          const SizedBox(height: 16),
          AppTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: _confirmController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.stone),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.stone,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) => v != _passwordController.text
                ? 'Passwords do not match.'
                : null,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Create Account',
            onPressed: _register,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: AppTextStyles.bodyMedium),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text('Sign in', style: AppTextStyles.link),
        ),
      ],
    );
  }
}
