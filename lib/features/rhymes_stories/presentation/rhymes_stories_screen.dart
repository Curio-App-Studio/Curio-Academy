import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../domain/rhyme_story_model.dart';
import 'widgets/animated_story_scene.dart';
import 'widgets/animated_rhyme_stage.dart';

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
  bool _isPlayingMelody = false;
  int? _speakingRhymeLineIndex;
  Timer? _melodySyncTimer;

  // Active Story Reader State
  int _selectedStoryIndex = 0;
  int _currentStorySceneIndex = 0;
  bool _isPlayingStory = false;
  int? _speakingSectionIndex;
  bool _isAutoReadingStory = false;

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
    _melodySyncTimer?.cancel();
    _melodySyncTimer = null;
    _isPlayingRhyme = false;
    _isPlayingMelody = false;
    _speakingRhymeLineIndex = null;
    _isPlayingStory = false;
    _isAutoReadingStory = false;
    _speakingSectionIndex = null;
    if (notify && mounted) {
      setState(() {});
    }
    AudioService.instance.stopAudio();
  }

  void _playSingleRhymeLine(RhymeItem rhyme, int lineIndex, bool isHindi) {
    _stopAllAudio();
    final lines = (isHindi && rhyme.hindiLines != null) ? rhyme.hindiLines! : rhyme.lines;
    if (lineIndex < 0 || lineIndex >= lines.length) return;

    setState(() {
      _isPlayingRhyme = true;
      _isPlayingMelody = false;
      _speakingRhymeLineIndex = lineIndex;
    });

    AudioService.instance.playSfx(CurioSfx.click);
    final text = lines[lineIndex];
    AudioService.instance.speakKidStorytelling(
      text,
      isHindi: isHindi,
      pitch: 1.05,
      speechRate: 0.46,
      onComplete: () {
        if (mounted) {
          setState(() {
            _speakingRhymeLineIndex = null;
            _isPlayingRhyme = false;
          });
        }
      },
    );
  }

  /// Plays the authentic nursery rhyme melody on its own, advancing line highlights in sync with the musical phrasing
  void _playRhymeMelody(RhymeItem rhyme, bool isHindi) {
    _stopAllAudio();
    setState(() {
      _isPlayingMelody = true;
      _isPlayingRhyme = false;
      _speakingRhymeLineIndex = 0;
    });

    final lines = (isHindi && rhyme.hindiLines != null) ? rhyme.hindiLines! : rhyme.lines;
    const melodyDurationsMs = <String, int>{
      'twinkle_star': 20200,
      'baa_baa_black_sheep': 16800,
      'humpty_dumpty': 13400,
      'wheels_on_the_bus': 12600,
      'johny_johny': 14300,
      'jack_and_jill': 11800,
      'incy_wincy_spider': 13400,
      'row_row_boat': 10100,
      'five_little_monkeys': 12600,
      'hickory_dickory': 11800,
    };

    final totalMs = melodyDurationsMs[rhyme.id] ?? 14000;
    final lineDurationMs = (totalMs / lines.length).round();

    int currentLine = 0;
    _melodySyncTimer?.cancel();
    _melodySyncTimer = Timer.periodic(Duration(milliseconds: lineDurationMs), (timer) {
      if (!mounted || !_isPlayingMelody) {
        timer.cancel();
        return;
      }
      currentLine++;
      if (currentLine < lines.length) {
        setState(() {
          _speakingRhymeLineIndex = currentLine;
        });
      } else {
        timer.cancel();
      }
    });

    AudioService.instance.playMelody(
      'assets/audio/rhymes/${rhyme.id}.wav',
      volume: 0.85,
      onComplete: () {
        _melodySyncTimer?.cancel();
        if (mounted) {
          setState(() {
            _isPlayingMelody = false;
            _speakingRhymeLineIndex = null;
          });
        }
      },
    );
  }

  /// Clean voice-only recitation: speaks line-by-line with poetic rhythm without clashing background music
  void _playRhymeVoice(RhymeItem rhyme, bool isHindi) {
    _stopAllAudio();
    setState(() {
      _isPlayingRhyme = true;
      _isPlayingMelody = false;
      _speakingRhymeLineIndex = 0;
    });

    _readRhymeLineSequentially(rhyme, 0, isHindi);
  }

  void _readRhymeLineSequentially(RhymeItem rhyme, int index, bool isHindi) {
    if (!mounted || !_isPlayingRhyme) return;
    final lines = (isHindi && rhyme.hindiLines != null) ? rhyme.hindiLines! : rhyme.lines;
    if (index >= lines.length) {
      if (mounted) {
        setState(() {
          _isPlayingRhyme = false;
          _speakingRhymeLineIndex = null;
        });
      }
      return;
    }

    setState(() {
      _speakingRhymeLineIndex = index;
    });

    final lineText = lines[index];
    AudioService.instance.speakKidStorytelling(
      lineText,
      isHindi: isHindi,
      pitch: 1.05,
      speechRate: 0.46,
      onComplete: () {
        if (mounted && _isPlayingRhyme) {
          Future.delayed(const Duration(milliseconds: 320), () {
            if (mounted && _isPlayingRhyme) {
              _readRhymeLineSequentially(rhyme, index + 1, isHindi);
            }
          });
        }
      },
    );
  }

  void _playStoryScene(StoryItem story, int sceneIndex, bool isHindi) {
    if (sceneIndex < 0 || sceneIndex >= story.scenes.length) return;
    AudioService.instance.stopAudio();
    setState(() {
      _currentStorySceneIndex = sceneIndex;
      _speakingSectionIndex = sceneIndex;
      _isPlayingStory = true;
      _isAutoReadingStory = false;
    });

    AudioService.instance.playSfx(CurioSfx.click);
    final scene = story.scenes[sceneIndex];
    final text = (isHindi && scene.textHi != null) ? scene.textHi! : scene.text;
    final speechText = text;

    AudioService.instance.speakKidStorytelling(
      speechText,
      isHindi: isHindi,
      onComplete: () {
        if (mounted) {
          setState(() {
            _speakingSectionIndex = null;
            _isPlayingStory = false;
          });
        }
      },
    );
  }

  void _playFullStory(StoryItem story, bool isHindi) {
    AudioService.instance.stopAudio();
    setState(() {
      _isPlayingStory = true;
      _isAutoReadingStory = true;
      _currentStorySceneIndex = 0;
      _speakingSectionIndex = 0;
    });

    AudioService.instance.playSfx(CurioSfx.starAward);
    final introText = isHindi
        ? 'सुनो मजेदार कहानी: ${story.titleHi}!'
        : 'Story time! ... ${story.title}!';

    AudioService.instance.speakKidStorytelling(
      introText,
      isHindi: isHindi,
      onComplete: () {
        if (mounted && _isAutoReadingStory) {
          _readSectionSequentially(story, 0, isHindi);
        }
      },
    );
  }

  void _readSectionSequentially(StoryItem story, int index, bool isHindi) {
    if (!mounted || !_isAutoReadingStory) return;

    if (index >= story.scenes.length) {
      _readMoralSection(story, isHindi);
      return;
    }

    setState(() {
      _currentStorySceneIndex = index;
      _speakingSectionIndex = index;
    });

    final scene = story.scenes[index];
    final text = (isHindi && scene.textHi != null) ? scene.textHi! : scene.text;
    final speechText = text;

    AudioService.instance.speakKidStorytelling(
      speechText,
      isHindi: isHindi,
      onComplete: () {
        if (mounted && _isAutoReadingStory) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted && _isAutoReadingStory) {
              _readSectionSequentially(story, index + 1, isHindi);
            }
          });
        }
      },
    );
  }

  void _readMoralSection(StoryItem story, bool isHindi) {
    if (!mounted || !_isAutoReadingStory) return;

    setState(() {
      _speakingSectionIndex = story.scenes.length; // Moral is active
    });

    AudioService.instance.playSfx(CurioSfx.correctCheer);
    final moralSpeech = isHindi
        ? 'कहानी की सीख: ${story.moralHi}! बहुत बढ़िया!'
        : 'And the moral of the story is: ${story.moral}! Great job listening!';

    AudioService.instance.speakKidStorytelling(
      moralSpeech,
      isHindi: isHindi,
      onComplete: () {
        if (mounted) {
          setState(() {
            _speakingSectionIndex = null;
            _isPlayingStory = false;
            _isAutoReadingStory = false;
          });
        }
      },
    );
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
                  _playRhymeMelody(rhyme, isHindi);
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
                    if (_isPlayingRhyme || _isPlayingMelody) {
                      _stopAllAudio();
                    } else {
                      _playRhymeMelody(rhyme, isHindi);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      (_isPlayingRhyme || _isPlayingMelody)
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Interactive Animated Musical Stage for Kids
          AnimatedRhymeStage(
            rhyme: rhyme,
            isPlaying: _isPlayingRhyme || _isPlayingMelody,
            isHindi: isHindi,
          ),
          const SizedBox(height: 14),
          // Interactive Karaoke / Line-by-Line Lyrics Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (_isPlayingRhyme && _speakingRhymeLineIndex != null)
                    ? rhyme.themeColor
                    : const Color(0xFFE2E8F0),
                width: (_isPlayingRhyme && _speakingRhymeLineIndex != null) ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...((isHindi && rhyme.hindiLines != null) ? rhyme.hindiLines! : rhyme.lines)
                    .asMap()
                    .entries
                    .map((entry) {
                  final lineIndex = entry.key;
                  final line = entry.value;
                  final isThisLineActive = _speakingRhymeLineIndex == lineIndex;

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _playSingleRhymeLine(rhyme, lineIndex, isHindi);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 2.5),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isThisLineActive
                            ? rhyme.themeColor.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isThisLineActive
                            ? Border.all(color: rhyme.themeColor, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isThisLineActive
                                ? Icons.volume_up_rounded
                                : Icons.music_note_rounded,
                            size: 16,
                            color: isThisLineActive
                                ? rhyme.themeColor
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: isThisLineActive
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: isThisLineActive
                                    ? rhyme.themeColor
                                    : const Color(0xFF1E293B),
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (isThisLineActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: rhyme.themeColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _isPlayingMelody ? '🎵 MELODY' : '🗣️ SPEAKING',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dual Action Controls: 1) Play Melody (with synced karaoke highlights) & 2) Read Rhyme (Voice-only recitation)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rhyme.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: Icon(
                    _isPlayingMelody ? Icons.stop_rounded : Icons.music_note_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _isPlayingMelody
                        ? (isHindi ? 'धुन रोकें ⏹' : 'Stop Melody ⏹')
                        : (isHindi ? 'धुन बजाएं (गाएं) 🎵' : 'Play Melody 🎵'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  onPressed: () {
                    if (_isPlayingMelody) {
                      _stopAllAudio();
                    } else {
                      _playRhymeMelody(rhyme, isHindi);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: rhyme.themeColor,
                    side: BorderSide(color: rhyme.themeColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(
                    _isPlayingRhyme ? Icons.stop_rounded : Icons.record_voice_over_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _isPlayingRhyme
                        ? (isHindi ? 'पढ़ना रोकें ⏹' : 'Stop Reading ⏹')
                        : (isHindi ? 'कविता सुनें 🗣️' : 'Read Rhyme 🗣️'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  onPressed: () {
                    if (_isPlayingRhyme) {
                      _stopAllAudio();
                    } else {
                      _playRhymeVoice(rhyme, isHindi);
                    }
                  },
                ),
              ),
            ],
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
                          child: story.id == 'thirsty_crow'
                              ? Transform.flip(
                                  flipX: true,
                                  child: Text(story.emoji, style: const TextStyle(fontSize: 24)),
                                )
                              : Text(story.emoji, style: const TextStyle(fontSize: 24)),
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
    final isCurrentSceneSpeaking = _speakingSectionIndex == _currentStorySceneIndex;
    final isMoralSpeaking = _speakingSectionIndex == story.scenes.length;

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
                  child: story.id == 'thirsty_crow'
                      ? Transform.flip(
                          flipX: true,
                          child: Text(story.emoji, style: const TextStyle(fontSize: 26)),
                        )
                      : Text(story.emoji, style: const TextStyle(fontSize: 26)),
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

          // 1. Dynamic Animated Picture-Book Canvas (Kid Illustrated & Touch-Interactive)
          AnimatedStorySceneIllustration(
            story: story,
            currentSceneIndex: _currentStorySceneIndex,
            isSpeaking: isCurrentSceneSpeaking,
            isHindi: isHindi,
          ),
          const SizedBox(height: 12),

          // 2. Interactive Section-by-Section Step Tracker (Timeline)
          _buildStorySectionTimeline(story, isHindi),
          const SizedBox(height: 12),

          // 3. Illustrated Scene Text Container (Visually Highlights Currently Speaking Section)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentSceneSpeaking
                  ? story.themeColor.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isCurrentSceneSpeaking
                    ? story.themeColor
                    : const Color(0xFFE2E8F0),
                width: isCurrentSceneSpeaking ? 2.5 : 1.5,
              ),
              boxShadow: isCurrentSceneSpeaking
                  ? [
                      BoxShadow(
                        color: story.themeColor.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: Column(
              children: [
                if (isCurrentSceneSpeaking)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: story.themeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          isHindi
                              ? 'अब पढ़ा जा रहा है: पृष्ठ ${_currentStorySceneIndex + 1}/${story.scenes.length} 🗣️'
                              : 'NOW READING: PAGE ${_currentStorySceneIndex + 1} OF ${story.scenes.length} 🗣️',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  (isHindi && activeScene.textHi != null) ? activeScene.textHi! : activeScene.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Moral Box (Highlights when speaking moral)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMoralSpeaking
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isMoralSpeaking
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFFDE68A),
                width: isMoralSpeaking ? 2.5 : 1.5,
              ),
              boxShadow: isMoralSpeaking
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Text(
                  isMoralSpeaking ? '🌟' : '💡',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMoralSpeaking)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            isHindi ? 'कहानी की सीख बोली जा रही है 🔊' : 'READING MORAL LESSON 🔊',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      Text(
                        isHindi ? 'सीख: ${story.moralHi}' : 'Moral: ${story.moral}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Scene Navigation & Audio Buttons
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
                  icon: Icon(_isPlayingStory ? Icons.stop_rounded : Icons.record_voice_over_rounded, size: 18),
                  label: Text(
                    _isPlayingStory
                        ? (isHindi ? 'कहानी रोकें ⏹' : 'Stop Story ⏹')
                        : (isHindi ? 'कहानी सुनें 🗣️' : 'Read Story 🗣️'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  onPressed: () {
                    if (_isPlayingStory) {
                      _stopAllAudio();
                    } else {
                      _playFullStory(story, isHindi);
                    }
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

  Widget _buildStorySectionTimeline(StoryItem story, bool isHindi) {
    final totalScenes = story.scenes.length;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: totalScenes + 1, // scenes + moral
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final isMoral = i == totalScenes;
          final isSpeakingThis = _speakingSectionIndex == i;
          final isSelectedThis = !isMoral && _currentStorySceneIndex == i;
          final isCompleted = !isMoral && i < _currentStorySceneIndex;

          Color bg;
          Color textCol;
          Border? border;

          if (isSpeakingThis) {
            bg = isMoral ? const Color(0xFFF59E0B) : story.themeColor;
            textCol = Colors.white;
            border = Border.all(color: Colors.white, width: 2);
          } else if (isSelectedThis) {
            bg = story.themeColor.withValues(alpha: 0.15);
            textCol = story.themeColor;
            border = Border.all(color: story.themeColor, width: 2);
          } else if (isCompleted) {
            bg = const Color(0xFFE2E8F0);
            textCol = const Color(0xFF475569);
          } else if (isMoral) {
            bg = const Color(0xFFFEF3C7);
            textCol = const Color(0xFFB45309);
          } else {
            bg = Colors.white;
            textCol = const Color(0xFF64748B);
            border = Border.all(color: const Color(0xFFE2E8F0));
          }

          final label = isMoral
              ? (isHindi ? 'सीख 💡' : 'Moral 💡')
              : (isCompleted ? '✓ ${i + 1}' : '${i + 1}');

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (isMoral) {
                _readMoralSection(story, isHindi);
              } else {
                setState(() {
                  _currentStorySceneIndex = i;
                });
                _playStoryScene(story, i, isHindi);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: border,
                boxShadow: isSpeakingThis
                    ? [
                        BoxShadow(
                          color: (isMoral ? const Color(0xFFF59E0B) : story.themeColor).withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSpeakingThis) ...[
                    const Icon(Icons.volume_up_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    isSpeakingThis
                        ? (isMoral
                            ? (isHindi ? 'सीख 💡' : 'Moral 💡')
                            : (isHindi ? 'भाग ${i + 1}' : 'Page ${i + 1}'))
                        : label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: textCol,
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
