import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/voice_settings.dart';

/// Modal bottom sheet allowing users to customize TTS voice persona, accent, speed, and pitch
class VoiceSettingsSheet extends StatefulWidget {
  const VoiceSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceSettingsSheet(),
    );
  }

  @override
  State<VoiceSettingsSheet> createState() => _VoiceSettingsSheetState();
}

class _VoiceSettingsSheetState extends State<VoiceSettingsSheet> {
  late VoicePersona _selectedPersona;
  late String _selectedLocale;
  late double _speechRate;
  late double _pitch;
  bool _isPlayingSample = false;

  final List<(String, String, String)> _locales = const [
    ('en-IN', 'India', '🇮🇳'),
    ('en-US', 'United States', '🇺🇸'),
    ('en-GB', 'United Kingdom', '🇬🇧'),
    ('en-AU', 'Australia', '🇦🇺'),
  ];

  @override
  void initState() {
    super.initState();
    final current = LocalStorageService.instance.getVoiceSettings();
    _selectedPersona = current.persona;
    _selectedLocale = current.locale;
    _speechRate = current.speechRate;
    _pitch = current.pitch;
  }

  VoiceSettings get _currentSettings => VoiceSettings(
        persona: _selectedPersona,
        locale: _selectedLocale,
        speechRate: _speechRate,
        pitch: _pitch,
      );

  Future<void> _playSample() async {
    setState(() => _isPlayingSample = true);
    await AudioService.instance.testVoiceSample(_currentSettings);
    if (mounted) {
      setState(() => _isPlayingSample = false);
    }
  }

  Future<void> _saveAndClose() async {
    await AudioService.instance.setVoiceSettings(_currentSettings);
    AudioService.instance.playSfx(CurioSfx.correctCheer);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(_selectedPersona.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Voice updated to ${_selectedPersona.label}!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title & Close
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7B25).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.record_voice_over_rounded,
                    color: Color(0xFFFF7B25),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice & Narration Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Customize your read-aloud companion',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Speaker Mute / Unmute Card
            ValueListenableBuilder<bool>(
              valueListenable: AudioService.instance.muteNotifier,
              builder: (context, isMuted, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMuted ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMuted ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: isMuted ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMuted ? 'Speaker Muted' : 'Speaker Active',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isMuted ? const Color(0xFF991B1B) : const Color(0xFF166534),
                              ),
                            ),
                            Text(
                              isMuted
                                  ? 'Audio narration & sound effects are silenced'
                                  : 'Audio narration & celebratory sounds enabled',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: !isMuted,
                        activeTrackColor: const Color(0xFF16A34A),
                        onChanged: (active) {
                          AudioService.instance.setMuted(!active);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 1. Choose Voice Persona
            const Text(
              '1. Choose Learning Companion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: VoicePersona.values.map((persona) {
                final isSelected = _selectedPersona == persona;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    setState(() {
                      _selectedPersona = persona;
                      _pitch = persona.defaultPitch;
                      _speechRate = persona.defaultRate;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF7B25).withValues(alpha: 0.08)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF7B25) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(persona.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                persona.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isSelected ? const Color(0xFFFF7B25) : const Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          persona.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? const Color(0xFF9A3412) : const Color(0xFF64748B),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 2. Choose Accent / Language
            const Text(
              '2. Accent / Region',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locales.map((item) {
                final (code, name, flag) = item;
                final isSelected = _selectedLocale == code;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    setState(() => _selectedLocale = code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6366F1).withValues(alpha: 0.12)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 3. Speech Speed / Pace
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3. Reading Pace',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${(_speechRate * 100).toInt()}% speed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: VoiceSpeed.values.map((speed) {
                final isSelected = VoiceSpeed.fromRate(_speechRate) == speed;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        AudioService.instance.playSfx(CurioSfx.click);
                        setState(() => _speechRate = speed.rate);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            speed.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 4. Voice Pitch Fine-Tuning
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '4. Voice Tone / Pitch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _pitch > 1.1 ? 'Higher (Child/Mascot)' : (_pitch < 0.9 ? 'Deeper (Wise Mentor)' : 'Standard'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Slider(
              value: _pitch,
              min: 0.70,
              max: 1.45,
              divisions: 15,
              activeColor: const Color(0xFFFF7B25),
              onChanged: (val) {
                setState(() => _pitch = (val * 100).round() / 100);
              },
            ),

            const SizedBox(height: 16),

            // Buttons: Test Sample & Save
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPlayingSample ? null : _playSample,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFFF7B25), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isPlayingSample
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.volume_up_rounded, color: Color(0xFFFF7B25)),
                    label: Text(
                      _isPlayingSample ? 'Listening...' : 'Test Voice',
                      style: const TextStyle(
                        color: Color(0xFFFF7B25),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7B25),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save & Apply',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
