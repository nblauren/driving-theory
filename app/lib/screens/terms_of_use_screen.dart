import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Use')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _TermsOfUseBody(),
      ),
    );
  }
}

class _TermsOfUseBody extends StatelessWidget {
  const _TermsOfUseBody();

  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Terms of Use', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // TODO: Replace with actual date before publishing
        Text('Last updated: [insert current date]', style: bodyStyle?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Text('By using this app you agree to the following terms.', style: bodyStyle),
        const SizedBox(height: 24),
        Text('Use of the App', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'This app is provided for personal educational use to help you prepare for the '
          'German driving theory examination. It is not affiliated with or endorsed by '
          'TÜV, DEKRA, or any official examination body.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('No Guarantee of Exam Success', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'This app is a study aid only. We make no guarantee that using this app will '
          'result in passing the official theory examination.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Accuracy of Content', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'While we strive to keep question content accurate and up to date, we cannot '
          'guarantee that all questions reflect the current official TÜV/DEKRA catalogue '
          'at all times. Always verify with your driving school.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Limitation of Liability', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'This app is provided as-is without warranty of any kind. We are not liable for '
          'any damages arising from use of the app.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Changes to These Terms', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'We may update these terms at any time. Continued use of the app after changes '
          'constitutes acceptance of the new terms.',
          style: bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('Contact', style: headingStyle),
        const SizedBox(height: 8),
        // TODO: Replace with actual contact email before publishing
        Text(
          'For any questions, contact: [your email address]',
          style: bodyStyle,
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
