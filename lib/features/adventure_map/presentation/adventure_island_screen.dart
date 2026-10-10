import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/chapter_model.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../../chapter_detail/presentation/chapter_detail_screen.dart';

/// Adventure Island / Learning Path Map Screen
/// Visual winding path where the student's avatar journeys through themed biomes,
/// unlocking chapter checkpoints and treasure chests!
class AdventureIslandScreen extends ConsumerStatefulWidget {
  final List<Chapter> chapters;
  final String subjectId;
  final String subjectName;
  final String emoji;
  final Color primaryColor;

  const AdventureIslandScreen({
    super.key,
    required this.chapters,
    required this.subjectId,
    required this.subjectName,
    required this.emoji,
    required this.primaryColor,
  });

  static Future<void> push(
    BuildContext context, {
    required List<Chapter> chapters,
    required String subjectId,
    required String subjectName,
    required String emoji,
    required Color primaryColor,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdventureIslandScreen(
          chapters: chapters,
          subjectId: subjectId,
          subjectName: subjectName,
          emoji: emoji,
          primaryColor: primaryColor,
        ),
      ),
    );
  }

  @override
  ConsumerState<AdventureIslandScreen> createState() => _AdventureIslandScreenState();
}

class _AdventureIslandScreenState extends ConsumerState<AdventureIslandScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _claimTreasureChest(String chestId, int bonusStars, int bonusPoints, bool isHindi) async {
    AudioService.instance.playSfx(CurioSfx.starAward);
    await LocalStorageService.instance.claimChest(chestId);
    await LocalStorageService.instance.addBonusStars(bonusStars);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 8),
            Text(
              isHindi ? 'खजाना खुला!' : 'Treasure Unlocked!',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF78350F)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 6),
                      Text(
                        '+$bonusStars ${isHindi ? "सितारे" : "Stars"}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF92400E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        '+$bonusPoints ${isHindi ? "पॉइंट्स" : "Points"}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E40AF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isHindi ? 'शानदार प्रगति! द्वीप पर आगे बढ़ते रहें!' : 'Awesome progress! Keep advancing on the Island map!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7B25),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {});
            },
            child: Text(isHindi ? 'धन्यवाद 🌟' : 'Awesome! 🌟'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final isHindi = strings.isHindi;
    final activeProfile = ref.watch(studentProfileProvider);

    // Compute completion metrics
    int completedCount = 0;
    for (int i = 0; i < widget.chapters.length; i++) {
      if (LocalStorageService.instance.isChapterCompleted(widget.chapters[i].chapterId)) {
        completedCount++;
      }
    }
    final progressPercent = widget.chapters.isNotEmpty ? (completedCount / widget.chapters.length) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Light Nature/Island background
      appBar: AppBar(
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.subjectName} ${isHindi ? "द्वीप यात्रा" : "Island Map"}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Total Stars badge
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                ValueListenableBuilder<int>(
                  valueListenable: LocalStorageService.instance.totalStarsNotifier,
                  builder: (context, stars, _) => Text(
                    '$stars',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Winding Trail List
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 80, bottom: 40, left: 16, right: 16),
            itemCount: widget.chapters.length,
            itemBuilder: (context, index) {
              final chapter = widget.chapters[index];
              final isCompleted = LocalStorageService.instance.isChapterCompleted(chapter.chapterId);
              // Chapter is unlocked if it's the first chapter or previous chapter is completed
              final isUnlocked = index == 0 ||
                  LocalStorageService.instance.isChapterCompleted(widget.chapters[index - 1].chapterId);

              final isCurrent = isUnlocked && !isCompleted;

              // Alternating S-curve alignment: left, center, right, center
              final alignIndex = index % 4;
              final Alignment nodeAlignment = alignIndex == 0
                  ? const Alignment(-0.65, 0)
                  : (alignIndex == 1
                      ? Alignment.center
                      : (alignIndex == 2 ? const Alignment(0.65, 0) : Alignment.center));

              // Check if a milestone treasure chest appears after this chapter (every 4 chapters)
              final hasChestAfter = (index + 1) % 4 == 0;
              final chestId = 'chest_${widget.subjectId}_${index + 1}';
              final isChestClaimed = LocalStorageService.instance.isChestClaimed(chestId);
              // Treasure chest unlocks ONLY when this chapter (and milestone) is actually completed
              final isChestUnlocked = isCompleted;

              return Column(
                children: [
                  // Chapter Node
                  Align(
                    alignment: nodeAlignment,
                    child: _buildChapterNode(
                      chapter: chapter,
                      index: index + 1,
                      isCompleted: isCompleted,
                      isUnlocked: isUnlocked,
                      isCurrent: isCurrent,
                      avatarIcon: activeProfile.avatarIcon,
                      isHindi: isHindi,
                    ),
                  ),

                  // Connecting Stepping Stones
                  if (index < widget.chapters.length - 1)
                    _buildSteppingStones(index, isCompleted),

                  // Milestone Treasure Chest
                  if (hasChestAfter) ...[
                    const SizedBox(height: 10),
                    _buildTreasureChest(
                      chestId: chestId,
                      chapterNumber: index + 1,
                      isUnlocked: isChestUnlocked,
                      isClaimed: isChestClaimed,
                      isHindi: isHindi,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),

          // Floating Top Progress Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isHindi ? 'द्वीप प्रगति' : 'Island Completion',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                            ),
                            Text(
                              '$completedCount / ${widget.chapters.length} ${isHindi ? "अध्याय" : "Chapters"}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildChapterNode({
    required Chapter chapter,
    required int index,
    required bool isCompleted,
    required bool isUnlocked,
    required bool isCurrent,
    required String avatarIcon,
    required bool isHindi,
  }) {
    Color nodeColor = const Color(0xFFCBD5E1);
    Color borderColor = const Color(0xFF94A3B8);
    Widget innerIcon = const Icon(Icons.lock_rounded, color: Colors.white, size: 24);

    if (isCompleted) {
      nodeColor = const Color(0xFFFBBF24);
      borderColor = const Color(0xFFD97706);
      innerIcon = const Text('⭐', style: TextStyle(fontSize: 26));
    } else if (isUnlocked) {
      nodeColor = widget.primaryColor;
      borderColor = widget.primaryColor.withValues(alpha: 0.7);
      innerIcon = Text(
        '$index',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar Mascot perched on Current Chapter
        if (isCurrent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(avatarIcon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  isHindi ? 'यहाँ खेलें! 🎯' : 'PLAY HERE! 🎯',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],

        // Interactive Node Button
        GestureDetector(
          onTap: () {
            AudioService.instance.playSfx(CurioSfx.click);
            if (isUnlocked) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: chapter)),
              ).then((_) {
                if (mounted) setState(() {});
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isHindi
                        ? 'अनलॉक करने के लिए पिछला अध्याय पूरा करें! 🔒'
                        : 'Complete the previous chapter to unlock! 🔒',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Container(
            width: isCurrent ? 74 : 64,
            height: isCurrent ? 74 : 64,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: isCurrent ? 4 : 3),
              boxShadow: [
                BoxShadow(
                  color: nodeColor.withValues(alpha: 0.4),
                  blurRadius: isCurrent ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: innerIcon),
          ),
        ),
        const SizedBox(height: 6),

        // Chapter Title Pill
        Container(
          constraints: const BoxConstraints(maxWidth: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            chapter.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSteppingStones(int index, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFFBBF24) : const Color(0xFFCBD5E1),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTreasureChest({
    required String chestId,
    required int chapterNumber,
    required bool isUnlocked,
    required bool isClaimed,
    required bool isHindi,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isHindi
                    ? 'खजाना बंद है! इसे खोलने के लिए पहले अध्याय $chapterNumber पूरा करें (5 प्रश्न या टेस्ट)। 🔒'
                    : 'Treasure locked! Complete Chapter $chapterNumber first (give 5 answers or take a test) to unlock. 🔒',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (isClaimed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isHindi ? 'यह खजाना पहले ही प्राप्त कर लिया गया है! 🌟' : 'This chest has already been claimed! 🌟'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          _claimTreasureChest(chestId, 5, 50, isHindi);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isClaimed
                ? [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)]
                : (isUnlocked
                    ? [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]
                    : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)]),
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isClaimed
                ? const Color(0xFF94A3B8)
                : (isUnlocked ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1)),
            width: 1.5,
          ),
          boxShadow: [
            if (isUnlocked && !isClaimed)
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isClaimed ? '📦' : (isUnlocked ? '🎁' : '🔒'), style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              isClaimed
                  ? (isHindi ? 'खजाना प्राप्त ✅' : 'Claimed Chest ✅')
                  : (isUnlocked ? (isHindi ? 'खजाना खोलें! 🌟' : 'TAP TO OPEN! 🌟') : (isHindi ? 'बंद खजाना' : 'Locked Chest')),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: isClaimed
                    ? const Color(0xFF475569)
                    : (isUnlocked ? const Color(0xFFB45309) : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
