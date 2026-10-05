import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 記録と写真の扱いの説明。
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = [
      (l10n.privacyLocalTitle, l10n.privacyLocalBody),
      (l10n.privacyOcrTitle, l10n.privacyOcrBody),
      (l10n.privacyBackupTitle, l10n.privacyBackupBody),
      (l10n.privacyAdsTitle, l10n.privacyAdsBody),
      (l10n.privacyMedicalTitle, l10n.medicalDisclaimer),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: [
          for (final (title, body) in sections) ...[
            Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}
