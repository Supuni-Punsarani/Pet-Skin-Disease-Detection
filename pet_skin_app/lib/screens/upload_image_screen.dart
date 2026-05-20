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

  Future<void> _pickImage() async {
    try {
      final picked =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      } else {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
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
            const Text(
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

            // Upload box
            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hasImage ? AppColors.primary : AppColors.decorativeCircle,
                    width: _hasImage ? 2 : 1.5,
                  ),
                ),
                child: _hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: kIsWeb && _imageBytes != null
                            ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                            : Image.file(File(_imagePath!),
                                fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.decorativeCircle,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.cloud_upload_outlined,
                                color: AppColors.primary, size: 32),
                          ),
                          const SizedBox(height: 14),
                          const Text('Tap to upload image',
                              style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('PNG, JPG supported',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 11)),
                        ],
                      ),
              ),
            ),

            if (_hasImage) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickImage,
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
