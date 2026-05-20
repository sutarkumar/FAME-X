import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;

  const VideoCallScreen({super.key, required this.chatData});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  String _status = 'Ringing...';
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  bool _isConnected = false;

  // Draggable PiP (Picture in Picture) Local Camera Feed Position
  double _pipX = 20.0;
  double _pipY = 80.0;

  @override
  void initState() {
    super.initState();
    _startConnectionProcess();
  }

  void _startConnectionProcess() {
    // Simulate "Ringing" state for 2.5 seconds, then connect the call
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() {
        _status = 'Connected';
        _isConnected = true;
      });
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.pop(context, _formatDuration(_secondsElapsed));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.chatData['name'] as String;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Video Feed (Simulated Remote Stream)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Display Blurred / Animated profile backdrop
                Image.asset('assets/images/hiker.jpg', fit: BoxFit.cover),
                // Semi-transparent overlay to ensure controls readability
                Container(
                  color: Colors.black.withValues(
                    alpha: _isConnected ? 0.3 : 0.65,
                  ),
                ),
                if (!_isConnected)
                  // Ringing Waveform Animation
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RingingPulse(name: name),
                        SizedBox(height: 24),
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _status,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 2. Draggable Picture-in-Picture Local Camera Stream
          if (_isConnected)
            Positioned(
              left: _pipX,
              top: _pipY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _pipX += details.delta.dx;
                    _pipY += details.delta.dy;

                    // Ensure window stays within screen bounds roughly
                    final size = MediaQuery.of(context).size;
                    if (_pipX < 10) _pipX = 10;
                    if (_pipX > size.width - 130) _pipX = size.width - 130;
                    if (_pipY < 40) _pipY = 40;
                    if (_pipY > size.height - 240) _pipY = size.height - 240;
                  });
                },
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 110,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white30, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _isCameraOn
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/hiker.jpg',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.blueAccent.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Icon(
                                  _isFrontCamera
                                      ? Icons.camera_front
                                      : Icons.camera_rear,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_off,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Camera Off',
                                  style: GoogleFonts.inter(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),

          // 3. Top Call Info Details (Only when connected)
          if (_isConnected)
            Positioned(
              top: 44,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _endCall,
                    ),
                    Column(
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatDuration(_secondsElapsed),
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 48), // Spacer to center title
                  ],
                ),
              ),
            ),

          // 4. Bottom Controls Bar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flip Camera
                _CallControlButton(
                  icon: Icons.flip_camera_ios_outlined,
                  color: Colors.white24,
                  iconColor: Colors.white,
                  onPressed: _flipCamera,
                ),
                SizedBox(width: 20),

                // Video On/Off Toggle
                _CallControlButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  color: _isCameraOn ? Colors.white24 : Colors.white,
                  iconColor: _isCameraOn ? Colors.white : Colors.black,
                  onPressed: _toggleCamera,
                ),
                SizedBox(width: 20),

                // Mute/Unmute Mic Toggle
                _CallControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.white : Colors.white24,
                  iconColor: _isMuted ? Colors.black : Colors.white,
                  onPressed: _toggleMute,
                ),
                SizedBox(width: 32),

                // End Call Red Button
                _CallControlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  iconColor: Colors.white,
                  size: 64,
                  iconSize: 28,
                  onPressed: _endCall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingingPulse extends StatefulWidget {
  final String name;

  const _RingingPulse({required this.name});

  @override
  State<_RingingPulse> createState() => _RingingPulseState();
}

class _RingingPulseState extends State<_RingingPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse animations
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double progress =
                    (_controller.value + (index / 3.0)) % 1.0;
                return Container(
                  width: 60 + (progress * 80),
                  height: 60 + (progress * 80),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.fameoPurple.withValues(
                      alpha: 0.45 * (1 - progress),
                    ),
                  ),
                );
              },
            );
          }),
          // Actual Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/hiker.jpg'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  const _CallControlButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onPressed,
    this.size = 50,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        onPressed: onPressed,
      ),
    );
  }
}
