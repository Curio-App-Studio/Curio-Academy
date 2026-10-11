import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../services/ad_service.dart';
import '../domain/arcade_question_engine.dart';

/// 2-Player Split-Screen Math Duel
/// Player 1 sits at the top (view rotated 180°), Player 2 sits at the bottom.
/// Simultaneous rapid-fire quiz duel on a single phone screen!
class SplitScreenDuelScreen extends ConsumerStatefulWidget {
  const SplitScreenDuelScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SplitScreenDuelScreen()),
    );
  }

  @override
  ConsumerState<SplitScreenDuelScreen> createState() => _SplitScreenDuelScreenState();
}

class _SplitScreenDuelScreenState extends ConsumerState<SplitScreenDuelScreen> {
  late final ArcadeQuestionEngine _engine;
  ArcadeQuestion? _currentQuestion;

  int _player1Score = 0;
  int _player2Score = 0;
  final int _targetScore = 5;

  bool _p1LockedOut = false;
  bool _p2LockedOut = false;
  int? _winner; // 1 or 2
  int _roundNumber = 1;
  final Set<String> _usedPrompts = {};

  @override
  void initState() {
    super.initState();
    _engine = ArcadeQuestionEngine();
    _startMatch();
  }

  void _startMatch() {
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
      _roundNumber = 1;
      _winner = null;
      _usedPrompts.clear();
    });
    _nextQuestion();
  }

  void _nextQuestion() {
    final activeProfile = ref.read(studentProfileProvider);
    final question = _engine.generateQuestion(
      activeProfile.studentClass,
      excludedPrompts: _usedPrompts,
    );
    _usedPrompts.add(question.displayPrompt);
    setState(() {
      _currentQuestion = question;
      _p1LockedOut = false;
      _p2LockedOut = false;
    });
  }

  void _handlePlayerTap(int player, int option) async {
    if (_winner != null || _currentQuestion == null) return;
    if (player == 1 && _p1LockedOut) return;
    if (player == 2 && _p2LockedOut) return;

    final isCorrect = option == _currentQuestion!.correctAnswer;

    if (isCorrect) {
      AudioService.instance.playSfx(CurioSfx.bubblePop);
      setState(() {
        if (player == 1) {
          _player1Score++;
        } else {
          _player2Score++;
        }
      });

      if (_player1Score >= _targetScore) {
        _onVictory(1);
      } else if (_player2Score >= _targetScore) {
        _onVictory(2);
      } else {
        _roundNumber++;
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) _nextQuestion();
      }
    } else {
      // Wrong tap locks player out for this question
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      setState(() {
        if (player == 1) {
          _p1LockedOut = true;
        } else {
          _p2LockedOut = true;
        }
      });

      // If both locked out, advance question automatically
      if (_p1LockedOut && _p2LockedOut) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _roundNumber++;
          _nextQuestion();
        }
      }
    }
  }

  void _onVictory(int winner) {
    AudioService.instance.playSfx(CurioSfx.applause);
    AdService().recordTestCompleted();
    setState(() {
      _winner = winner;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.strings;
    final isHindi = strings.isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // TOP HALF: Player 1 (Inverted 180° for head-to-head seating)
                Expanded(
                  child: Transform.rotate(
                    angle: math.pi, // 180 degrees
                    child: _buildPlayerArena(
                      playerNum: 1,
                      playerName: isHindi ? 'खिलाड़ी 1' : 'Player 1',
                      avatar: '🦁',
                      score: _player1Score,
                      primaryColor: const Color(0xFFEA580C),
                      isLockedOut: _p1LockedOut,
                      isHindi: isHindi,
                    ),
                  ),
                ),

                // CENTER DIVIDER HUD
                _buildCenterDividerHUD(isHindi),

                // BOTTOM HALF: Player 2 (Standard upright orientation)
                Expanded(
                  child: _buildPlayerArena(
                    playerNum: 2,
                    playerName: isHindi ? 'खिलाड़ी 2' : 'Player 2',
                    avatar: '🐯',
                    score: _player2Score,
                    primaryColor: const Color(0xFF2563EB),
                    isLockedOut: _p2LockedOut,
                    isHindi: isHindi,
                  ),
                ),
              ],
            ),

            // Winner Celebration Overlay
            if (_winner != null) _buildWinnerOverlay(isHindi),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterDividerHUD(bool isHindi) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${isHindi ? "राउंड" : "ROUND"} $_roundNumber • ${isHindi ? "लक्ष्य: 5 अंक" : "FIRST TO 5"}',
              style: const TextStyle(
                color: Color(0xFFFBBF24),
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
            onPressed: _startMatch,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArena({
    required int playerNum,
    required String playerName,
    required String avatar,
    required int score,
    required Color primaryColor,
    required bool isLockedOut,
    required bool isHindi,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
      ),
      child: Column(
        children: [
          // Player Header & Score Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    playerName,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Score Dots (5 points)
              Row(
                children: List.generate(_targetScore, (index) {
                  final filled = index < score;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: filled ? const Color(0xFFFBBF24) : Colors.white12,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: filled ? const Color(0xFFF59E0B) : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const Spacer(),

          // Question Card
          if (_currentQuestion != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: isLockedOut ? const Color(0xFF334155) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLockedOut ? Colors.red.withValues(alpha: 0.5) : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  isLockedOut ? (isHindi ? '❌ लॉक आउट!' : '❌ LOCKED OUT') : _currentQuestion!.displayPrompt,
                  style: TextStyle(
                    fontSize: isLockedOut ? 16 : 28,
                    fontWeight: FontWeight.w900,
                    color: isLockedOut ? const Color(0xFFF87171) : Colors.white,
                    letterSpacing: isLockedOut ? 0 : 1.5,
                  ),
                ),
              ),
            ),

          const Spacer(),

          // 4 Options (2x2 Rows)
          if (_currentQuestion != null && _currentQuestion!.options.length >= 4) ...[
            Row(
              children: [
                Expanded(child: _buildOptionButton(playerNum, _currentQuestion!.options[0], primaryColor, isLockedOut)),
                const SizedBox(width: 8),
                Expanded(child: _buildOptionButton(playerNum, _currentQuestion!.options[1], primaryColor, isLockedOut)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildOptionButton(playerNum, _currentQuestion!.options[2], primaryColor, isLockedOut)),
                const SizedBox(width: 8),
                Expanded(child: _buildOptionButton(playerNum, _currentQuestion!.options[3], primaryColor, isLockedOut)),
              ],
            ),
          ],

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int playerNum, int opt, Color primaryColor, bool isLockedOut) {
    return SizedBox(
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLockedOut ? null : () => _handlePlayerTap(playerNum, opt),
          child: Container(
            decoration: BoxDecoration(
              color: isLockedOut ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLockedOut ? Colors.white10 : primaryColor.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                '$opt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isLockedOut ? Colors.white24 : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerOverlay(bool isHindi) {
    final isP1 = _winner == 1;
    final winnerName = isP1 ? (isHindi ? 'खिलाड़ी 1' : 'Player 1 (Lion 🦁)') : (isHindi ? 'खिलाड़ी 2' : 'Player 2 (Tiger 🐯)');
    final winnerColor = isP1 ? const Color(0xFFEA580C) : const Color(0xFF2563EB);

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: winnerColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: winnerColor.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 10),
              Text(
                isHindi ? 'विजेता!' : 'VICTORY!',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$winnerName ${isHindi ? "जीत गया! 🏆" : "Wins the Duel! 🏆"}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_player1Score',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFEA580C)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white54)),
                  ),
                  Text(
                    '$_player2Score',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _startMatch,
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: Text(
                    isHindi ? 'फिर से खेलें ⚔️' : 'Rematch ⚔️',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7B25),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  isHindi ? 'बाहर निकलें' : 'Exit to Dashboard',
                  style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
