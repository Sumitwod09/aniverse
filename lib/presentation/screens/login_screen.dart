import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/providers/auth_providers.dart';
import '../widgets/buttons.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // For now, sign in as guest since Firebase auth is not yet configured
    _signInAsGuest();
  }

  void _signInAsGuest() {
    ref.read(authNotifierProvider.notifier).signInAsGuest();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: const CustomAppBar(
        title: 'Sign In',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSignUp ? 'Create Account' : 'Welcome Back',
              style: AppTypography.display,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _isSignUp
                  ? 'Create an account to sync your watchlist across devices'
                  : 'Sign in to access your watchlist and continue watching',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Email field
            Text('Email', style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'your@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Password field
            Text('Password', style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit button
            authState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      if (authState.isError) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: AppColors.error),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  authState.error ?? 'An error occurred',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      PrimaryButton(
                        text: _isSignUp ? 'Create Account' : 'Sign In',
                        width: double.infinity,
                        onPressed: _submit,
                      ),
                    ],
                  ),
            const SizedBox(height: AppSpacing.md),

            // Toggle sign in/up
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() => _isSignUp = !_isSignUp);
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign in'
                      : 'Don\'t have an account? Create one',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Or divider
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.borderDivider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'OR',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.borderDivider)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Continue as guest
            SecondaryButton(
              text: 'Continue as Guest',
              icon: Icons.person_outline,
              width: double.infinity,
              onPressed: _signInAsGuest,
            ),
          ],
        ),
      ),
    );
  }
}
