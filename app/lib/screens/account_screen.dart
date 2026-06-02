import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/consent_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'auth_screen.dart';
import 'consent_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_use_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsSection(),
            const Divider(height: 32),
            authState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (user) {
                if (user == null) {
                  return _SignedOutView();
                }
                return _SignedInView(
                  displayName: user.displayName ?? 'User',
                  email: user.email ?? '',
                  photoUrl: user.photoURL,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(selectedLanguageProvider);
    final ttsEnabled = ref.watch(ttsEnabledProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPEARANCE',
            style: AppTextStyles.label(
              color: isDark
                  ? AppColors.textTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
          const SizedBox(height: 12),
          _ThemeModeToggle(
            themeMode: themeMode,
            onChanged: (mode) =>
                ref.read(themeModeProvider.notifier).setThemeMode(mode),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          Text(
            'APP SETTINGS',
            style: AppTextStyles.label(
              color: isDark
                  ? AppColors.textTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: const Text('Question Language'),
            trailing: SegmentedButton<AppLanguage>(
              segments: const [
                ButtonSegment(value: AppLanguage.en, label: Text('EN')),
                ButtonSegment(value: AppLanguage.de, label: Text('DE')),
              ],
              selected: {language},
              onSelectionChanged: (selected) {
                ref
                    .read(selectedLanguageProvider.notifier)
                    .setLanguage(selected.first);
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.volume_up),
            title: const Text('Text-to-Speech'),
            subtitle: const Text('Read questions aloud'),
            value: ttsEnabled,
            onChanged: (_) =>
                ref.read(ttsEnabledProvider.notifier).toggle(),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Use'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
            ),
          ),
          _DeleteMyDataTile(),
        ],
      ),
    );
  }
}

class _ThemeModeToggle extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;
  final bool isDark;

  const _ThemeModeToggle({
    required this.themeMode,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark
        ? AppColors.backgroundCard
        : AppColors.lightBackgroundCard;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment('System', ThemeMode.system, textSecondary),
          _buildSegment('Light', ThemeMode.light, textSecondary),
          _buildSegment('Dark', ThemeMode.dark, textSecondary),
        ],
      ),
    );
  }

  Widget _buildSegment(String label, ThemeMode mode, Color inactiveColor) {
    final isActive = themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        child: Container(
          height: 40,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accentPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.button(
              color: isActive ? Colors.white : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Not signed in',
              style: AppTextStyles.heading2(
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to sync progress across devices.',
              style: AppTextStyles.bodySmall(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInView extends ConsumerStatefulWidget {
  final String displayName;
  final String email;
  final String? photoUrl;

  const _SignedInView({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  ConsumerState<_SignedInView> createState() => _SignedInViewState();
}

class _SignedInViewState extends ConsumerState<_SignedInView> {
  bool _syncing = false;

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    try {
      final syncService = ref.read(firebaseSyncServiceProvider);
      final db = ref.read(databaseProvider);
      final merged = await syncService.pullAndMerge(db);
      await syncService.pushAllProgress(db);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Synced — $merged updates from cloud')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 40,
            backgroundColor: isDark ? AppColors.backgroundElevated : AppColors.lightBackgroundElevated,
            backgroundImage:
                widget.photoUrl != null ? NetworkImage(widget.photoUrl!) : null,
            child: widget.photoUrl == null
                ? Text(
                    widget.displayName.isNotEmpty
                        ? widget.displayName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.statLarge(
                      color: AppColors.accentLight,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            widget.displayName,
            style: AppTextStyles.heading1(
              color: isDark
                  ? AppColors.textPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.email,
            style: AppTextStyles.bodySmall(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Sync Now'),
            subtitle: const Text('Pull & push progress'),
            trailing: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _syncing ? null : _syncNow,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}

class _DeleteMyDataTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.delete_forever, color: AppColors.error),
      title: const Text(
        'Delete My Data',
        style: TextStyle(color: AppColors.error),
      ),
      onTap: () => _confirmDelete(context, ref),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete My Data'),
        content: const Text(
          'This will delete all your learning progress, sign you out, '
          'and reset the app. This cannot be undone.\n\n'
          'The question database will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final db = ref.read(databaseProvider);
    final authService = ref.read(authServiceProvider);
    final syncService = ref.read(firebaseSyncServiceProvider);
    final prefs = ref.read(sharedPreferencesProvider);

    if (syncService.isLoggedIn) {
      try {
        final uid = authService.currentUser?.uid;
        if (uid != null) {
          final collection = FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('progress');
          final docs = await collection.get();
          final batch = FirebaseFirestore.instance.batch();
          for (final doc in docs.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      } catch (_) {}
    }

    await db.delete(db.questionProgress).go();

    try {
      await authService.signOut();
    } catch (_) {}

    await resetConsent(prefs);

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ConsentScreen()),
      (route) => false,
    );
  }
}
