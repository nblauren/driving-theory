import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _PrivacyPolicyBody(),
      ),
    );
  }
}

class _PrivacyPolicyBody extends StatelessWidget {
  const _PrivacyPolicyBody();

  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Privacy Policy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // TODO: Replace with actual date before publishing
        Text('Last updated: [insert current date]', style: bodyStyle?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Text(
          'This app ("Driving Theory Trainer") is operated as a personal project. '
          'The following describes how your data is handled.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Data We Collect', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          '• Your learning progress: which questions you have answered, your correct '
          'and incorrect counts, and your spaced repetition status. This data is stored '
          'locally on your device using a SQLite database.\n\n'
          '• If you choose to sign in with Google or Apple, your progress data is '
          'additionally synced to Firebase Firestore, a cloud database operated by Google, '
          'to allow access across multiple devices. This sync is optional — the app works '
          'fully without signing in.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Data We Do Not Collect', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          '• We do not collect your name, email address, or any personal identifying '
          'information unless you sign in (in which case only your Firebase user ID is '
          'stored locally to identify your sync data).\n\n'
          '• We do not use analytics tools, advertising SDKs, or tracking of any kind.\n\n'
          '• We do not sell, share, or transfer your data to any third party.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Data Storage and Security', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          '• Local data is stored on your device and is not accessible to us.\n\n'
          '• If you use cloud sync, your data is stored in Firebase Firestore in the EU '
          '(europe-west region) and is protected by Google\'s security infrastructure.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Your Rights (GDPR)', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'If you are located in the European Union, you have the right to access, correct, '
          'or delete your personal data at any time. To delete your data, you can sign out '
          'and delete your account from the settings screen, which will remove your synced '
          'data from Firestore. Local data can be cleared by uninstalling the app.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Contact', style: headingStyle),
        const SizedBox(height: 8),
        // TODO: Replace with actual contact email before publishing
        Text(
          'For any questions about this privacy policy, contact: [your email address]',
          style: bodyStyle,
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
