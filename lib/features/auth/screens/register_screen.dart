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
