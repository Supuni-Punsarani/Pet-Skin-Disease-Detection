import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/common_widgets.dart';

class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.read<DiagnosisProvider>().result;

    if (result == null) {
      return const AppScaffold(
        showBack: true,
        child: Center(child: Text('No diagnosis found.')),
      );
    }

    return AppScaffold(
      showBack: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Treatment Guidance', style: AppTextStyles.heading1)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 8),
            Text('For ${result.diseaseName}',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.primary)),
            const SizedBox(height: 20),

            // Severity banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9B97FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Treatment Plan Ready',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                        Text(
                            '${result.treatments.length} recommended steps',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            )),
                      ],
                    ),
                  ),
                  SeverityBadge(severity: result.severity),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            const Text('Recommended Steps', style: AppTextStyles.heading2)
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 14),

            ...List.generate(result.treatments.length, (i) {
              return _TreatmentCard(
                index: i + 1,
                text: result.treatments[i],
                delay: (400 + i * 100).ms,
              );
            }),

            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB3D9FF)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFF1976D2), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is AI-generated guidance. Always consult a licensed veterinarian for proper diagnosis and treatment.',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 900.ms),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Find Nearby Vet',
              onTap: () => Navigator.pushNamed(context, '/vet'),
            ).animate().fadeIn(delay: 1000.ms),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/select-pet', (_) => false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ).animate().fadeIn(delay: 1100.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final int index;
  final String text;
  final Duration delay;
  const _TreatmentCard(
      {required this.index, required this.text, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.decorativeCircle),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 14, top: 2),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ),
          Expanded(
              child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.2, end: 0);
  }
}
