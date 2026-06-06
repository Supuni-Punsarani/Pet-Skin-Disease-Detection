import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/vet_data_service.dart';
import '../widgets/common_widgets.dart';

class VetLocationScreen extends StatefulWidget {
  const VetLocationScreen({super.key});

  @override
  State<VetLocationScreen> createState() => _VetLocationScreenState();
}

class _VetLocationScreenState extends State<VetLocationScreen> {
  List<VetClinic> _clinics = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadVets();
  }

  Future<void> _loadVets() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _clinics = [];
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      final vets = await VetDataService.getNearbyVets(
          position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _clinics = vets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openMap(VetClinic clinic) async {
    final query = Uri.encodeComponent('${clinic.name}, ${clinic.address}');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map app.')),
        );
      }
    }
  }

  Future<void> _callVet(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer.')),
        );
      }
    }
  }

  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.monitor_heart_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nearby Vets',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (!_isLoading && _errorMsg == null)
                    GestureDetector(
                      onTap: _loadVets,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Refresh',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  const ProfileAvatar(),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 14),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.surfaceSoft, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search vet clinics near me...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 14),

            // Map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 230,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD4E8D6),
                        Color(0xFFB8D9C0),
                        Color(0xFFC8E0CA),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: [
                      // Grid overlay
                      Positioned.fill(
                        child: CustomPaint(painter: _MapGridPainter()),
                      ),

                      // Horizontal road
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            height: 5,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),

                      // Vertical road
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            const Flexible(flex: 42, child: SizedBox.expand()),
                            Container(
                              width: 5,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                            const Flexible(flex: 58, child: SizedBox.expand()),
                          ],
                        ),
                      ),

                      // Road label
                      const Positioned(
                        top: 108,
                        left: 10,
                        child: Text(
                          'Main Road',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0x66000000),
                          ),
                        ),
                      ),

                      // User location dot
                      Positioned(
                        top: 100,
                        left: 160,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A8EFF),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A8EFF)
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Vet Pin 1 - City Vet
                      const Positioned(
                        top: 38,
                        left: 200,
                        child: _MapPin(
                          emoji: '🏥',
                          label: 'City Vet',
                          color: AppColors.primary,
                        ),
                      ),

                      // Vet Pin 2 - PetCare
                      const Positioned(
                        top: 140,
                        left: 50,
                        child: _MapPin(
                          emoji: '🐾',
                          label: 'PetCare',
                          color: Color(0xFF9B6FA0),
                        ),
                      ),

                      // Vet Pin 3 - Animal Hosp
                      const Positioned(
                        top: 60,
                        right: 28,
                        child: _MapPin(
                          emoji: '🏥',
                          label: 'Animal Hosp.',
                          color: Color(0xFF4A70A0),
                        ),
                      ),

                      // Locate button
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                              child: Text('📍',
                                  style: TextStyle(fontSize: 17))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),

            const SizedBox(height: 12),

            // Clinic list
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMsg!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMedium)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadVets, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }
    if (_clinics.isEmpty) {
      return const Center(child: Text('No clinics found nearby.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_clinics.length} veterinary clinics found within 10km',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          ..._clinics.asMap().entries.map((e) {
            final i = e.key;
            final c = e.value;
            return _ClinicCard(
              clinic: c,
              isTopPick: i == 0,
              onTapMap: () => _openMap(c),
              onTapCall: () => _callVet(c.phone),
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 + i * 80))
            .slideY(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }
}

// ── Map grid painter ──────────────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0F4A7050)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Map pin ───────────────────────────────────────────────────────────────────
class _MapPin extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _MapPin(
      {required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Clinic card ───────────────────────────────────────────────────────────────
class _ClinicCard extends StatelessWidget {
  final VetClinic clinic;
  final bool isTopPick;
  final VoidCallback onTapMap;
  final VoidCallback onTapCall;

  const _ClinicCard({
    required this.clinic,
    required this.isTopPick,
    required this.onTapMap,
    required this.onTapCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTopPick
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.surfaceSoft,
          width: isTopPick ? 2 : 1.5,
        ),
        boxShadow: isTopPick
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  clinic.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surfaceSoft,
                    child: const Center(child: Icon(Icons.maps_home_work_rounded, color: AppColors.primary)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isTopPick
                            ? AppColors.primary
                            : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clinic.address,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Open/Closed badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: clinic.isOpen
                      ? AppColors.success.withValues(alpha: 0.12)
                      : const Color(0xFFE05050).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  clinic.isOpen ? 'OPEN' : 'CLOSED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: clinic.isOpen
                        ? AppColors.success
                        : const Color(0xFFE05050),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Meta row: distance + rating
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                '${clinic.distanceKm.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  shape: BoxShape.circle,
                ),
              ),
              const Text('⭐', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                '${clinic.rating} (${clinic.reviewCount})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),

          // Badge
          if (isTopPick) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🏆 Top Rated · Vet Clinic',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: '📞 Call',
                  isPrimary: false,
                  onTap: onTapCall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: '📍 Directions',
                  isPrimary: true,
                  onTap: onTapMap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? AppColors.primary
                : AppColors.surfaceSoft,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isPrimary ? Colors.white : AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }
}

