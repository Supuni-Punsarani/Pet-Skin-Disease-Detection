import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/common_widgets.dart';

class AiProcessingScreen extends StatefulWidget {
  const AiProcessingScreen({super.key});

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _runDiagnosis();
  }

  Future<void> _runDiagnosis() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final dp = context.read<DiagnosisProvider>();
    await dp.runDiagnosis();
    if (!mounted) return;

    if (dp.errorMessage != null) {
      final proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Connection Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text(
              'The AI Backend server could not be reached.\n\nError: ${dp.errorMessage}\n\nWould you like to see a rule-based offline diagnosis using your symptom answers instead?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5FD4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Show Offline Result', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (proceed != true) {
        if (!mounted) return;
        Navigator.pop(context); // Go back home
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A1B6E), Color(0xFF6B5FD4), Color(0xFF9B97FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.monitor_heart_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text('dermAi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const Spacer(),
                    const ProfileAvatar(),
                  ],
                ),
              ),

              const Spacer(),

              // Center pet image circle
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulsing ring
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 20),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1.05, 1.05),
                          duration: 1500.ms,
                          curve: Curves.easeInOut),

                  // Mid ring
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),

                  // Inner circle with pet image
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B5FD4).withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1450778869180-41d0601e046e?w=400&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('🐕🐈', style: TextStyle(fontSize: 60)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Analyzing badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(30),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 20)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.85, end: 1.15, duration: 700.ms),
                    const SizedBox(width: 10),
                    const Text(
                      'Scanning image and symptoms...',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .fade(begin: 0.7, end: 1.0, duration: 1000.ms),

              const SizedBox(height: 16),
              Text(
                'This may take a few seconds',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7)),
              ),

              const Spacer(),

              // Step dots
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
                child: Row(
                  children: [
                    const _StepDot(label: 'Symptoms\nAnalyzed', done: true),
                    Expanded(
                        child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.4))),
                    const _StepDot(label: 'Disease\nMatching', done: false),
                    Expanded(
                        child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.4))),
                    const _StepDot(label: 'Result\nReady', done: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  const _StepDot({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? Colors.white : Colors.white.withValues(alpha: 0.25),
          ),
          child: done
              ? const Icon(Icons.check_rounded,
                  color: Color(0xFF6B5FD4), size: 16)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 9,
              height: 1.3),
        ),
      ],
    );
  }
}
