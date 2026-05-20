import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Map<String, String>> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;
  bool _isPaused = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _startStory();
  }

  void _startStory() {
    _progressController.reset();
    _progressController.forward();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startStory();
    } else {
      // Out of stories, exit viewer
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _startStory();
    } else {
      // First story, restart current slide
      _startStory();
    }
  }

  void _pauseStory() {
    if (!_isPaused) {
      _progressController.stop();
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      _progressController.forward();
      setState(() {
        _isPaused = false;
      });
    }
  }

  void _sendStoryReply(String replyText) {
    if (replyText.isEmpty) return;

    final storyUser = widget.stories[_currentIndex]['name'] ?? 'unknown';

    // Simulate sending DM to the user in background
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reply sent to $storyUser!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );

    _replyController.clear();
    _resumeStory();
  }

  void _sendEmojiReaction(String emoji) {
    final storyUser = widget.stories[_currentIndex]['name'] ?? 'unknown';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent $emoji reaction to $storyUser!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );

    _resumeStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final name = story['name'] ?? '';
    final imagePath = story['img'] ?? 'assets/images/hiker.jpg';

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxContentWidth = constraints.maxWidth > 700
              ? 600
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxContentWidth,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Full Screen Story Image with Gestures
                  Positioned.fill(
                    child: GestureDetector(
                      onLongPressDown: (_) => _pauseStory(),
                      onLongPressUp: () => _resumeStory(),
                      onLongPressEnd: (_) => _resumeStory(),
                      onTapUp: (details) {
                        final width = MediaQuery.of(context).size.width;
                        if (details.globalPosition.dx < width / 3) {
                          _previousStory();
                        } else {
                          _nextStory();
                        }
                      },
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  ),

                  // Gradient overlays for visibility
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 180,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // 2. Top Segmented Progress Indicators
                  Positioned(
                    top: 48,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(widget.stories.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: HeightIndicator(
                                index: index,
                                currentIndex: _currentIndex,
                                animation: _progressController,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // 3. User details profile header
                  Positioned(
                    top: 64,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(imagePath),
                        ),
                        SizedBox(width: 12),
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '3h ago',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // 4. Bottom Reply Interface
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Emoji Reactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['❤️', '😂', '😮', '😢', '👏', '🔥'].map((
                            emoji,
                          ) {
                            return GestureDetector(
                              onTap: () {
                                _pauseStory();
                                _sendEmojiReaction(emoji);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  emoji,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),

                        // Text Field Reply input
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: TextField(
                                  controller: _replyController,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Send message...',
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  onTap: () => _pauseStory(),
                                  onSubmitted: (text) => _sendStoryReply(text),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.white),
                              onPressed: () =>
                                  _sendStoryReply(_replyController.text.trim()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HeightIndicator extends StatelessWidget {
  final int index;
  final int currentIndex;
  final Animation<double> animation;

  const HeightIndicator({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    if (index < currentIndex) {
      return Container(height: 3, color: Colors.white);
    } else if (index > currentIndex) {
      return Container(height: 3, color: Colors.white24);
    } else {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: animation.value,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 3,
          );
        },
      );
    }
  }
}
