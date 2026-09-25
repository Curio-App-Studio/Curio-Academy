import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/tier_theme_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

class CurioApp extends ConsumerWidget {
  const CurioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTier = ref.watch(gradeTierProvider);
    final themeData = AppTheme.buildTheme(activeTier);

    return MaterialApp(
      title: 'Curio Academy',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const SplashScreen(),
    );
  }
}
