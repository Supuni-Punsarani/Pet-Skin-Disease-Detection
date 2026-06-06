import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/common_widgets.dart';

class SymptomQuestion2Screen extends StatefulWidget {
  const SymptomQuestion2Screen({super.key});

  @override
  State<SymptomQuestion2Screen> createState() => _SymptomQuestion2ScreenState();
}

class _SymptomQuestion2ScreenState extends State<SymptomQuestion2Screen> {
  String? _q2Code; // scratching
  String? _q3Code; // skin look

  // Options are built dynamically in build() based on pet type
  List<(String, String)> _q2Options(String pet) => pet == 'Dog'
      ? const [
          ('A', 'Normal scratching'),
          ('B', 'Mild scratching'),
          ('C', 'Frequent scratching and licking'),
          ('D', 'Intense — cannot stop scratching'),
        ]
      : const [
          ('A', 'Normal occasional grooming'),
          ('B', 'Mild scratching or extra grooming'),
          ('C', 'Frequent scratching and licking'),
          ('D', 'Intense — cannot stop scratching'),
        ];

  List<(String, String)> _q3Options(String pet) => pet == 'Dog'
      ? const [
          ('A', 'Red patches'),
          ('B', 'Hair loss'),
          ('C', 'Flaky/greasy'),
          ('D', 'Clean'),
          ('E', 'Red+bumps'),
        ]
      : const [
          ('A', 'Red patches or inflamed skin'),
          ('B', 'Hair loss or bald patches'),
          ('C', 'Flaky, scaly or greasy coat'),
          ('D', 'Clean and normal appearance'),
          ('E', 'Bumps, scabs or raised areas'),
          ('F', 'Moist, weeping or crusty skin'),
        ];

  void _next() {
    if (_q2Code == null || _q3Code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer both questions'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    final dp = context.read<DiagnosisProvider>();
    dp.setAnswer(2, _q2Code!);
    dp.setAnswer(3, _q3Code!);
    Navigator.pushNamed(context, '/question3');
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.read<DiagnosisProvider>().selectedPet;
    final q2Opts = _q2Options(pet);
    final q3Opts = _q3Options(pet);
    final q2Question = pet == 'Dog'
        ? 'Is your dog scratching or licking the affected area?'
        : 'Is your pet scratching, licking, or over-grooming the affected area?';

    return AppScaffold(
      showBack: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearPercentIndicator(
              lineHeight: 6,
              percent: 3 / 6,
              backgroundColor: AppColors.decorativeCircle,
              progressColor: AppColors.primary,
              barRadius: const Radius.circular(10),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 6),
            Text(
              'Questions 2 & 3 of 6',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Tell Us More About\nSymptoms',
                style: AppTextStyles.heading1),
            const SizedBox(height: 20),

            // Q2 — Grooming / Scratching
            _buildCard(
              icon: Icons.pets_rounded,
              question: q2Question,
              options: q2Opts,
              selectedCode: _q2Code,
              onSelected: (code) => setState(() => _q2Code = code),
            ),
            const SizedBox(height: 16),

            // Q3 — Skin appearance
            _buildCard(
              icon: Icons.visibility_rounded,
              question: 'What does the affected skin look like?',
              options: q3Opts,
              selectedCode: _q3Code,
              onSelected: (code) => setState(() => _q3Code = code),
            ),
            const SizedBox(height: 30),

            PrimaryButton(label: 'Next', onTap: _next),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String question,
    required List<(String, String)> options,
    required String? selectedCode,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.decorativeCircle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.decorativeCircle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(question, style: AppTextStyles.bodyBold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...options.map(
            (opt) => LabeledOption(
              code: opt.$1,
              label: opt.$2,
              isSelected: selectedCode == opt.$1,
              onTap: () => onSelected(opt.$1),
            ),
          ),
        ],
      ),
    );
  }
}
