import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/storage/local_storage.dart';
import '../core/theme/app_theme.dart';
import '../screens/login_screen.dart';
import '../main.dart';

class EmagzAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  const EmagzAppBar({super.key, this.onBackPressed});

  ImageProvider _getAvatarImage() {
    final path = LocalStorage.getString('draft_image_path', defaultValue: '');
    if (path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return ResizeImage(FileImage(file), width: 80);
      }
    }
    return const ResizeImage(AssetImage('assets/images/hiker.jpg'), width: 80);
  }

  void _showProfileSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final activeMode = AppColors.themeMode;

            Widget themeOption({
              required String label,
              required IconData icon,
              required AppThemeMode mode,
              required Color accentColor,
              required Color bgPreview,
            }) {
              final isSelected = activeMode == mode;
              return GestureDetector(
                onTap: () async {
                  String themeString = 'system';
                  if (mode == AppThemeMode.light) themeString = 'light';
                  if (mode == AppThemeMode.dark) themeString = 'dark';
                  if (mode == AppThemeMode.sunset) themeString = 'sunset';

                  await LocalStorage.setString('theme_mode', themeString);

                  // Update global theme properties
                  AppColors.themeMode = mode;
                  MyApp.themeNotifier.value = mode;

                  // Rebuild bottom sheet state to reflect selection
                  setSheetState(() {});
                },
                child: Container(
                  width: 72,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bgPreview,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.fameoPurple
                          : AppColors.borderLight,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.fameoPurple.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? AppColors.fameoPurple : accentColor,
                        size: 20,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.fameoPurple
                              : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderDark.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: _getAvatarImage(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fameo - X User',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'admin@emagz.com',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Theme Selector Section
                    Text(
                      'Select Application Theme',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        themeOption(
                          label: 'System',
                          icon: Icons.settings_brightness_outlined,
                          mode: AppThemeMode.system,
                          accentColor: Colors.grey,
                          bgPreview: Colors.grey.withValues(alpha: 0.05),
                        ),
                        themeOption(
                          label: 'Light',
                          icon: Icons.light_mode_outlined,
                          mode: AppThemeMode.light,
                          accentColor: Colors.orange,
                          bgPreview: const Color(0xFFF7F8FC),
                        ),
                        themeOption(
                          label: 'Dark',
                          icon: Icons.dark_mode_outlined,
                          mode: AppThemeMode.dark,
                          accentColor: Colors.indigo,
                          bgPreview: const Color(0xFF1E1E1E),
                        ),
                        themeOption(
                          label: 'Sunset',
                          icon: Icons.wb_twilight_outlined,
                          mode: AppThemeMode.sunset,
                          accentColor: Colors.deepOrangeAccent,
                          bgPreview: const Color(0xFF2C1B47),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Logout Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        elevation: 0,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // Close sheet
                        await LocalStorage.setBool('isLoggedIn', false);
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: GoogleFonts.inter(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Back button or Logo
              Row(
                children: [
                  if (onBackPressed != null) ...[
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: onBackPressed,
                      color: AppColors.textDark,
                    ),
                    SizedBox(width: 8),
                  ],
                  // eMAGZ Logo (Blue Box with White Text)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emagzBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'eMAGZ',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              // Right: Notification Bell & Profile Avatar
              Row(
                children: [
                  // Bell Icon
                  IconButton(
                    icon: Icon(Icons.notifications_none, size: 26),
                    color: AppColors.textDark,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications tapped'),
                          duration: Duration(milliseconds: 700),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  // User Avatar with Tap Action
                  GestureDetector(
                    onTap: () => _showProfileSettingsSheet(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: _getAvatarImage(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
