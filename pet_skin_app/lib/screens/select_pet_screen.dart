import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../providers/auth_provider.dart';

class SelectPetScreen extends StatelessWidget {
  const SelectPetScreen({super.key});

  @override
  Widget build(BuildContext context) {

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
          // Bottom left small circle
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      _DermAiLogo(),
                    ],
                  ),
                ),

                const Spacer(),

                // Title
                const Text(
                  'Select Your Pet Type',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: 40),

                // Pet options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PetCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=300&q=80',
                      fallbackEmoji: '🐕',
                      label: 'Dog',
                      isComingSoon: false,
                      onTap: () {
                        context.read<DiagnosisProvider>().selectPet('Dog');
                        context.read<DiagnosisProvider>().reset();
                        Navigator.pushNamed(context, '/signin');
                      },
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),

                    const SizedBox(width: 28),

                    _PetCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=300&q=80',
                      fallbackEmoji: '🐈',
                      label: 'Cat',
                      isComingSoon: false,
                      onTap: () {
                        context.read<DiagnosisProvider>().selectPet('Cat');
                        context.read<DiagnosisProvider>().reset();
                        Navigator.pushNamed(context, '/signin');
                      },
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3, end: 0),
                  ],
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final String imageUrl;
  final String fallbackEmoji;
  final String label;
  final bool isComingSoon;
  final VoidCallback onTap;

  const _PetCard({
    required this.imageUrl,
    required this.fallbackEmoji,
    required this.label,
    required this.isComingSoon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 130,
            height: 165,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isComingSoon
                    ? Colors.grey.shade200
                    : AppColors.decorativeCircle,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular pet image
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isComingSoon
                          ? Colors.grey.shade200
                          : AppColors.decorativeCircle,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.surface,
                          child: Center(
                            child: Text(fallbackEmoji,
                                style: const TextStyle(fontSize: 36)),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: Center(
                          child: Text(fallbackEmoji,
                              style: const TextStyle(fontSize: 36)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isComingSoon
                        ? Colors.grey.shade400
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (isComingSoon)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Soon',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DermAiLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.monitor_heart_outlined,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        const Text('dermAi',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      ],
    );
  }
}
