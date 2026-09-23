import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/local_storage_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline storage service
  await LocalStorageService.instance.init();

  // Initialize AdMob service with Families Policy settings
  await AdService().initialize();

  // Lock orientation to preferred kid-safe modes (portrait / responsive tablet)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    const ProviderScope(
      child: CurioApp(),
    ),
  );
}
