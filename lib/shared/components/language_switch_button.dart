import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/local/local_storage_service.dart';

/// Compact kid-friendly Language Switcher Button for AppBars
/// Reactive with Riverpod appLanguageProvider and LocalStorageService.instance.languageNotifier
class LanguageSwitchButton extends ConsumerWidget {
  final bool isDark;
  const LanguageSwitchButton({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              final nextCode = isHindi ? 'en' : 'hi';
              final nextLang = AppLanguage.fromCode(nextCode);

              // 1. Update Riverpod provider to trigger immediate app-wide rebuild
              try {
                await ref.read(appLanguageProvider.notifier).setLanguage(nextLang);
              } catch (_) {
                // Fallback if mounted outside ProviderScope
                await LocalStorageService.instance.saveAppLanguage(nextCode);
                final newLocale = nextCode == 'hi' ? 'hi-IN' : 'en-IN';
                final curSettings = AudioService.instance.currentVoiceSettings;
                await AudioService.instance.setVoiceSettings(
                  curSettings.copyWith(locale: newLocale),
                );
              }

              // 2. Also ensure local storage is explicitly aligned
              await LocalStorageService.instance.saveAppLanguage(nextCode);
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text(nextCode == 'hi' ? '🇮🇳' : '🇬🇧', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nextCode == 'hi'
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
              padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 3),
              margin: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFBFDBFE),
                  width: 1.1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isHindi ? '🇮🇳' : '🌐',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 3.5),
                  Text(
                    isHindi ? 'हिन्दी' : 'EN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
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
