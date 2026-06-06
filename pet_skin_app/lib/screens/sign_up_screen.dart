import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Pet Fields
  final _petNameCtrl = TextEditingController();
  final _petBreedCtrl = TextEditingController();
  final _petAgeCtrl = TextEditingController();
  final _petWeightCtrl = TextEditingController();

  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _petNameCtrl.dispose();
    _petBreedCtrl.dispose();
    _petAgeCtrl.dispose();
    _petWeightCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phone: _phoneCtrl.text.trim(),
      petName: _petNameCtrl.text.trim(),
      petBreed: _petBreedCtrl.text.trim(),
      petAge: _petAgeCtrl.text.trim(),
      petWeight: _petWeightCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      // User specifically requested to redirect back to Sign In after Sign Up.
      // Firebase auto-signs in on registration, so we sign them out to force a manual sign-in.
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Account created successfully! Please sign in.'),
            backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      final msg = auth.errorMessage ?? 'Registration failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bottom right purple circle
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
                    const SizedBox(height: 16),

                    // ignore: prefer_const_constructors
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fill in the details below to get started',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 24),

                    // --- PET DETAILS ---
                    const Text('Pet Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 12),

                    _buildField(
                      controller: _petNameCtrl,
                      label: 'Pet Name',
                      icon: Icons.pets,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Pet name is required';
                        if (v.trim().length < 2) return 'Pet name must be at least 2 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildField(
                      controller: _petBreedCtrl,
                      label: 'Breed (e.g., Golden Retriever)',
                      icon: Icons.category_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Breed is required';
                        if (v.trim().length < 2) return 'Please enter a valid breed';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _petAgeCtrl,
                            label: 'Age (Years)',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Age is required';
                              final age = int.tryParse(v.trim());
                              if (age == null || age < 0) return 'Enter a valid age';
                              if (age > 50) return 'Age seems too high';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _petWeightCtrl,
                            label: 'Weight (kg)',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Weight is required';
                              final w = double.tryParse(v.trim());
                              if (w == null || w <= 0) return 'Enter a valid weight';
                              if (w > 200) return 'Weight seems too high';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: AppColors.decorativeCircle),
                    const SizedBox(height: 16),

                    // --- OWNER DETAILS ---
                    const Text('Owner Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 12),

                    _buildField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Name is required';
                        if (v.trim().length < 2) return 'Name must be at least 2 characters';
                        if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(v.trim())) return 'Name must contain letters only';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),



                    _buildField(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Phone number is required';
                        final digits = v.trim().replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
                        if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return 'Phone must contain numbers only';
                        if (digits.length < 7 || digits.length > 15) return 'Enter a valid phone number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
                          return 'Enter a valid email (e.g. name@email.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textDark),
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
                      decoration: _inputDeco(
                        'Password',
                        Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textMedium,
                            size: 18,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        helperText: 'Must be 6-14 characters with uppercase, lowercase, numbers, and symbols.',
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _register,
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
                            : const Text('Next',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Sign In',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: _inputDeco(label, icon),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon, {Widget? suffix, String? helperText}) {
    return InputDecoration(
      labelText: label.isEmpty ? null : label,
      hintText: label.isEmpty ? null : label,
      helperText: helperText,
      helperMaxLines: 2,
      helperStyle: const TextStyle(fontSize: 11, color: AppColors.textMedium),
      labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMedium),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.decorativeCircle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.decorativeCircle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
