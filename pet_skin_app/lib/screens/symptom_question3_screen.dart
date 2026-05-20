import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/common_widgets.dart';

class SymptomQuestion3Screen extends StatefulWidget {
  const SymptomQuestion3Screen({super.key});

  @override
  State<SymptomQuestion3Screen> createState() => _SymptomQuestion3ScreenState();
}

class _SymptomQuestion3ScreenState extends State<SymptomQuestion3Screen> {
  String? _q4Code; // smell
  String? _q5Code; // environment
  String? _q6Code; // behavior

  static const List<(String, String)> _q4Options = [
    ('A', 'No unusual smell'),
    ('B', 'Mild odour'),
    ('C', 'Strong or unpleasant smell'),
  ];

  // Q5 options differ by pet: dogs have 5 options, cats have 4
  List<(String, String)> _q5Options(String pet) => pet == 'Dog'
      ? const [
          ('A', 'Outdoor / mud'),
          ('B', 'Mostly indoors'),
          ('C', 'Damp or humid area'),
          ('D', 'Near other dogs'),
          ('E', 'Allergens / dust'),
        ]
      : const [
          ('A', 'Normal indoor and outdoor access'),
          ('B', 'Mostly indoors'),
          ('C', 'Damp or humid environment'),
          ('D', 'Recently in contact with other animals'),
        ];

  static const List<(String, String)> _q6Options = [
    ('A', 'Acting normally'),
    ('B', 'Restless or unsettled'),
    ('C', 'Uncomfortable or irritable'),
  ];

  void _submit() {
    if (_q4Code == null || _q5Code == null || _q6Code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all three questions'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    final dp = context.read<DiagnosisProvider>();
    dp.setAnswer(4, _q4Code!);
    dp.setAnswer(5, _q5Code!);
    dp.setAnswer(6, _q6Code!);
    Navigator.pushNamed(context, '/processing');
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.read<DiagnosisProvider>().selectedPet;
    final q5Opts = _q5Options(pet);
    return AppScaffold(
      showBack: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearPercentIndicator(
              lineHeight: 6,
              percent: 1.0,
              backgroundColor: AppColors.decorativeCircle,
              progressColor: AppColors.primary,
              barRadius: const Radius.circular(10),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 6),
            Text(
              'Questions 4, 5 & 6 of 6',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Tell Us More About\nSymptoms',
                style: AppTextStyles.heading1),
            const SizedBox(height: 20),

            // Q4 — Smell
            _buildCard(
              icon: Icons.air_rounded,
              question: 'Is there any unusual smell from the skin?',
              options: _q4Options,
              selectedCode: _q4Code,
              onSelected: (code) => setState(() => _q4Code = code),
            ),
            const SizedBox(height: 16),

            // Q5 — Environment
            _buildCard(
              icon: Icons.nature_people_rounded,
              question: 'Any recent environmental contact?',
              options: q5Opts,
              selectedCode: _q5Code,
              onSelected: (code) => setState(() => _q5Code = code),
            ),
            const SizedBox(height: 16),

            // Q6 — Behavior
            _buildCard(
              icon: Icons.psychology_rounded,
              question: "Has your ${pet.toLowerCase()}'s behavior changed?",
              options: _q6Options,
              selectedCode: _q6Code,
              onSelected: (code) => setState(() => _q6Code = code),
            ),
            const SizedBox(height: 30),

            PrimaryButton(label: 'Continue Diagnosis', onTap: _submit),
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
