import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'video_call_screen.dart';

class DirectMessageScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;

  const DirectMessageScreen({super.key, required this.chatData});

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  int _botReplyCount = 0;

  @override
  void initState() {
    super.initState();
    // Load initial conversation history based on the user
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    final name = widget.chatData['name'] as String;
    final initialMessage = widget.chatData['msg'] as String;
    final time = widget.chatData['time'] as String;

    _messages.addAll([
      {
        'isMe': false,
        'text': 'Hey there! It\'s $name, how have you been?',
        'time': '3 hours ago',
      },
      {
        'isMe': true,
        'text': 'Doing great! Just getting ready for the weekend.',
        'time': '2 hours ago',
      },
      {'isMe': false, 'text': initialMessage, 'time': time},
    ]);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isMe': true, 'text': text, 'time': 'Just now'});
    });

    _messageController.clear();
    _scrollToBottom();

    // Trigger mock automated reply
    _triggerBotReply(text);
  }

  void _triggerBotReply(String userMessage) {
    setState(() {
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate real-time typing latency (1.5 seconds)
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final name = widget.chatData['name'] as String;
      String reply = _getBotResponse(name, _botReplyCount);
      _botReplyCount++;

      setState(() {
        _isTyping = false;
        _messages.add({'isMe': false, 'text': reply, 'time': 'Just now'});
      });
      _scrollToBottom();
    });
  }

  String _getBotResponse(String name, int count) {
    if (name.startsWith('john_d')) {
      final replies = [
        'Hey! Yes, I am definitely joining the hike. Bringing my camera too! 📸',
        'We should start early, around 6:00 AM. What do you think?',
        'I\'ll pick you up at your place. Let me know the exact location! 🗺️',
        'Awesome! See you tomorrow morning then! 👍',
      ];
      return replies[count % replies.length];
    } else if (name.startsWith('sarah_m')) {
      final replies = [
        'Thank you! I absolutely loved that sunset too. It was magical! ✨',
        'I\'m planning to go to the coastline next week. Want to join?',
        'Yes! Let\'s plan it out this weekend. Have a great day!',
      ];
      return replies[count % replies.length];
    } else if (name.startsWith('alex_wander')) {
      final replies = [
        'Got it! Here are the coordinate files. Let me know if they look good.',
        'Be careful near the cliffs, it gets pretty windy there.',
        'Let me know when you reach there, I\'d love to hear your feedback.',
      ];
      return replies[count % replies.length];
    } else if (name.startsWith('bella_lens')) {
      final replies = [
        'Yes, the summit post is updated with the new high-res landscape pictures.',
        'Thanks! I used my new prime lens for that shot.',
        'Sounds good! I\'ll tag you in the next story.',
      ];
      return replies[count % replies.length];
    } else {
      final replies = [
        'Hey! That\'s awesome. Let\'s catch up later! 🙌',
        'Haha, definitely! Let\'s do that.',
        'Nice! Let me know if you need anything else.',
      ];
      return replies[count % replies.length];
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.chatData['name'] as String;
    final isOnline = widget.chatData['online'] as bool;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images/hiker.jpg'),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isOnline ? 'Active now' : 'Offline',
                    style: GoogleFonts.inter(
                      color: isOnline ? AppColors.success : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.local_phone_outlined, color: AppColors.textDark),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: AppColors.textDark),
            onPressed: () async {
              final duration = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VideoCallScreen(chatData: widget.chatData),
                ),
              );
              if (duration != null && duration.isNotEmpty) {
                setState(() {
                  _messages.add({
                    'isMe': true,
                    'text': 'Video call ended ($duration)',
                    'time': 'Just now',
                    'isSystem': true,
                  });
                });
                _scrollToBottom();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: AppColors.textDark),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxContentWidth = constraints.maxWidth > 700
              ? 600
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxContentWidth,
              child: Column(
                children: [
                  // Message list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
                  ),

                  // Bottom Message Input
                  _buildMessageInput(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isSystem = msg.containsKey('isSystem') && msg['isSystem'] == true;
    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, size: 16, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  msg['text'] as String,
                  style: GoogleFonts.inter(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isMe = msg['isMe'] as bool;
    final text = msg['text'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 5),
                  bottomRight: Radius.circular(isMe ? 5 : 20),
                ),
                gradient: isMe
                    ? LinearGradient(
                        colors: [AppColors.fameoPurple, AppColors.emagzBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.grey[200],
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: isMe ? Colors.white : AppColors.textDark,
                  fontSize: 14.5,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                msg['time'] as String,
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'typing',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              const _BouncingDot(delay: 0),
              const _BouncingDot(delay: 150),
              const _BouncingDot(delay: 300),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.fameoPurple,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            _SendButton(
              onPressed: _sendMessage,
              controller: _messageController,
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _SendButton extends StatefulWidget {
  final VoidCallback onPressed;
  final TextEditingController controller;

  const _SendButton({required this.onPressed, required this.controller});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textListener);
  }

  void _textListener() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _hasText ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 150),
      child: AnimatedOpacity(
        opacity: _hasText ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: IconButton(
          icon: Icon(Icons.send, color: AppColors.fameoPurple),
          onPressed: _hasText ? widget.onPressed : null,
        ),
      ),
    );
  }
}
