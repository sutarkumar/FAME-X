import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'direct_message_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockChats = [
      {
        'name': 'john_d',
        'msg': 'Are you joining the hike tomorrow?',
        'time': '10 min ago',
        'unread': 2,
        'online': true,
      },
      {
        'name': 'sarah_m',
        'msg': 'That sunset photo was breath-taking!',
        'time': '1 hour ago',
        'unread': 0,
        'online': true,
      },
      {
        'name': 'alex_wander',
        'msg': 'Let me share the coordinates.',
        'time': '3 hours ago',
        'unread': 1,
        'online': false,
      },
      {
        'name': 'bella_lens',
        'msg': 'I updated the summit post.',
        'time': 'Yesterday',
        'unread': 0,
        'online': true,
      },
      {
        'name': 'nature_hub',
        'msg': 'New feature release is live.',
        'time': 'May 18',
        'unread': 0,
        'online': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Chats',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note, color: AppColors.fameoPurple, size: 28),
            onPressed: () {},
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
                itemCount: mockChats.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 76,
                  endIndent: 16,
                  color: AppColors.borderLight,
                ),
                itemBuilder: (context, index) {
                  final chat = mockChats[index];
                  final isOnline = chat['online'] as bool;
                  final unreadCount = chat['unread'] as int;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
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
                        if (isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      chat['name'] as String,
                      style: GoogleFonts.inter(
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: AppColors.textDark,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      chat['msg'] as String,
                      style: GoogleFonts.inter(
                        fontWeight: unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: unreadCount > 0
                            ? AppColors.textDark
                            : AppColors.textMuted,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          chat['time'] as String,
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.fameoPurple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 20),
                            alignment: Alignment.center,
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DirectMessageScreen(chatData: chat),
                        ),
                      );
                    },
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
