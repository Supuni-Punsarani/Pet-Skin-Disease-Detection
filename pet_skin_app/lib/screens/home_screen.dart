import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: AppColors.decorativeCircle,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 28),
                  _buildWelcomeCard(context),
                  const SizedBox(height: 28),
                  const Text('What We Do', style: AppTextStyles.heading2),
                  const SizedBox(height: 14),
                  _buildFeatureGrid(context),
                  const SizedBox(height: 28),
                  const Text('Common Pet Skin Conditions', style: AppTextStyles.heading2),
                  const SizedBox(height: 14),
                  _buildDiseaseCards(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PetDerm AI',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('Pet Skin Disease Detection', style: AppTextStyles.caption),
            ],
          ),
        ),
        const ProfileAvatar(),
      ],
    );
  }



  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B97FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Is Your Pet\nFeeling Unwell? 🐾',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Answer a few symptom questions and let AI help identify your pet\'s skin condition.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 160,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                context.read<DiagnosisProvider>().reset();
                Navigator.pushNamed(context, '/upload-image');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Start Diagnosis',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {'icon': Icons.quiz_outlined, 'title': 'Symptom\nCheck', 'route': '/question1'},
      {'icon': Icons.biotech_outlined, 'title': 'AI\nAnalysis', 'route': '/processing'},
      {'icon': Icons.medical_services_outlined, 'title': 'Treatment\nGuide', 'route': '/treatment'},
      {'icon': Icons.location_on_outlined, 'title': 'Find\nNearby Vet', 'route': '/vet'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((f) => _FeatureCard(
                icon: f['icon'] as IconData,
                title: f['title'] as String,
                onTap: () => Navigator.pushNamed(context, f['route'] as String),
              ))
          .toList(),
    );
  }

  Widget _buildDiseaseCards() {
    final diseases = [
      {'name': 'Mange', 'icon': '🦠', 'color': const Color(0xFFFFECEC)},
      {'name': 'Ringworm', 'icon': '🍄', 'color': const Color(0xFFFFF3E0)},
      {'name': 'Fungal Infection', 'icon': '🍄', 'color': const Color(0xFFFFF9E6)},
      {'name': 'Demodicosis', 'icon': '🦟', 'color': const Color(0xFFEDF7ED)},
      {'name': 'Bacterial Dermatosis', 'icon': '🧫', 'color': const Color(0xFFE8F4FF)},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: diseases
          .map((d) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: d['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(d['icon'] as String, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 7),
                    Text(d['name'] as String,
                        style: AppTextStyles.bodyBold.copyWith(fontSize: 12)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: true, onTap: () {}),
              _NavItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Scan',
                  isActive: false,
                  onTap: () {
                    context.read<DiagnosisProvider>().reset();
                    Navigator.pushNamed(context, '/upload-image');
                  }),
              _NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  isActive: false,
                  onTap: () => Navigator.pushNamed(context, '/history')),
              _NavItem(
                  icon: Icons.location_on_rounded,
                  label: 'Vets',
                  isActive: false,
                  onTap: () => Navigator.pushNamed(context, '/vet')),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.decorativeCircle,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : Colors.grey.shade400, size: 22),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isActive ? AppColors.primary : Colors.grey.shade400,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ],
      ),
    );
  }
}
