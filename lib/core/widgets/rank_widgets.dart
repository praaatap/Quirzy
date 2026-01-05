import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quirzy/core/services/rank_service.dart';

/// Premium Rank Badge Widget - Shows current rank with fancy visuals
class RankBadgeWidget extends StatefulWidget {
  final RankTier rank;
  final double size;
  final bool showGlow;
  final bool showPulse;
  final bool showLabel;
  final VoidCallback? onTap;

  const RankBadgeWidget({
    super.key,
    required this.rank,
    this.size = 60,
    this.showGlow = true,
    this.showPulse = true,
    this.showLabel = true,
    this.onTap,
  });

  @override
  State<RankBadgeWidget> createState() => _RankBadgeWidgetState();
}

class _RankBadgeWidgetState extends State<RankBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final glowIntensity = widget.showPulse
                  ? 0.3 + (_pulseController.value * 0.3)
                  : 0.4;

              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(widget.rank.color),
                      Color(widget.rank.color).withOpacity(0.7),
                      Color(widget.rank.glowColor),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: widget.showGlow
                      ? [
                          BoxShadow(
                            color: Color(
                              widget.rank.glowColor,
                            ).withOpacity(glowIntensity),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    widget.rank.iconPath,
                    style: TextStyle(fontSize: widget.size * 0.45),
                  ),
                ),
              );
            },
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 8),
            Text(
              widget.rank.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(widget.rank.color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rank Progress Card Widget - Shows full rank info with progress bar
class RankProgressCard extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onTap;

  const RankProgressCard({super.key, required this.isDark, this.onTap});

  @override
  State<RankProgressCard> createState() => _RankProgressCardState();
}

class _RankProgressCardState extends State<RankProgressCard>
    with SingleTickerProviderStateMixin {
  final RankService _rankService = RankService();
  late AnimationController _progressController;

  RankTier? _currentRank;
  RankTier? _nextRank;
  int _totalXP = 0;
  double _progress = 0;
  int _xpToNextRank = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadRankData();
  }

  Future<void> _loadRankData() async {
    await _rankService.initialize();
    if (!mounted) return;

    setState(() {
      _currentRank = _rankService.getCurrentRank();
      _nextRank = _rankService.getNextRank();
      _totalXP = _rankService.getTotalXP();
      _progress = _rankService.getProgressToNextRank();
      _xpToNextRank = _rankService.getXPToNextRank();
      _isLoading = false;
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentRank == null) {
      return _buildLoadingState();
    }

    final currentRank = _currentRank!;
    final surfaceColor = widget.isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = widget.isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = widget.isDark ? Colors.white70 : const Color(0xFF64748B);

    return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: widget.isDark
                  ? Border.all(color: const Color(0xFF2D2540))
                  : null,
              boxShadow: widget.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              children: [
                // Top row: Badge + Info
                Row(
                  children: [
                    // Rank Badge
                    RankBadgeWidget(
                      rank: currentRank,
                      size: 70,
                      showLabel: false,
                    ),
                    const SizedBox(width: 16),

                    // Rank info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                currentRank.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (currentRank.isLegendary)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.amber, Colors.orange],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'MAX',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_totalXP XP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textSub,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow to next rank (if exists)
                    if (_nextRank != null)
                      Column(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(_nextRank!.color).withOpacity(0.1),
                              border: Border.all(
                                color: Color(_nextRank!.color).withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _nextRank!.iconPath,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Next',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: textSub,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress bar
                if (_nextRank != null) ...[
                  Row(
                    children: [
                      Text(
                        currentRank.tier,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSub,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _nextRank!.tier,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      final animatedProgress =
                          _progress * _progressController.value;

                      return Stack(
                        children: [
                          // Background
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          // Progress
                          FractionallySizedBox(
                            widthFactor: animatedProgress,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(currentRank.color),
                                    Color(currentRank.glowColor),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(
                                      currentRank.glowColor,
                                    ).withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_xpToNextRank XP to ${_nextRank!.name}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSub,
                    ),
                  ),
                ] else ...[
                  // Max rank reached
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.2),
                          Colors.orange.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'You\'ve reached the highest rank!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fade(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildLoadingState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF5B13EC),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// Mini Rank Badge for app bars and headers
class MiniRankBadge extends StatelessWidget {
  final RankTier rank;
  final bool showXP;
  final int? currentXP;

  const MiniRankBadge({
    super.key,
    required this.rank,
    this.showXP = false,
    this.currentXP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(rank.color).withOpacity(0.2),
            Color(rank.glowColor).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(rank.color).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rank.iconPath, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rank.tier,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(rank.color),
                ),
              ),
              if (showXP && currentXP != null)
                Text(
                  '$currentXP XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(rank.color).withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// All Ranks Grid - Shows all available ranks
class AllRanksGrid extends StatelessWidget {
  final RankTier currentRank;
  final bool isDark;

  const AllRanksGrid({
    super.key,
    required this.currentRank,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? Colors.white70 : const Color(0xFF64748B);

    // Group ranks by tier
    final Map<String, List<RankTier>> tierGroups = {};
    for (final rank in RankService.allRanks) {
      tierGroups.putIfAbsent(rank.tier, () => []);
      tierGroups[rank.tier]!.add(rank);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tierGroups.entries.map((entry) {
        final tierName = entry.key;
        final ranks = entry.value;
        final isCurrentTier = ranks.any((r) => r.id == currentRank.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isCurrentTier
                ? Border.all(
                    color: Color(currentRank.color).withOpacity(0.5),
                    width: 2,
                  )
                : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ranks.first.iconPath,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tierName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCurrentTier
                          ? Color(currentRank.color)
                          : textMain,
                    ),
                  ),
                  if (isCurrentTier) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(currentRank.color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'CURRENT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(currentRank.color),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ranks.map((rank) {
                  final isUnlocked = rank.rankIndex <= currentRank.rankIndex;
                  final isCurrent = rank.id == currentRank.id;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Color(rank.color).withOpacity(0.2)
                          : (isUnlocked
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(20),
                      border: isCurrent
                          ? Border.all(color: Color(rank.color))
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUnlocked)
                          Icon(Icons.lock, size: 12, color: textSub)
                        else if (isCurrent)
                          Icon(Icons.star, size: 12, color: Color(rank.color))
                        else
                          Icon(Icons.check, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          rank.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isUnlocked
                                ? (isCurrent ? Color(rank.color) : textMain)
                                : textSub,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
