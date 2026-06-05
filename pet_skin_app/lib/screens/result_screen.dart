import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/common_widgets.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DiagnosisProvider>();
    final result = dp.result;

    if (result == null) {
      return const AppScaffold(
        showBack: true,
        child: Center(child: Text('No result found. Please restart.')),
      );
    }

    final confidencePct = (result.confidence * 100).toStringAsFixed(0);

    return AppScaffold(
      showBack: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Identified Result', style: AppTextStyles.heading1)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 12),

            // Save to History status banner
            if (dp.isSaving)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Saving scan to your history...',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            if (dp.saveError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Failed to save to history: ${dp.saveError}',
                        style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            if (dp.saveSuccess)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Scan saved to history successfully! ✅',
                        style: TextStyle(color: Colors.green.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Result Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.decorativeCircle, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResultRow(
                    label: 'Disease Name',
                    value: result.diseaseName,
                    valueStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF0F0F0)),
                  _ResultRow(
                    label: 'Confidence',
                    value: '$confidencePct%',
                    valueStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: result.confidence,
                      minHeight: 8,
                      backgroundColor: AppColors.decorativeCircle,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF0F0F0)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Severity',
                                style: AppTextStyles.caption),
                            const SizedBox(height: 6),
                            SeverityBadge(severity: result.severity),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pet Type',
                                style: AppTextStyles.caption),
                            const SizedBox(height: 6),
                            Text(result.petType,
                                style: AppTextStyles.bodyBold),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),
            const Text('About This Condition', style: AppTextStyles.heading2)
                .animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 10),
            Text(result.description, style: AppTextStyles.body)
                .animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 20),

            if (result.matchedSymptoms.isNotEmpty) ...[
              const Text('Matched Symptoms', style: AppTextStyles.heading2)
                  .animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.matchedSymptoms
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.decorativeCircle,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.primary)),
                        ))
                    .toList(),
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 20),
            ],

            // Urgency
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: Color(0xFFF57C00)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(result.urgency,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF57C00),
                        )),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 28),

            const Text('Professional Treatment Plan', style: AppTextStyles.heading2)
                .animate().fadeIn(delay: 900.ms),
            const SizedBox(height: 14),

            ...List.generate(result.treatments.length, (i) {
              return _TreatmentCard(
                index: i + 1,
                text: result.treatments[i],
                delay: (1000 + i * 100).ms,
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
                      'This is an AI-generated assessment. Always consult a licensed veterinarian for definitive diagnosis and treatment.',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1100.ms),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/vet'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('View Nearest Vet Locations',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ).animate().fadeIn(delay: 1000.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _ResultRow(
      {required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: valueStyle ?? AppTextStyles.bodyBold),
      ],
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
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textMedium))),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.2, end: 0);
  }
}
