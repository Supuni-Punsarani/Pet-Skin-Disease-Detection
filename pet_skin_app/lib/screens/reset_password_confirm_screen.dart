import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ResetPasswordConfirmScreen extends StatefulWidget {
  final String oobCode;
  const ResetPasswordConfirmScreen({super.key, required this.oobCode});

  @override
  State<ResetPasswordConfirmScreen> createState() => _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState extends State<ResetPasswordConfirmScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: _passwordCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully! Please sign in.'),
          backgroundColor: AppColors.success,
        ),
      );

      // Auto redirect to Sign In
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Failed to reset password. The link may be invalid or expired.';
      if (e.code == 'weak-password') {
        msg = 'Password must be at least 6 characters long.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.decorativeCircle,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // Creative Icon Header
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              color: AppColors.decorativeCircle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.vpn_key_outlined,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ).animate().scale(delay: 150.ms, duration: 600.ms, curve: Curves.easeOutBack),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Titles
                    Center(
                      child: Text(
                        'Create New Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Your identity has been verified. Enter your new password below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 36),

                    // Input Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // New Password
                          Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                             validator: (v) {
                               if (v == null || v.isEmpty) return 'Password is required';
                               if (v.length < 6 || v.length > 14) {
                                 return 'Password must be between 6 and 14 characters';
                               }
                               if (!RegExp(r'[A-Z]').hasMatch(v)) {
                                 return 'Password must contain at least one uppercase letter';
                               }
                               if (!RegExp(r'[a-z]').hasMatch(v)) {
                                 return 'Password must contain at least one lowercase letter';
                               }
                               if (!RegExp(r'[0-9]').hasMatch(v)) {
                                 return 'Password must contain at least one number';
                               }
                               if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(v)) {
                                 return 'Password must contain at least one symbol';
                               }
                               return null;
                             },
                             decoration: InputDecoration(
                               hintText: 'Enter new password',
                               hintStyle: TextStyle(
                                 fontSize: 14,
                                 color: Colors.grey.shade400,
                               ),
                               helperText: 'Must be 6-14 characters with uppercase, lowercase, numbers, and symbols.',
                               helperMaxLines: 2,
                               helperStyle: TextStyle(fontSize: 11, color: AppColors.textMedium),
                               prefixIcon: const Icon(
                                 Icons.lock_outline_rounded,
                                 color: AppColors.primary,
                                 size: 18,
                               ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textMedium,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: _obscureConfirmPassword,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Confirm password is required';
                              if (v != _passwordCtrl.text) return 'Passwords do not match';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Re-enter new password',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_clock_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textMedium,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Save Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
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
