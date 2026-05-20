import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/storage/local_storage.dart';
import '../core/theme/app_theme.dart';
import '../widgets/emagz_app_bar.dart';
import 'create_post_details_screen.dart';

class UpdatePostScreen extends StatefulWidget {
  const UpdatePostScreen({super.key});

  @override
  State<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final List<String> _tabs = ['Text', 'v-Magz', 'Gallery', 'Video', 'Audio'];
  String _activeTab = 'Gallery';

  // Track selected image indices. Indices range from 0 to 7 (8 grid images total).
  List<int> _selectedIndices = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedIndices();
  }

  void _loadSelectedIndices() {
    // Load selected indices from SharedPreferences. If empty, default to pre-selecting first two (0, 1).
    final list = LocalStorage.getStringList('selected_gallery_indices');
    if (list.isEmpty) {
      setState(() {
        _selectedIndices = [0, 1];
      });
      _saveSelectedIndices([0, 1]);
    } else {
      setState(() {
        _selectedIndices = list.map((e) => int.parse(e)).toList();
      });
    }
  }

  void _saveSelectedIndices(List<int> indices) {
    LocalStorage.setStringList(
      'selected_gallery_indices',
      indices.map((e) => e.toString()).toList(),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
    // Immediately persist to local storage
    _saveSelectedIndices(_selectedIndices);
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
          final int gridCrossAxisCount = constraints.maxWidth > 500 ? 4 : 3;

          return Center(
            child: SizedBox(
              width: maxContentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Update Post',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  // Segmented Tabs Control
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final isSelected = _activeTab == tab;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(tab),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _activeTab = tab;
                                });
                              }
                            },
                            selectedColor: AppColors.emagzBlue,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.emagzBlue
                                  : AppColors.borderLight,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 12),

                  // Grid of gallery photos
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        itemCount: 8, // 8 gallery images
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCrossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndices.contains(index);
                          return GalleryGridTile(
                            index: index,
                            isSelected: isSelected,
                            onTap: () => _toggleSelection(index),
                          );
                        },
                      ),
                    ),
                  ),

                  // Bottom Action Buttons Panel
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: AppColors.borderLight, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppColors.borderDark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Next button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emagzBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _selectedIndices.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CreatePostDetailsScreen(),
                                      ),
                                    ).then((uploaded) {
                                      if (!context.mounted) return;
                                      if (uploaded == true) {
                                        // If a post was uploaded, navigate all the way back to feed
                                        Navigator.pop(context, true);
                                      }
                                    });
                                  },
                            child: Text(
                              'Next (${_selectedIndices.length})',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
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
      ),
    );
  }
}

class GalleryGridTile extends StatefulWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  const GalleryGridTile({
    super.key,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<GalleryGridTile> createState() => _GalleryGridTileState();
}

class _GalleryGridTileState extends State<GalleryGridTile> {
  bool _isHovered = false;

  Color _getHoverColor(int index) {
    final List<Color> colors = [
      AppColors.fameoPurple,
      AppColors.emagzBlue,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.indigo,
      Colors.redAccent,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.emagzBlue
                  : Colors.transparent,
              width: 3.5,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: AppColors.emagzBlue.withValues(alpha: 0.15),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Hiker Image with Zoom effect inside bounds
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  transform: Matrix4.diagonal3Values(
                    _isHovered ? 1.05 : 1.0,
                    _isHovered ? 1.05 : 1.0,
                    1.0,
                  ),
                  transformAlignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.asset(
                    'assets/images/hiker.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              // Dynamic color overlay with fade-in animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: widget.isSelected
                      ? AppColors.emagzBlue.withValues(alpha: 0.1)
                      : (_isHovered
                            ? _getHoverColor(
                                widget.index,
                              ).withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.05)),
                ),
              ),

              // Selection Badge
              if (widget.isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.emagzBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),

              // Grid item number
              Positioned(
                bottom: 6,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Photo #${widget.index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
