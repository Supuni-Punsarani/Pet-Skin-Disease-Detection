import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text('Settings',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ProfileAvatar(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.decorativeCircle,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        auth.userName.isNotEmpty
                            ? auth.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.userName,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Text(auth.userEmail,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 30),

            // Preferences
            _buildSectionHeader('Preferences'),
            _buildSettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Push Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => themeProvider.toggleTheme(val),
              ),
            ),
            _buildSettingsTile(
              icon: Icons.language_rounded,
              title: 'App Language',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('English',
                      style: TextStyle(color: AppColors.textMedium)),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMedium),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Support & About
            _buildSectionHeader('Support & About'),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () async {
                final uri = Uri.parse(
                    'https://www.example.com/privacy-policy');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About PetDerm AI',
              trailing: Text('v1.0.0',
                  style: TextStyle(color: AppColors.textMedium)),
            ),

            const SizedBox(height: 40),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/signin', (r) => false);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Log Out',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.red.shade50,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.decorativeCircle,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textDark)),
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMedium),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
