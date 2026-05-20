import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../models/post_model.dart';

class HoverReactionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const HoverReactionButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<HoverReactionButton> createState() => _HoverReactionButtonState();
}

class _HoverReactionButtonState extends State<HoverReactionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.fameoPurple.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.10 : 1.0,
          _isHovered ? 1.10 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        child: InkWell(
          onTap: widget.onPressed,
          customBorder: const CircleBorder(),
          child: widget.child,
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final PostModel post;
  final ValueChanged<PostModel>? onPostChanged;

  const PostCard({super.key, required this.post, this.onPostChanged});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isHovered = false;

  Color _getPostHoverColor(String username) {
    final code = username.hashCode;
    final List<Color> colors = [
      AppColors.fameoPurple,
      AppColors.emagzBlue,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.indigo,
    ];
    return colors[code.abs() % colors.length];
  }

  ImageProvider _getAvatarImage(String imageUrl) {
    ImageProvider provider;
    if (imageUrl.isEmpty) {
      provider = const AssetImage('assets/images/hiker.jpg');
    } else if (imageUrl.startsWith('assets/')) {
      provider = AssetImage(imageUrl);
    } else {
      final file = File(imageUrl);
      if (file.existsSync()) {
        provider = FileImage(file);
      } else {
        provider = const AssetImage('assets/images/hiker.jpg');
      }
    }
    return ResizeImage(provider, width: 100);
  }

  Widget _buildPostImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/hiker.jpg',
        fit: BoxFit.cover,
        cacheWidth: 600,
      );
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover, cacheWidth: 600);
    } else {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, cacheWidth: 600);
      } else {
        return Image.asset(
          'assets/images/hiker.jpg',
          fit: BoxFit.cover,
          cacheWidth: 600,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.01 : 1.0,
          _isHovered ? 1.01 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.fameoPurple.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: _getAvatarImage(post.profileImageUrl),
                      ),
                      SizedBox(width: 10),
                      // Username & Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.username,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(width: 2),
                              Text(
                                post.location.isNotEmpty
                                    ? post.location
                                    : 'Earth',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // More Options
                  IconButton(
                    icon: Icon(Icons.more_horiz, color: AppColors.textMuted),
                    onPressed: () {
                      _showPostDetailsModal(context, post);
                    },
                  ),
                ],
              ),
            ),

            // Post Image
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.grey[200],
                      child: _buildPostImage(post.imageUrl),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: _isHovered
                          ? _getPostHoverColor(
                              post.username,
                            ).withValues(alpha: 0.10)
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),

            // Action Panel (Like, Comment, Share)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Like Action
                      HoverReactionButton(
                        onPressed: () {
                          if (widget.onPostChanged != null) {
                            final updatedLikes = post.isLiked
                                ? post.likes - 1
                                : post.likes + 1;
                            widget.onPostChanged!(
                              post.copyWith(
                                isLiked: !post.isLiked,
                                likes: updatedLikes < 0 ? 0 : updatedLikes,
                              ),
                            );
                          }
                        },
                        child: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: post.isLiked ? Colors.red : AppColors.textDark,
                          size: 26,
                        ),
                      ),
                      SizedBox(width: 8),

                      // Comment Action (Hide or disabled based on allowComments toggle)
                      if (post.allowComments) ...[
                        HoverReactionButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comment thread opened'),
                                duration: Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.textDark,
                            size: 24,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Comments Disabled',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Share Action (Hide if postSharing is false)
                  if (post.postSharing)
                    HoverReactionButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post link copied to clipboard!'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.send_outlined,
                        color: AppColors.textDark,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),

            // Likes Count, Caption and Tags
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Likes display (adapted to hideLikes setting)
                  if (!post.hideLikes) ...[
                    Text(
                      '${post.likes} likes',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6),
                  ] else ...[
                    Text(
                      'Likes hidden',
                      style: GoogleFonts.inter(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 6),
                  ],

                  // Caption with bold username
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '${post.username} ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  // Metadata time
                  Text(
                    post.timestamp,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetailsModal(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.borderDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Post Settings Info',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: const Text('Allow Like & View From'),
                trailing: Chip(
                  label: Text(post.allowLikeViewFrom),
                  backgroundColor: AppColors.fameoPurple.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: AppColors.fameoPurple,
                    fontSize: 12,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.remove_red_eye_outlined),
                title: const Text('Hide Views Setting'),
                trailing: Text(
                  post.hideViews ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: post.hideViews ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.comment_bank_outlined),
                title: const Text('Allow Comments'),
                trailing: Text(
                  post.allowComments ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: post.allowComments ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
