import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const primaryColor = Color(0xFF5B13EC);

  final List<String> _filters = [
    'All',
    'JEE',
    'NEET',
    'GATE',
    'CAT',
    'UPSC',
    'SSC',
    'Banking',
  ];

  final List<Map<String, dynamic>> _examCategories = [
    {
      'name': 'JEE Main',
      'icon': Icons.school_rounded,
      'color': Color(0xFF6366F1),
      'quizzes': 250,
    },
    {
      'name': 'NEET',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF10B981),
      'quizzes': 180,
    },
    {
      'name': 'GATE',
      'icon': Icons.engineering_rounded,
      'color': Color(0xFFF59E0B),
      'quizzes': 120,
    },
    {
      'name': 'CAT',
      'icon': Icons.business_rounded,
      'color': Color(0xFFEC4899),
      'quizzes': 95,
    },
    {
      'name': 'UPSC',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF8B5CF6),
      'quizzes': 200,
    },
    {
      'name': 'SSC',
      'icon': Icons.verified_user_rounded,
      'color': Color(0xFF3B82F6),
      'quizzes': 150,
    },
  ];

  final List<Map<String, dynamic>> _popularTopics = [
    {'name': 'Physics', 'icon': Icons.bolt_rounded, 'color': Color(0xFFF59E0B)},
    {
      'name': 'Chemistry',
      'icon': Icons.science_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'name': 'Mathematics',
      'icon': Icons.functions_rounded,
      'color': Color(0xFF6366F1),
    },
    {
      'name': 'Biology',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFFEC4899),
    },
    {
      'name': 'English',
      'icon': Icons.translate_rounded,
      'color': Color(0xFF3B82F6),
    },
    {
      'name': 'Reasoning',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSub = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover quizzes for your exam preparation',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.plusJakartaSans(
                      color: textMain,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search topics, exams, subjects...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: textSub.withOpacity(0.6),
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(Icons.search_rounded, color: textSub),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedFilter = filter);
                        },
                        backgroundColor: surfaceColor,
                        selectedColor: primaryColor.withOpacity(0.15),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primaryColor : textSub,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                    ? Colors.white12
                                    : const Color(0xFFE2E8F0)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Exam Categories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exam Categories',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Exam Category Cards Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final exam = _examCategories[index];
                  return _buildExamCard(
                    exam,
                    isDark,
                    surfaceColor,
                    textMain,
                    textSub,
                    index,
                  );
                }, childCount: _examCategories.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.4,
                ),
              ),
            ),

            // Popular Topics Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Popular Topics',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  itemCount: _popularTopics.length,
                  itemBuilder: (context, index) {
                    final topic = _popularTopics[index];
                    return _buildTopicChip(
                      topic,
                      isDark,
                      surfaceColor,
                      textMain,
                      index,
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(
    Map<String, dynamic> exam,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
    int index,
  ) {
    final color = exam['color'] as Color;

    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to exam quizzes
          },
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    exam['icon'] as IconData,
                    size: 60,
                    color: color.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          exam['icon'] as IconData,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        exam['name'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      Text(
                        '${exam['quizzes']}+ quizzes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 80).ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildTopicChip(
    Map<String, dynamic> topic,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    int index,
  ) {
    final color = topic['color'] as Color;

    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(topic['icon'] as IconData, color: Colors.white, size: 24),
                const SizedBox(height: 6),
                Text(
                  topic['name'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 60).ms)
        .fade(duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }
}
