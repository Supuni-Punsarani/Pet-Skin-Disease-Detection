import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/common_widgets.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  Uint8List? _imageBytes;
  String? _imagePath;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked =
          await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imagePath = null;
        });
      } else {
        setState(() {
          _imagePath = picked.path;
          _imageBytes = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _showPickOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.decorativeCircle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _OptionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _OptionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasImage => _imageBytes != null || _imagePath != null;

  void _addImage() {
    if (!_hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an image first.'),
            backgroundColor: AppColors.primary),
      );
      return;
    }
    final dp = context.read<DiagnosisProvider>();
    if (kIsWeb && _imageBytes != null) {
      dp.addImage('web:${_imageBytes!.lengthInBytes}');
    } else if (_imagePath != null) {
      dp.addImage(_imagePath!);
    }
    Navigator.pushNamed(context, '/view-image');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload Pet Skin Image',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a clear photo of the affected skin area',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 30),

            // Selector or Image preview
            if (!_hasImage)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.decorativeCircle,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: AppColors.decorativeCircle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_outlined,
                                  color: AppColors.primary, size: 26),
                            ),
                            const SizedBox(height: 14),
                            Text('Use Camera',
                                style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Take a real-time photo',
                                style: TextStyle(
                                    color: AppColors.textMedium, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.decorativeCircle,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: AppColors.decorativeCircle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_library_outlined,
                                  color: AppColors.primary, size: 26),
                            ),
                            const SizedBox(height: 14),
                            Text('From Gallery',
                                style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Browse existing photos',
                                style: TextStyle(
                                    color: AppColors.textMedium, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: kIsWeb && _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : Image.file(File(_imagePath!), fit: BoxFit.cover),
                ),
              ),

            if (_hasImage) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _showPickOptionsSheet,
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.primary, size: 16),
                label: const Text('Change Image',
                    style:
                        TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _addImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Add',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.decorativeCircle),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
