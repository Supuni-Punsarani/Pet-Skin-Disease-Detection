import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// ─── AppScaffold ─────────────────────────────────────────────────────────────
/// Provides a consistent scaffold with the dermAi AppBar header.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBack;
  final List<Widget>? actions;
  final bool showDecorativeCircle;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBack = true,
    this.actions,
    this.showDecorativeCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: showBack ? 80 : 56,
        leading: showBack
            ? Row(
                children: [
                  const SizedBox(width: 8),
                  GestureDetector(
                    child: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.primary),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  _DermAiIcon(),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: _DermAiIcon(),
              ),
        title: title != null
            ? Text(
                title!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              )
            : const Text(
                'dermAi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
        actions: actions ??
            [
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: ProfileAvatar(),
              ),
            ],
      ),
      body: Stack(
        children: [
          if (showDecorativeCircle)
            Positioned(
              bottom: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.decorativeCircle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _DermAiIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.monitor_heart_outlined,
          color: Colors.white, size: 18),
    );
  }
}

/// ─── ProfileAvatar & Menu ──────────────────────────────────────────────────────
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showProfileMenu(context),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.decorativeCircle,
        child: const Icon(Icons.person, size: 20, color: AppColors.primary),
      ),
    );
  }
}

void showProfileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.history_rounded, color: AppColors.primary),
                title: const Text('Diagnosis History', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/history');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/signin', (r) => false);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ─── PrimaryButton ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

/// ─── OptionCheckbox ───────────────────────────────────────────────────────────
class OptionCheckbox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isRadio;
  final ValueChanged<bool> onChanged;

  const OptionCheckbox({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isRadio,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: isRadio ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isRadio ? null : BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? AppColors.primary : AppColors.textMedium,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── SeverityBadge ────────────────────────────────────────────────────────────
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  Color get _color {
    switch (severity.toLowerCase()) {
      case 'none':
      case 'healthy':
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
      case 'severe':
        return Colors.red;
      default:
        return AppColors.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// ─── LabeledOption ────────────────────────────────────────────────────────────
/// A styled radio-style option row with a letter badge (A/B/C...).
/// Used by all symptom question screens.
class LabeledOption extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const LabeledOption({
    super.key,
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
              ),
              alignment: Alignment.center,
              child: Text(
                code,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? AppColors.primary : AppColors.textMedium,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
