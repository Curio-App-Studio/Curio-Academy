import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../domain/rhyme_story_model.dart';

/// Interactive Rhymes & Stories Screen for LKG, UKG and Early Learners
class RhymesStoriesScreen extends StatefulWidget {
  final int initialTab;

  const RhymesStoriesScreen({
    super.key,
    this.initialTab = 0,
  });

  static Future<void> push(BuildContext context, {int initialTab = 0}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RhymesStoriesScreen(initialTab: initialTab),
      ),
    );
  }

  @override
  State<RhymesStoriesScreen> createState() => _RhymesStoriesScreenState();
}

class _RhymesStoriesScreenState extends State<RhymesStoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Active Rhyme Player State
  int _selectedRhymeIndex = 0;
  bool _isPlayingRhyme = false;

  // Active Story Reader State
  int _selectedStoryIndex = 0;
  int _currentStorySceneIndex = 0;
  bool _isPlayingStory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _stopAllAudio();
      }
    });
  }

  @override
  void dispose() {
    _stopAllAudio(notify: false);
    _tabController.dispose();
    super.dispose();
  }

  void _stopAllAudio({bool notify = true}) {
    _isPlayingRhyme = false;
    _isPlayingStory = false;
    if (notify && mounted) {
      setState(() {});
    }
    AudioService.instance.stopAudio();
  }

  void _playRhyme(RhymeItem rhyme, bool isHindi) {
    AudioService.instance.stopAudio();
    setState(() {
      _isPlayingRhyme = true;
    });

    final prompt = isHindi && rhyme.hindiLines != null
        ? '${rhyme.titleHi}! ${rhyme.hindiLines!.join('. ')}'
        : '${rhyme.title}! ${rhyme.speechText}';

    AudioService.instance.speakPrompt(prompt, isHindi: isHindi);
  }

  void _playStoryScene(StoryItem story, int sceneIndex, bool isHindi) {
    if (sceneIndex < 0 || sceneIndex >= story.scenes.length) return;
    AudioService.instance.stopAudio();
    setState(() {
      _currentStorySceneIndex = sceneIndex;
      _isPlayingStory = true;
    });

    final scene = story.scenes[sceneIndex];
    final text = (isHindi && scene.textHi != null) ? scene.textHi! : scene.text;
    AudioService.instance.speakPrompt(text, isHindi: isHindi);
  }

  void _playFullStory(StoryItem story, bool isHindi) {
    AudioService.instance.stopAudio();
    setState(() {
      _isPlayingStory = true;
      _currentStorySceneIndex = 0;
    });

    final fullStoryText = isHindi
        ? '${story.titleHi}. ${story.scenes.map((s) => s.textHi ?? s.text).join(' ')}. सीख: ${story.moralHi}'
        : '${story.title}. ${story.fullSpeechText}. Moral: ${story.moral}';

    AudioService.instance.speakPrompt(fullStoryText, isHindi: isHindi);
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () {
            _stopAllAudio();
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('📖', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'कविताएं और कहानियां 🎶' : 'Rhymes & Stories 🎶',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isHindi ? 'सुनें, पढ़ें और सीखें 🌟' : 'Sing, Listen & Learn 🌟',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              (_isPlayingRhyme || _isPlayingStory)
                  ? Icons.stop_circle_rounded
                  : Icons.volume_up_rounded,
              color: (_isPlayingRhyme || _isPlayingStory)
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF6366F1),
              size: 24,
            ),
            tooltip: (_isPlayingRhyme || _isPlayingStory) ? 'Stop Audio' : 'Audio Guide',
            onPressed: () {
              if (_isPlayingRhyme || _isPlayingStory) {
                _stopAllAudio();
              } else {
                AudioService.instance.speakPrompt(
                  isHindi
                      ? 'अपनी पसंदीदा कविता या कहानी चुनें और टच करके सुनें!'
                      : 'Pick any rhyme or story to read and listen along!',
                  isHindi: isHindi,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C3AED),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF7C3AED),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
          tabs: [
            Tab(
              icon: const Text('🎵', style: TextStyle(fontSize: 18)),
              text: isHindi ? 'बालगीत व कविताएं' : 'Nursery Rhymes',
            ),
            Tab(
              icon: const Text('📖', style: TextStyle(fontSize: 18)),
              text: isHindi ? 'मजेदार कहानियां' : 'Moral Stories',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRhymesTab(isHindi),
          _buildStoriesTab(isHindi),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: NURSERY RHYMES
  // ---------------------------------------------------------------------------
  Widget _buildRhymesTab(bool isHindi) {
    final activeRhyme = RhymesStoriesData.rhymes[_selectedRhymeIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Featured Spotlight Rhyme Player Card
          _buildActiveRhymeCard(activeRhyme, isHindi),

          const SizedBox(height: 20),

          // 2. All Nursery Rhymes Grid Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHindi ? 'सभी बालगीत (१० कविताएं) 🎵' : 'Explore All Rhymes (10 Songs) 🎵',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'SING-ALONG 🎶',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6D28D9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grid of all Rhymes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: RhymesStoriesData.rhymes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final rhyme = RhymesStoriesData.rhymes[index];
              final isSelected = index == _selectedRhymeIndex;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    _selectedRhymeIndex = index;
                  });
                  _playRhyme(rhyme, isHindi);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? rhyme.themeColor.withValues(alpha: 0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? rhyme.themeColor : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rhyme.emoji, style: const TextStyle(fontSize: 26)),
                          if (isSelected && _isPlayingRhyme)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: rhyme.themeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PLAYING ♫',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi ? rhyme.titleHi : rhyme.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? rhyme.themeColor : const Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rhyme.character,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActiveRhymeCard(RhymeItem rhyme, bool isHindi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rhyme.themeColor.withValues(alpha: 0.15),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rhyme.themeColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: rhyme.themeColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: rhyme.themeColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: rhyme.themeColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(rhyme.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? rhyme.titleHi : rhyme.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: rhyme.themeColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rhyme.character,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: rhyme.themeColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (_isPlayingRhyme) {
                      _stopAllAudio();
                    } else {
                      _playRhyme(rhyme, isHindi);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _isPlayingRhyme ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rhyme.lines.map((line) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.music_note_rounded, size: 16, color: rhyme.themeColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          line,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: rhyme.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: Icon(_isPlayingRhyme ? Icons.stop_rounded : Icons.record_voice_over_rounded),
              label: Text(
                _isPlayingRhyme
                    ? (isHindi ? 'कविता रोकें ⏹' : 'Stop Recitation ⏹')
                    : (isHindi ? 'पूरी कविता गाएं 🎵' : 'Sing Rhyme Along 🎵'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              onPressed: () {
                if (_isPlayingRhyme) {
                  _stopAllAudio();
                } else {
                  _playRhyme(rhyme, isHindi);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: MORAL STORIES
  // ---------------------------------------------------------------------------
  Widget _buildStoriesTab(bool isHindi) {
    final activeStory = RhymesStoriesData.stories[_selectedStoryIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Featured Interactive Story Reader Card
          _buildActiveStoryReaderCard(activeStory, isHindi),

          const SizedBox(height: 20),

          // 2. Storybook Collection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHindi ? 'कहानियों का संग्रह (५ कहानियां) 📚' : 'Story Collection (5 Tales) 📚',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'MORAL TALES 💡',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: RhymesStoriesData.stories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final story = RhymesStoriesData.stories[index];
              final isSelected = index == _selectedStoryIndex;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    _selectedStoryIndex = index;
                    _currentStorySceneIndex = 0;
                  });
                  _playStoryScene(story, 0, isHindi);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? story.themeColor.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? story.themeColor : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: story.themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(story.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? story.titleHi : story.title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? story.themeColor : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isHindi ? 'सीख: ${story.moralHi}' : 'Moral: ${story.moral}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: story.themeColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? Icons.menu_book_rounded : Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: story.themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActiveStoryReaderCard(StoryItem story, bool isHindi) {
    final activeScene = story.scenes[_currentStorySceneIndex.clamp(0, story.scenes.length - 1)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            story.themeColor.withValues(alpha: 0.14),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: story.themeColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: story.themeColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: story.themeColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(story.emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? story.titleHi : story.title,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: story.themeColor,
                      ),
                    ),
                    Text(
                      'Page ${_currentStorySceneIndex + 1} of ${story.scenes.length}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: story.themeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'STORYBOOK 📖',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Illustrated Scene Picture & Text Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: story.themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(activeScene.emoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  (isHindi && activeScene.textHi != null) ? activeScene.textHi! : activeScene.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Moral Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHindi ? 'सीख: ${story.moralHi}' : 'Moral: ${story.moral}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Scene Navigation & Audio Buttons
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: story.themeColor,
                  side: BorderSide(color: story.themeColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(isHindi ? 'पिछला' : 'Prev'),
                onPressed: _currentStorySceneIndex > 0
                    ? () {
                        _playStoryScene(story, _currentStorySceneIndex - 1, isHindi);
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: story.themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                  label: Text(
                    isHindi ? 'कहानी सुनें 🗣️' : 'Read Story 🗣️',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  onPressed: () {
                    _playFullStory(story, isHindi);
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: story.themeColor,
                  side: BorderSide(color: story.themeColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(isHindi ? 'अगला' : 'Next'),
                onPressed: _currentStorySceneIndex < story.scenes.length - 1
                    ? () {
                        _playStoryScene(story, _currentStorySceneIndex + 1, isHindi);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
