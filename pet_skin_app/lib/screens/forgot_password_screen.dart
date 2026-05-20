import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.sendPasswordReset(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.decorativeCircle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset_rounded,
                            color: AppColors.primary, size: 40),
                      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text('Forgot Password?',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Enter your email and we\'ll send you a reset link.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(height: 36),
                    if (_sent)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFA5D6A7)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.green),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Reset link sent! Check your email inbox.',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn()
                    else ...[
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textDark),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Valid email required'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                              fontSize: 13, color: AppColors.textMedium),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AppColors.primary, size: 18),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.decorativeCircle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.decorativeCircle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _sendReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Send Reset Link',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
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
