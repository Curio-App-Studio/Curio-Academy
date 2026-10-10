import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/local_storage_service.dart';
import 'services/ad_service.dart';
import 'services/in_app_purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline storage service
  await LocalStorageService.instance.init();

  // Initialize AdMob service with Families Policy settings
  await AdService().initialize();

  // Initialize Google Play In-App Purchase & Subscriptions
  await InAppPurchaseService.instance.initialize();

  // Lock orientation to preferred kid-safe modes (portrait / responsive tablet)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Enable full-screen immersive mode to hide Android system navigation bar
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    const ProviderScope(
      child: CurioApp(),
    ),
  );
}
