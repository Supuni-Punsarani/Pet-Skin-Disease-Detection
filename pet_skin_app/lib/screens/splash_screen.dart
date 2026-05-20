import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A1B6E), Color(0xFF4A3BAA), Color(0xFF6B5FD4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative blur circles
              Positioned(
                top: 60,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 20),

                  // Logo row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.monitor_heart_outlined,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'dermAi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Smart Skin Care for Cats & Dogs',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 30),

                  // Hero pet image
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                              width: 24,
                            ),
                          ),
                        ),
                        // Middle glow ring
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                        // Inner circle with pet image
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B5FD4)
                                    .withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1444212477490-ca407925329e?w=400&q=80',
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: Text('🐕‍🦺🐈',
                                      style: TextStyle(fontSize: 60)),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text('🐕‍🦺🐈',
                                    style: TextStyle(fontSize: 60)),
                              ),
                            ),
                          ),
                        ),
                        // Sparkle dots
                        ..._buildSparkles(),
                      ],
                    ),
                  )
                      .animate()
                      .scale(duration: 700.ms, curve: Curves.elasticOut)
                      .fadeIn(),

                  // Title
                  const Text(
                    'AI-Powered Pet\nSkin Care',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  Text(
                    'Detect skin conditions, get treatment\nplans & find nearby vets instantly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 40),

                  // GET STARTED button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/select-pet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          'GET STARTED',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    final positions = [
      const Offset(-110, -80),
      const Offset(105, -90),
      const Offset(-120, 60),
      const Offset(115, 70),
      const Offset(-60, -120),
      const Offset(70, -115),
    ];
    return positions.map((pos) {
      return Positioned(
        left: 145 + pos.dx,
        top: 145 + pos.dy,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.2, 1.2),
              duration: (800 + positions.indexOf(pos) * 200).ms,
            )
            .fadeIn(),
      );
    }).toList();
  }
}
