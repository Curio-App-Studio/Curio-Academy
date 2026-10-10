import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../domain/spell_bee_repository.dart';
import '../domain/spell_bee_word.dart';

/// Spelling Mistake Vault & Interactive Flashcard Revision Deck
class SpellBeeMistakesScreen extends StatefulWidget {
  const SpellBeeMistakesScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpellBeeMistakesScreen()),
    );
  }

  @override
  State<SpellBeeMistakesScreen> createState() => _SpellBeeMistakesScreenState();
}

class _SpellBeeMistakesScreenState extends State<SpellBeeMistakesScreen> {
  final LocalStorageService _storage = LocalStorageService.instance;
  final SpellBeeRepository _repo = SpellBeeRepository.instance;
  bool _isFlashcardMode = false;
  int _cardIndex = 0;
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final isHindi = _storage.getAppLanguage() == 'hi';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF78350F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isHindi ? 'स्पेलिंग मिस्टेक वॉल्ट' : 'Spelling Mistake Vault',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF78350F)),
        ),
        actions: [
          ValueListenableBuilder<List<String>>(
            valueListenable: _storage.spellBeeMistakesNotifier,
            builder: (context, mistakes, _) {
              if (mistakes.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: _isFlashcardMode ? 'Switch to List' : 'Switch to Flashcards',
                icon: Icon(
                  _isFlashcardMode ? Icons.format_list_bulleted_rounded : Icons.flip_to_back_rounded,
                  color: const Color(0xFF78350F),
                ),
                onPressed: () {
                  setState(() {
                    _isFlashcardMode = !_isFlashcardMode;
                    _cardIndex = 0;
                    _isFlipped = false;
                  });
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<String>>(
          valueListenable: _storage.spellBeeMistakesNotifier,
          builder: (context, mistakes, _) {
            if (mistakes.isEmpty) {
              return _buildEmptyState(isHindi);
            }

            if (_isFlashcardMode) {
              return _buildFlashcardView(mistakes, isHindi);
            }

            return _buildListView(mistakes, isHindi);
          },
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildEmptyState(bool isHindi) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              ),
              child: const Center(
                child: Text('🌟', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isHindi ? 'कोई गलती नहीं बची!' : 'Mistake Vault is Empty!',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF78350F)),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'आपने अपनी सभी कठिन स्पेलिंग्स मास्टर कर ली हैं या अभी तक कोई गलती नहीं की।'
                  : 'You have mastered all your tricky spelling words! Keep practicing to stay sharp.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<String> mistakes, bool isHindi) {
    return Column(
      children: [
        // Header Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                '${mistakes.length} ${isHindi ? "शब्द दोहराने के लिए" : "words to review"}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFB45309)),
                onPressed: () {
                  setState(() {
                    _isFlashcardMode = true;
                    _cardIndex = 0;
                    _isFlipped = false;
                  });
                },
                icon: const Icon(Icons.style_rounded, size: 18),
                label: Text(
                  isHindi ? 'फ्लैशकार्ड मोड' : 'Flashcards',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),

        // List of Cards
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            itemCount: mistakes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final rawWord = mistakes[idx];
              final wordObj = _repo.findWord(rawWord) ??
                  SpellBeeWord(
                    word: rawWord,
                    definition: 'Spelling word under review',
                    exampleSentence: 'Practice spelling this word correctly.',
                    emoji: '📝',
                    targetClass: _storage.getStudentClass(),
                  );

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(wordObj.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                wordObj.word,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Color(0xFF1F2937),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  wordObj.origin,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wordObj.definition,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFF59E0B)),
                      onPressed: () => AudioService.instance.speakPrompt(wordObj.word),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
                      tooltip: isHindi ? 'मास्टर हो गया' : 'Mastered',
                      onPressed: () {
                        AudioService.instance.playSfx(CurioSfx.correctCheer);
                        _storage.removeSpellBeeMistake(wordObj.word);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardView(List<String> mistakes, bool isHindi) {
    if (_cardIndex >= mistakes.length) {
      _cardIndex = mistakes.length - 1;
    }
    final rawWord = mistakes[_cardIndex];
    final wordObj = _repo.findWord(rawWord) ??
        SpellBeeWord(
          word: rawWord,
          definition: 'Practice spelling this word.',
          exampleSentence: 'Use in sentence for context.',
          emoji: '📝',
          targetClass: _storage.getStudentClass(),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Flashcard Count Indicator
          Text(
            '${isHindi ? "कार्ड" : "Card"} ${_cardIndex + 1} of ${mistakes.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
          ),
          const SizedBox(height: 16),

          // Flip Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _isFlipped = !_isFlipped);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isFlipped
                        ? [const Color(0xFFFEF3C7), Colors.white]
                        : [Colors.white, const Color(0xFFFFFBEB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(wordObj.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 14),
                    if (!_isFlipped) ...[
                      // Front: Clues & Audio only
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${wordObj.partOfSpeech} • ${wordObj.origin}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        wordObj.definition,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => AudioService.instance.speakPrompt(wordObj.word),
                        icon: const Icon(Icons.volume_up_rounded),
                        label: Text(isHindi ? 'उच्चारण सुनें' : 'Listen Pronunciation'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isHindi ? '👆 स्पेलिंग देखने के लिए टैप करें' : '👆 Tap card to reveal spelling',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                      ),
                    ] else ...[
                      // Back: Full Revealed Spelling & Phonetics
                      Text(
                        wordObj.word,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      if (wordObj.phonetic.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          wordObj.phonetic,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                        ),
                      ],
                      const Divider(height: 28),
                      Text(
                        '"${wordObj.exampleSentence}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          AudioService.instance.playSfx(CurioSfx.correctCheer);
                          _storage.removeSpellBeeMistake(wordObj.word);
                          setState(() {
                            _isFlipped = false;
                          });
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(
                          isHindi ? 'मुझे याद हो गया (Mastered!)' : 'I Mastered This Word!',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 28, color: Color(0xFF78350F)),
                onPressed: _cardIndex > 0
                    ? () {
                        setState(() {
                          _cardIndex--;
                          _isFlipped = false;
                        });
                      }
                    : null,
              ),
              Text(
                '${_cardIndex + 1} / ${mistakes.length}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF78350F)),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 28, color: Color(0xFF78350F)),
                onPressed: _cardIndex + 1 < mistakes.length
                    ? () {
                        setState(() {
                          _cardIndex++;
                          _isFlipped = false;
                        });
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
