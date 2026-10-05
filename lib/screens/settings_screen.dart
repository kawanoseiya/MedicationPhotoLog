import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/app_state.dart';
import '../services/backup_service.dart';
import '../services/purchase_service.dart';
import '../services/review_service.dart';
import '../theme.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/ui.dart';
import 'family_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  bool _restoring = false;

  /// 書き出し・復元の処理中。
  bool _backupBusy = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    });
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _restorePurchase() async {
    setState(() => _restoring = true);
    final outcome = await PurchaseService.instance.restore();
    if (!mounted) return;
    setState(() => _restoring = false);
    _snack(purchaseOutcomeMessage(AppLocalizations.of(context), outcome));
  }

  Future<void> _exportBackup(Rect? origin) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _backupBusy = true);
    try {
      final path = await BackupService.export();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'application/zip')],
          sharePositionOrigin: origin,
        ),
      );
    } on Exception catch (e) {
      debugPrint('書き出しに失敗しました: $e');
      _snack(l10n.backupFailed);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context);
    final BackupContents contents;
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
      if (files.isEmpty) return;
      final path = files.first.path;
      if (path == null) throw const FormatException('no path');
      setState(() => _backupBusy = true);
      contents = await BackupService.read(path);
    } on Exception catch (e) {
      debugPrint('バックアップを読めませんでした: $e');
      if (mounted) setState(() => _backupBusy = false);
      _snack(l10n.restoreUnreadable);
      return;
    }
    if (!mounted) return;
    setState(() => _backupBusy = false);
    final ok = await showConfirm(
      context,
      title: l10n.restoreConfirmTitle,
      message: l10n.restoreConfirmBody(
        contents.persons.length,
        contents.records.length,
      ),
      confirmLabel: l10n.restoreAction,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _backupBusy = true);
    try {
      await BackupService.restore(contents);
      await AppState.instance.reloadAll();
      _snack(l10n.restoreDone);
    } on Exception catch (e) {
      debugPrint('復元に失敗しました: $e');
      _snack(l10n.backupFailed);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Widget _spinner() => const SizedBox(
    width: 24,
    height: 24,
    child: CircularProgressIndicator(strokeWidth: 3),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final state = AppState.instance;
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              Group(
                header: l10n.sectionFamily,
                footer: l10n.familyNote,
                children: [
                  GroupRow(
                    icon: Icons.group_rounded,
                    title: l10n.manageFamily,
                    value: '${state.persons.length}',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FamilyScreen()),
                    ),
                  ),
                ],
              ),
              Group(
                header: l10n.sectionPurchase,
                children: [
                  if (state.isPro)
                    GroupRow(
                      icon: Icons.verified_rounded,
                      iconColor: AppColors.success,
                      title: l10n.purchased,
                      subtitle: l10n.purchasedNote,
                    )
                  else
                    GroupRow(
                      icon: Icons.block_rounded,
                      title: l10n.removeAds,
                      subtitle: l10n.removeAdsNote,
                      onTap: () => showPaywall(context, source: 'settings'),
                    ),
                  GroupRow(
                    icon: Icons.restore_rounded,
                    title: l10n.restorePurchase,
                    trailing: _restoring ? _spinner() : null,
                    onTap: _restoring ? null : _restorePurchase,
                  ),
                  if (AdService.instance.privacyOptionsRequired && !state.isPro)
                    GroupRow(
                      icon: Icons.tune_rounded,
                      title: l10n.adPrivacyOptions,
                      onTap: AdService.instance.showPrivacyOptions,
                    ),
                ],
              ),
              Group(
                header: l10n.sectionLanguage,
                children: [
                  for (final o in LanguageOption.values)
                    GroupRow(
                      title: switch (o) {
                        LanguageOption.system => l10n.languageSystem,
                        LanguageOption.ja => '日本語',
                        LanguageOption.en => 'English',
                      },
                      selected: state.language == o,
                      onTap: () => state.setLanguage(o),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.sectionTextSize,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PillSegmented<TextSizeOption>(
                  values: TextSizeOption.values,
                  selected: state.textSize,
                  label: (o) => switch (o) {
                    TextSizeOption.standard => l10n.textStandard,
                    TextSizeOption.large => l10n.textLarge,
                    TextSizeOption.extraLarge => l10n.textExtraLarge,
                  },
                  onChanged: state.setTextSize,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                child: Text(
                  l10n.textSizeNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Group(
                header: l10n.sectionBackup,
                footer: l10n.backupNote,
                children: [
                  Builder(
                    builder: (context) => GroupRow(
                      icon: Icons.ios_share_rounded,
                      title: l10n.exportBackup,
                      subtitle: l10n.exportBackupNote,
                      trailing: _backupBusy ? _spinner() : null,
                      onTap: _backupBusy
                          ? null
                          : () {
                              final box =
                                  context.findRenderObject() as RenderBox?;
                              _exportBackup(
                                box == null
                                    ? null
                                    : box.localToGlobal(Offset.zero) & box.size,
                              );
                            },
                    ),
                  ),
                  GroupRow(
                    icon: Icons.settings_backup_restore_rounded,
                    title: l10n.restoreBackup,
                    subtitle: l10n.restoreBackupNote,
                    onTap: _backupBusy ? null : _restoreBackup,
                  ),
                ],
              ),
              Group(
                header: l10n.sectionAbout,
                footer: l10n.medicalDisclaimer,
                children: [
                  GroupRow(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyTitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                    ),
                  ),
                  if (AppConfig.appStoreId.isNotEmpty)
                    GroupRow(
                      icon: Icons.star_outline_rounded,
                      title: l10n.rateApp,
                      onTap: ReviewService.instance.openWriteReview,
                    ),
                  GroupRow(
                    icon: Icons.info_outline_rounded,
                    title: l10n.version,
                    value: _version,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
