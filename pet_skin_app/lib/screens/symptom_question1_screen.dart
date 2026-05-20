import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/common_widgets.dart';

class SymptomQuestion1Screen extends StatefulWidget {
  const SymptomQuestion1Screen({super.key});

  @override
  State<SymptomQuestion1Screen> createState() => _SymptomQuestion1ScreenState();
}

class _SymptomQuestion1ScreenState extends State<SymptomQuestion1Screen> {
  String? _selectedCode;

  static const List<(String, String)> _options = [
    ('A', 'Less than 1 week'),
    ('B', '1-2 weeks'),
    ('C', 'More than 2 weeks'),
    ('D', 'Seasonal'),
    ('E', 'No problem'),
  ];

  void _next() {
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    context.read<DiagnosisProvider>().setAnswer(1, _selectedCode!);
    Navigator.pushNamed(context, '/question2');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearPercentIndicator(
              lineHeight: 6,
              percent: 1 / 6,
              backgroundColor: AppColors.decorativeCircle,
              progressColor: AppColors.primary,
              barRadius: const Radius.circular(10),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 6),
            Text(
              'Question 1 of 6',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Tell Us More About\nSymptoms',
                style: AppTextStyles.heading1),
            const SizedBox(height: 20),
            Container(
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
                        child: const Icon(Icons.access_time_rounded,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'How long has the skin problem been present?',
                          style: AppTextStyles.bodyBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._options.map(
                    (opt) => LabeledOption(
                      code: opt.$1,
                      label: opt.$2,
                      isSelected: _selectedCode == opt.$1,
                      onTap: () => setState(() => _selectedCode = opt.$1),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(label: 'Next', onTap: _next),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
