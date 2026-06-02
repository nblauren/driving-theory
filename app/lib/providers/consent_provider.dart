import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../consent_config.dart';
import 'language_provider.dart';

const _keyConsentVersion = 'consent_accepted_version';
const _keyConsentTimestamp = 'consent_accepted_at';

/// Whether the user has accepted the current consent version.
final consentAcceptedProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final acceptedVersion = prefs.getInt(_keyConsentVersion) ?? 0;
  return acceptedVersion >= currentConsentVersion;
});

/// Records that the user accepted the current consent version.
Future<void> acceptConsent(SharedPreferences prefs) async {
  await prefs.setInt(_keyConsentVersion, currentConsentVersion);
  await prefs.setString(_keyConsentTimestamp, DateTime.now().toIso8601String());
}

/// Resets consent state so the gate reappears on next launch.
Future<void> resetConsent(SharedPreferences prefs) async {
  await prefs.remove(_keyConsentVersion);
  await prefs.remove(_keyConsentTimestamp);
}
