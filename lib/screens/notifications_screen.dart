import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockNotifications = [
      {
        'name': 'john_d',
        'type': 'like',
        'detail': 'liked your post.',
        'time': '5 min ago',
        'hasPreview': true,
      },
      {
        'name': 'sarah_m',
        'type': 'comment',
        'detail': 'commented: "Stunning shot!"',
        'time': '1 hour ago',
        'hasPreview': true,
      },
      {
        'name': 'alex_wander',
        'type': 'follow',
        'detail': 'started following you.',
        'time': '2 hours ago',
        'hasPreview': false,
      },
      {
        'name': 'bella_lens',
        'type': 'mention',
        'detail': 'mentioned you in a caption.',
        'time': 'Yesterday',
        'hasPreview': true,
      },
      {
        'name': 'nature_hub',
        'type': 'post',
        'detail': 'published a new update.',
        'time': '3 days ago',
        'hasPreview': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                color: AppColors.fameoPurple,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
        shape: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxContentWidth = constraints.maxWidth > 700
              ? 600
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxContentWidth,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                itemCount: mockNotifications.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 76,
                  endIndent: 16,
                  color: AppColors.borderLight,
                ),
                itemBuilder: (context, index) {
                  final item = mockNotifications[index];
                  final type = item['type'] as String;
                  final hasPreview = item['hasPreview'] as bool;

                  IconData typeIcon;
                  Color iconColor;

                  switch (type) {
                    case 'like':
                      typeIcon = Icons.favorite;
                      iconColor = AppColors.error;
                      break;
                    case 'comment':
                      typeIcon = Icons.chat_bubble;
                      iconColor = AppColors.fameoPurple;
                      break;
                    case 'follow':
                      typeIcon = Icons.person_add;
                      iconColor = AppColors.emagzBlue;
                      break;
                    case 'mention':
                      typeIcon = Icons.alternate_email;
                      iconColor = Colors.orange;
                      break;
                    default:
                      typeIcon = Icons.info;
                      iconColor = AppColors.textMuted;
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(
                              'assets/images/hiker.jpg',
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(typeIcon, size: 12, color: iconColor),
                          ),
                        ),
                      ],
                    ),
                    title: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                        children: [
                          TextSpan(
                            text: '${item['name']} ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item['detail'] as String),
                        ],
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item['time'] as String,
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    trailing: hasPreview
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/images/hiker.jpg',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              cacheWidth: 100,
                            ),
                          )
                        : null,
                    onTap: () {},
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
