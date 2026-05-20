import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/storage/local_storage.dart';
import '../core/theme/app_theme.dart';
import '../models/post_model.dart';
import '../widgets/fameo_app_bar.dart';
import '../widgets/post_card.dart';
import 'story_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<PostModel> _posts = [];

  final List<Map<String, String>> _stories = [
    {'name': 'My Story', 'img': 'assets/images/hiker.jpg'},
    {'name': 'john_d', 'img': 'assets/images/eyes.jpg'},
    {'name': 'sarah_m', 'img': 'assets/images/leaves.jpg'},
    {'name': 'alex_wander', 'img': 'assets/images/kitten.jpg'},
    {'name': 'bella_lens', 'img': 'assets/images/coast.jpg'},
    {'name': 'nature_hub', 'img': 'assets/images/hiker.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void loadPosts() {
    _loadPosts();
  }

  void _loadPosts() {
    final List<PostModel> loadedPosts = [];

    // Load custom posts from LocalStorage
    final postsJsonList = LocalStorage.getStringList('saved_user_posts');
    if (postsJsonList.isNotEmpty) {
      for (final postJson in postsJsonList) {
        try {
          loadedPosts.add(PostModel.fromJson(postJson));
        } catch (e) {
          // ignore corrupted data
        }
      }
    }

    // Default mock data containing all uploaded images
    final defaultMockPosts = [
      PostModel(
        id: 'mock_1',
        username: 'travel_lens',
        profileImageUrl: 'assets/images/hiker.jpg',
        location: 'Mountain Range',
        caption:
            'Standing at the edge of the world. Fresh air, misty valley peaks, and total tranquility.',
        imageUrl: 'assets/images/hiker.jpg',
        likes: 142,
        comments: 29,
        isLiked: false,
        timestamp: '2 hours ago',
      ),
      PostModel(
        id: 'mock_2',
        username: 'coastline_seeker',
        profileImageUrl: 'assets/images/coast.jpg',
        location: 'Northern Cliffs',
        caption:
            'Beautiful shores, wild rocks, and the eternal ocean breeze. Waking up to this is a dream.',
        imageUrl: 'assets/images/coast.jpg',
        likes: 412,
        comments: 52,
        isLiked: true,
        timestamp: '5 hours ago',
      ),
      PostModel(
        id: 'mock_3',
        username: 'kitty_explorer',
        profileImageUrl: 'assets/images/kitten.jpg',
        location: 'Sunny Garden',
        caption:
            'Focused on the next big adventure (or maybe just a bird in the distance). 🐾✨',
        imageUrl: 'assets/images/kitten.jpg',
        likes: 624,
        comments: 98,
        isLiked: false,
        timestamp: '1 day ago',
      ),
      PostModel(
        id: 'mock_4',
        username: 'nature_journal',
        profileImageUrl: 'assets/images/leaves.jpg',
        location: 'Rainforest Trail',
        caption:
            'Morning dew reflecting the light on these fresh rain-soaked leaves. Pure nature.',
        imageUrl: 'assets/images/leaves.jpg',
        likes: 312,
        comments: 21,
        isLiked: true,
        timestamp: '2 days ago',
      ),
    ];

    // Combine user posts at the top, followed by mock data
    setState(() {
      _posts = [...loadedPosts, ...defaultMockPosts];
    });
  }

  void _updatePost(PostModel updatedPost) {
    // Find and update post in our state list
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      setState(() {
        _posts[index] = updatedPost;
      });

      // Save to local storage if it was a user post
      final postsJsonList = LocalStorage.getStringList('saved_user_posts');
      final userPostIndex = postsJsonList.indexWhere((pStr) {
        try {
          final pMap = json.decode(pStr);
          return pMap['id'] == updatedPost.id;
        } catch (e) {
          return false;
        }
      });

      if (userPostIndex != -1) {
        postsJsonList[userPostIndex] = updatedPost.toJson();
        LocalStorage.setStringList('saved_user_posts', postsJsonList);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FameoAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive design layout constrains list view width on desktop
          final double maxContentWidth = constraints.maxWidth > 700
              ? 600
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxContentWidth,
              child: RefreshIndicator(
                color: AppColors.fameoPurple,
                onRefresh: () async {
                  _loadPosts();
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Stories section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          top: 12.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          'Updates',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),

                    // Horizontal Stories
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 105,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: _stories.length,
                          itemBuilder: (context, index) {
                            final story = _stories[index];
                            final isSelf = index == 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoryViewerScreen(
                                        stories: _stories,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: HoverStoryWidget(
                                  story: story,
                                  isSelf: isSelf,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Divider and Feed Header
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 1, color: AppColors.borderLight),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 16.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              'Feed',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Feed Posts Sliver
                    if (_posts.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text(
                              'No feed posts available.',
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            post: _posts[index],
                            onPostChanged: _updatePost,
                          );
                        },
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
}

class HoverStoryWidget extends StatefulWidget {
  final Map<String, String> story;
  final bool isSelf;
  const HoverStoryWidget({
    super.key,
    required this.story,
    required this.isSelf,
  });

  @override
  State<HoverStoryWidget> createState() => _HoverStoryWidgetState();
}

class _HoverStoryWidgetState extends State<HoverStoryWidget> {
  bool _isHovered = false;

  Color _getStoryHoverColor() {
    final name = widget.story['name'] ?? '';
    final code = name.hashCode;
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

  LinearGradient _getStoryHoverGradient() {
    final name = widget.story['name'] ?? '';
    final code = name.hashCode;

    final List<List<Color>> gradientPairs = [
      [AppColors.emagzBlue, AppColors.fameoPurple],
      [Colors.teal, Colors.greenAccent],
      [Colors.orange, Colors.pink],
      [Colors.redAccent, Colors.purpleAccent],
      [Colors.cyan, Colors.indigo],
      [Colors.pinkAccent, Colors.amberAccent],
      [Colors.indigoAccent, Colors.tealAccent],
    ];

    final pair = gradientPairs[code.abs() % gradientPairs.length];
    return LinearGradient(
      colors: pair,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.08 : 1.0,
          _isHovered ? 1.08 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        child: Column(
          children: [
            Stack(
              children: [
                // Gradient Ring Border
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isSelf
                        ? null
                        : (_isHovered
                              ? _getStoryHoverGradient()
                              : LinearGradient(
                                  colors: [
                                    AppColors.fameoPurpleGradientStart,
                                    AppColors.fameoPurpleGradientEnd,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )),
                    color: widget.isSelf
                        ? (_isHovered
                              ? AppColors.fameoPurple
                              : AppColors.borderLight)
                        : null,
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            widget.story['img']!,
                            fit: BoxFit.cover,
                            cacheWidth: 120,
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color: _isHovered
                                ? _getStoryHoverColor().withValues(alpha: 0.15)
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.isSelf)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.fameoPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.add, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                widget.isSelf ? 'My Story' : widget.story['name']!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
                  color: _isHovered
                      ? AppColors.fameoPurple
                      : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
