import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/voice_spelling_service.dart';

/// Interactive National Spell Bee Stage Voice Spelling Sheet
/// Lets children speak the spelling aloud (e.g., "C - A - T" or word)
/// with real-time audio visualization, letter chip feedback, and auto-submit.
class VoiceSpellingSheet extends StatefulWidget {
  final String targetWord;
  final String? wordPrompt;
  final ValueChanged<List<String>> onSpellingComplete;

  const VoiceSpellingSheet({
    super.key,
    required this.targetWord,
    this.wordPrompt,
    required this.onSpellingComplete,
  });

  static Future<void> show(
    BuildContext context, {
    required String targetWord,
    String? wordPrompt,
    required ValueChanged<List<String>> onSpellingComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceSpellingSheet(
        targetWord: targetWord,
        wordPrompt: wordPrompt,
        onSpellingComplete: onSpellingComplete,
      ),
    );
  }

  @override
  State<VoiceSpellingSheet> createState() => _VoiceSpellingSheetState();
}

class _VoiceSpellingSheetState extends State<VoiceSpellingSheet> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isListening = false;
  String _recognizedTranscript = '';
  List<String> _parsedLetters = [];
  bool _isMatch = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start listening on sheet open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVoiceRecognition();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    VoiceSpellingService.instance.stopListening();
    super.dispose();
  }

  Future<void> _startVoiceRecognition() async {
    setState(() {
      _isListening = true;
      _errorMessage = null;
      _recognizedTranscript = '';
      _parsedLetters = [];
      _isMatch = false;
    });

    AudioService.instance.playSfx(CurioSfx.bubblePop);

    await VoiceSpellingService.instance.startListening(
      targetWord: widget.targetWord,
      onResult: (words, letters, isMatch) {
        if (!mounted) return;
        setState(() {
          _recognizedTranscript = words;
          _parsedLetters = letters;
          _isMatch = isMatch;
        });

        if (isMatch) {
          _onPerfectMatch();
        }
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _errorMessage = err;
        });
      },
      onListeningComplete: () {
        if (!mounted) return;
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  Future<void> _stopVoiceRecognition() async {
    await VoiceSpellingService.instance.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onPerfectMatch() async {
    AudioService.instance.playSfx(CurioSfx.correctCheer);
    await VoiceSpellingService.instance.stopListening();
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSpellingComplete(_parsedLetters);
    }
  }

  void _applyManualLetters() {
    if (_parsedLetters.isNotEmpty) {
      AudioService.instance.playSfx(CurioSfx.click);
      Navigator.of(context).pop();
      widget.onSpellingComplete(_parsedLetters);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetUpper = widget.targetWord.toUpperCase();
    final targetLength = targetUpper.length;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎙️', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'National Spell Bee Stage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    Text(
                      widget.wordPrompt ?? 'Speak the spelling clearly (e.g., "C - A - T")',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Target Word Blank Slots (reveals length and matched letters)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(targetLength, (index) {
              final targetChar = targetUpper[index];
              final hasSpoken = index < _parsedLetters.length;
              final spokenChar = hasSpoken ? _parsedLetters[index] : null;
              final isCorrectLetter = spokenChar == targetChar;

              Color bg = const Color(0xFFF8FAFC);
              Color border = const Color(0xFFCBD5E1);
              Color textCol = const Color(0xFF334155);

              if (hasSpoken) {
                if (isCorrectLetter) {
                  bg = const Color(0xFFECFDF5);
                  border = const Color(0xFF10B981);
                  textCol = const Color(0xFF047857);
                } else {
                  bg = const Color(0xFFFEF2F2);
                  border = const Color(0xFFEF4444);
                  textCol = const Color(0xFFB91C1C);
                }
              }

              return Container(
                width: 44,
                height: 50,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 2),
                ),
                child: Center(
                  child: Text(
                    spokenChar ?? '_',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: textCol,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Glowing Stage Microphone Animation
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopVoiceRecognition();
              } else {
                _startVoiceRecognition();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring
                if (_isListening)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                          ),
                        ),
                      );
                    },
                  ),

                // Main Mic Button
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFF59E0B), const Color(0xFFEA580C)]
                          : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? const Color(0xFFEA580C) : const Color(0xFF6366F1))
                            .withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Status & Transcript Box
          Text(
            _isMatch
                ? '🎉 Perfect! Word Matched!'
                : _isListening
                    ? 'Listening... say letters aloud 👂'
                    : 'Tap microphone to speak',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _isMatch
                  ? const Color(0xFF059669)
                  : _isListening
                      ? const Color(0xFFD97706)
                      : const Color(0xFF64748B),
            ),
          ),

          if (_recognizedTranscript.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Heard: "$_recognizedTranscript"',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Use Letter Tiles', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              if (_parsedLetters.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _applyManualLetters,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Apply Spelling', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
