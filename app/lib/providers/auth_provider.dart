import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firebase_sync_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  return FirebaseSyncService();
});

/// Stream of auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Whether a Firestore sync is currently in progress.
final syncInProgressProvider = StateProvider<bool>((ref) => false);
