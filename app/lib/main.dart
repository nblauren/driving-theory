import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/consent_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/consent_screen.dart';
import 'screens/main_shell.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Already initialized (e.g. hot restart)
  }

  // Enable Firestore offline persistence explicitly
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Initialize notifications
  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const DrivingTheoryApp(),
  ));
}

class DrivingTheoryApp extends ConsumerWidget {
  const DrivingTheoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasConsent = ref.watch(consentAcceptedProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Driving Theory',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: hasConsent ? const MainShell() : const ConsentScreen(),
    );
  }
}
