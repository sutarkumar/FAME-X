import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _trendingTags = [
    '#Adventure',
    '#Hiking',
    '#Wanderlust',
    '#SummitPoint',
    '#NatureWalks',
    '#TravelLog',
  ];
  String _selectedTag = '#Adventure';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxContentWidth = constraints.maxWidth > 700
                ? 600
                : constraints.maxWidth;
            final int gridCrossAxisCount = constraints.maxWidth > 500 ? 3 : 2;

            return Center(
              child: SizedBox(
                width: maxContentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Header Input Field
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textDark.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search posts, tags, or explorers...',
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.fameoPurple,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: AppColors.textDark,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),

                    // Trending tag chips horizontal list
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: _trendingTags.length,
                          itemBuilder: (context, index) {
                            final tag = _trendingTags[index];
                            final isSelected = _selectedTag == tag;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ChoiceChip(
                                label: Text(tag),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedTag = tag;
                                    });
                                  }
                                },
                                selectedColor: AppColors.fameoPurple.withValues(
                                  alpha: 0.15,
                                ),
                                backgroundColor: AppColors.cardBackground,
                                labelStyle: GoogleFonts.inter(
                                  color: isSelected
                                      ? AppColors.fameoPurple
                                      : AppColors.textMuted,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.fameoPurple
                                      : AppColors.borderLight,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Explore Highlights',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    // Grid of matching pictures
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 12,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridCrossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: AppColors.cardBackground,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textDark.withValues(
                                      alpha: 0.02,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.asset(
                                        'assets/images/hiker.jpg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        cacheWidth: 300,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Summit View #${index + 1}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              size: 12,
                                              color: AppColors.error,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${(index + 1) * 23} likes',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
