import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'dart:typed_data';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

class ViewImageScreen extends StatefulWidget {
  const ViewImageScreen({super.key});

  @override
  State<ViewImageScreen> createState() => _ViewImageScreenState();
}

class _ViewImageScreenState extends State<ViewImageScreen> {
  Uint8List? _imageBytes;
  final _picker = ImagePicker();
  bool _showFullImage = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('bytes')) {
      _imageBytes = args['bytes'] as Uint8List?;
    }
  }

  // Load from provider if bytes weren't passed (happens on first upload)
  String? get _activeImagePath {
    final dp = context.read<DiagnosisProvider>();
    final path = dp.primaryImagePath;
    if (path != null && path.startsWith('web:')) {
      return null; // Not a real file path
    }
    return path;
  }

  Future<void> _addAnotherImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      context.read<DiagnosisProvider>().addImage(picked.path);
      setState(() {
        _imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _analyzeImage() {
    Navigator.pushNamed(context, '/question1');
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthProvider>().userName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.monitor_heart_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('dermAi',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const Spacer(),
                      const ProfileAvatar(),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'View Image',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ).animate().fadeIn(duration: 400.ms),

                        const SizedBox(height: 20),

                        // Image display
                        GestureDetector(
                          onTap: () => setState(
                              () => _showFullImage = !_showFullImage),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: _showFullImage ? 280 : 180,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.decorativeCircle, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Builder(
                                builder: (context) {
                                  if (_imageBytes != null) {
                                    return Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                    );
                                  } else if (_activeImagePath != null) {
                                    return Image.file(
                                      File(_activeImagePath!),
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 60,
                                        color: AppColors.textMedium,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 20),

                        // View Image toggle
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () => setState(
                                () => _showFullImage = !_showFullImage),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(
                              _showFullImage ? 'Collapse Image' : 'View Image',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 6),

                        Text('or',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13)),

                        const SizedBox(height: 6),

                        // Add Another Image
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton(
                            onPressed: _addAnotherImage,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Add Another Image',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ),
                        ).animate().fadeIn(delay: 250.ms),

                        const SizedBox(height: 16),

                        // Analyze Image
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _analyzeImage,
                            icon: const Icon(Icons.biotech_outlined, size: 18),
                            label: const Text('Analyze Image',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
