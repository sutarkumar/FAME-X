import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../core/storage/local_storage.dart';
import '../core/theme/app_theme.dart';
import '../models/post_model.dart';
import '../widgets/emagz_app_bar.dart';

class CreatePostDetailsScreen extends StatefulWidget {
  const CreatePostDetailsScreen({super.key});

  @override
  State<CreatePostDetailsScreen> createState() =>
      _CreatePostDetailsScreenState();
}

class _CreatePostDetailsScreenState extends State<CreatePostDetailsScreen> {
  final TextEditingController _descController = TextEditingController();
  final List<String> _suggestedTags = [
    '#nature',
    '#photography',
    '#adventure',
    '#sunset',
    '#fameo',
  ];

  // Settings states
  bool _hideLikes = false;
  bool _hideViews = false;
  bool _hideSettings = false;
  bool _allowComments = true;
  bool _postSharing = true;

  // Privacy selection
  String _allowLikeViewFrom =
      'Everyone'; // Everyone, Followers, Specific Profiles

  // Uploading animation state
  bool _isUploading = false;

  // Selected local image path draft
  String? _pickedImagePath;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName =
            'fame_x_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File savedImage = await File(
          image.path,
        ).copy('${directory.path}/$fileName');

        setState(() {
          _pickedImagePath = savedImage.path;
        });
        LocalStorage.setString('draft_image_path', savedImage.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Widget _buildPreviewImage() {
    if (_pickedImagePath != null && _pickedImagePath!.isNotEmpty) {
      final file = File(_pickedImagePath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Image.asset('assets/images/hiker.jpg', fit: BoxFit.cover);
  }

  @override
  void initState() {
    super.initState();
    _loadSettingsAndDrafts();
    _descController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _descController.removeListener(_onDescriptionChanged);
    _descController.dispose();
    super.dispose();
  }

  void _loadSettingsAndDrafts() {
    setState(() {
      _descController.text = LocalStorage.getString(
        'draft_description',
        defaultValue: '',
      );
      _hideLikes = LocalStorage.getBool('hide_likes', defaultValue: false);
      _hideViews = LocalStorage.getBool('hide_views', defaultValue: false);
      _hideSettings = LocalStorage.getBool(
        'hide_settings',
        defaultValue: false,
      );
      _allowComments = LocalStorage.getBool(
        'allow_comments',
        defaultValue: true,
      );
      _postSharing = LocalStorage.getBool('post_sharing', defaultValue: true);
      _allowLikeViewFrom = LocalStorage.getString(
        'allow_like_view_from',
        defaultValue: 'Everyone',
      );
      final savedPath = LocalStorage.getString(
        'draft_image_path',
        defaultValue: '',
      );
      _pickedImagePath = savedPath.isNotEmpty ? savedPath : null;
    });
  }

  void _onDescriptionChanged() {
    LocalStorage.setString('draft_description', _descController.text);
  }

  void _saveToggle(String key, bool value) {
    LocalStorage.setBool(key, value);
  }

  void _savePrivacy(String value) {
    LocalStorage.setString('allow_like_view_from', value);
  }

  void _addTagToDescription(String tag) {
    final currentText = _descController.text;
    if (currentText.length + tag.length + 1 <= 250) {
      setState(() {
        if (currentText.isEmpty) {
          _descController.text = tag;
        } else if (currentText.endsWith(' ')) {
          _descController.text = '$currentText$tag ';
        } else {
          _descController.text = '$currentText $tag ';
        }
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a post description.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Simulate upload delay with micro-animation spinner
    await Future.delayed(const Duration(milliseconds: 1500));

    final imagePath = _pickedImagePath ?? 'assets/images/hiker.jpg';
    final newPost = PostModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: 'me_adventurer',
      profileImageUrl: imagePath,
      location: 'Scenic Peak',
      caption: _descController.text,
      imageUrl: imagePath,
      likes: 0,
      comments: 0,
      isLiked: false,
      timestamp: 'Just now',
      hideLikes: _hideLikes,
      hideViews: _hideViews,
      allowComments: _allowComments,
      postSharing: _postSharing,
      allowLikeViewFrom: _allowLikeViewFrom,
    );

    // Save post to LocalStorage
    final postsJsonList = LocalStorage.getStringList('saved_user_posts');
    postsJsonList.insert(
      0,
      newPost.toJson(),
    ); // Prepends to show at the top of feed
    await LocalStorage.setStringList('saved_user_posts', postsJsonList);

    // Clear draft description, draft image & selected gallery image indices on upload success
    await LocalStorage.setString('draft_description', '');
    await LocalStorage.setString('draft_image_path', '');
    await LocalStorage.setStringList('selected_gallery_indices', []);

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate back to Screen 1 with upload success signal
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmagzAppBar(onBackPressed: () => Navigator.pop(context)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxContentWidth = constraints.maxWidth > 700
              ? 600
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxContentWidth,
              child: _isUploading
                  ? _buildUploadingScreen()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Section: Image Preview & Edit button
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: _buildPreviewImage(),
                                    ),
                                    // Gradient shadow overlay
                                    Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.7),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    // Edit post button
                                    Positioned(
                                      bottom: 12,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.fameoPurple,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        icon: Icon(Icons.edit, size: 16),
                                        label: Text(
                                          'Edit post',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Description Input Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Description',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    ValueListenableBuilder<TextEditingValue>(
                                      valueListenable: _descController,
                                      builder: (context, value, child) {
                                        final len = value.text.length;
                                        return Text(
                                          '$len / 250',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: len > 240
                                                ? AppColors.error
                                                : AppColors.textMuted,
                                            fontWeight: len > 240
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                TextField(
                                  controller: _descController,
                                  maxLines: 4,
                                  maxLength: 250,
                                  decoration: InputDecoration(
                                    hintText:
                                        'What is on your mind? Add captions and tags...',
                                    hintStyle: GoogleFonts.inter(
                                      color: AppColors.textMuted.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    counterText:
                                        '', // Hide default counter text since we made a custom one
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.fameoPurple,
                                        width: 1.5,
                                      ),
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  style: GoogleFonts.inter(fontSize: 14),
                                ),
                                SizedBox(height: 12),

                                // Suggestion Tag Chips
                                SizedBox(
                                  height: 38,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _suggestedTags.length,
                                    itemBuilder: (context, index) {
                                      final tag = _suggestedTags[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: ActionChip(
                                          label: Text(tag),
                                          labelStyle: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.fameoPurple,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          backgroundColor: AppColors.fameoPurple
                                              .withValues(alpha: 0.08),
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          onPressed: () =>
                                              _addTagToDescription(tag),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),
                          Divider(color: AppColors.borderLight),

                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.textMuted,
                                ),
                                hintText: 'Search settings or profiles...',
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.textMuted.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                              style: GoogleFonts.inter(fontSize: 13),
                              onChanged: (value) {
                                // Search mock trigger
                              },
                            ),
                          ),

                          // Settings List
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              'Settings',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),

                          _buildSettingToggle(
                            icon: Icons.favorite_border,
                            title: 'Hide Likes',
                            value: _hideLikes,
                            onChanged: (val) {
                              setState(() => _hideLikes = val);
                              _saveToggle('hide_likes', val);
                            },
                          ),

                          _buildSettingToggle(
                            icon: Icons.remove_red_eye_outlined,
                            title: 'Hide Views',
                            value: _hideViews,
                            onChanged: (val) {
                              setState(() => _hideViews = val);
                              _saveToggle('hide_views', val);
                            },
                          ),

                          _buildSettingToggle(
                            icon: Icons.settings_outlined,
                            title: 'Hide Settings options',
                            value: _hideSettings,
                            onChanged: (val) {
                              setState(() => _hideSettings = val);
                              _saveToggle('hide_settings', val);
                            },
                          ),

                          _buildSettingToggle(
                            icon: Icons.comment_bank_outlined,
                            title: 'Allow Comments',
                            value: _allowComments,
                            onChanged: (val) {
                              setState(() => _allowComments = val);
                              _saveToggle('allow_comments', val);
                            },
                          ),

                          _buildSettingToggle(
                            icon: Icons.share_outlined,
                            title: 'Post Sharing options',
                            value: _postSharing,
                            onChanged: (val) {
                              setState(() => _postSharing = val);
                              _saveToggle('post_sharing', val);
                            },
                          ),

                          SizedBox(height: 16),
                          Divider(color: AppColors.borderLight),

                          // "Allow Like and View from" Switch/Selection list
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              'Allow Like and View from',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),

                          _buildPrivacyRadioOption('Everyone'),
                          _buildPrivacyRadioOption('Followers'),
                          _buildPrivacyRadioOption('Specific Profiles'),

                          SizedBox(height: 24),

                          // Bottom Big Purple Upload Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: HoverUploadButton(onPressed: _uploadPost),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return HoverSettingTile(
      icon: icon,
      title: title,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildPrivacyRadioOption(String value) {
    return HoverPrivacyTile(
      value: value,
      groupValue: _allowLikeViewFrom,
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _allowLikeViewFrom = val;
          });
          _savePrivacy(val);
        }
      },
    );
  }

  Widget _buildUploadingScreen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.fameoPurple),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Uploading to fameo - X...',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Syncing your settings and media...',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HoverSettingTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const HoverSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  State<HoverSettingTile> createState() => _HoverSettingTileState();
}

class _HoverSettingTileState extends State<HoverSettingTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.fameoPurple.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? AppColors.fameoPurple.withValues(alpha: 0.3)
                : AppColors.borderLight,
          ),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: AppColors.fameoPurple),
          title: Text(
            widget.title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch.adaptive(
                value: widget.value,
                onChanged: widget.onChanged,
                // ignore: deprecated_member_use
                activeColor: AppColors.fameoPurple,
              ),
              SizedBox(width: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                  left: _isHovered ? 4.0 : 0.0,
                  right: _isHovered ? 0.0 : 4.0,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverPrivacyTile extends StatefulWidget {
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const HoverPrivacyTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  State<HoverPrivacyTile> createState() => _HoverPrivacyTileState();
}

class _HoverPrivacyTileState extends State<HoverPrivacyTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.groupValue == widget.value;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.fameoPurple.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.fameoPurple
                : (_isHovered
                      ? AppColors.fameoPurple.withValues(alpha: 0.3)
                      : AppColors.borderLight),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: widget.value,
                // ignore: deprecated_member_use
                groupValue: widget.groupValue,
                activeColor: AppColors.fameoPurple,
                title: Text(
                  widget.value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: AppColors.textDark,
                  ),
                ),
                // ignore: deprecated_member_use
                onChanged: widget.onChanged,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                left: _isHovered ? 4.0 : 0.0,
                right: _isHovered ? 16.0 : 20.0,
              ),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HoverUploadButton extends StatefulWidget {
  final VoidCallback onPressed;
  const HoverUploadButton({super.key, required this.onPressed});

  @override
  State<HoverUploadButton> createState() => _HoverUploadButtonState();
}

class _HoverUploadButtonState extends State<HoverUploadButton> {
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.fameoPurple.withValues(
                alpha: _isHovered ? 0.4 : 0.2,
              ),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovered
                ? const Color(0xFF4A148C)
                : AppColors.fameoPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: _isHovered ? 8 : 4,
            minimumSize: const Size(double.infinity, 54),
            shadowColor: Colors.transparent,
          ),
          onPressed: widget.onPressed,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: GoogleFonts.outfit(
              fontSize: _isHovered ? 19.5 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: _isHovered ? 1.5 : 0.5,
            ),
            child: const Text('Upload Post'),
          ),
        ),
      ),
    );
  }
}
