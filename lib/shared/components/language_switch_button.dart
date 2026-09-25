import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../data/local/local_storage_service.dart';

/// Compact kid-friendly Language Switcher Button for AppBars
/// Offline-first and reactive using LocalStorageService.instance.languageNotifier
class LanguageSwitchButton extends StatelessWidget {
  final bool isDark;
  const LanguageSwitchButton({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalStorageService.instance.languageNotifier,
      builder: (context, langCode, _) {
        final isHindi = langCode == 'hi';
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              AudioService.instance.playSfx(CurioSfx.click);
              final next = isHindi ? 'en' : 'hi';
              await LocalStorageService.instance.saveAppLanguage(next);
              final newLocale = next == 'hi' ? 'hi-IN' : 'en-IN';
              final curSettings = AudioService.instance.currentVoiceSettings;
              await AudioService.instance.setVoiceSettings(
                curSettings.copyWith(locale: newLocale),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text(next == 'hi' ? '🇮🇳' : '🇬🇧', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            next == 'hi'
                                ? 'भाषा बदलकर हिन्दी कर दी गई है! 🇮🇳'
                                : 'Language changed to English! 🇬🇧',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFBFDBFE),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isHindi ? '🇮🇳' : '🌐',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isHindi ? 'हिन्दी' : 'EN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                      color: isDark ? Colors.white : const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
