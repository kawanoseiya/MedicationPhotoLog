import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/purchase_service.dart';
import '../theme.dart';

/// 広告を消す（買い切り・月額）の案内。購入できたら true を返す。
///
/// [source] は開いた場所（settings / ad）。
Future<bool> showPaywall(BuildContext context, {required String source}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _PaywallSheet(source: source),
  );
  return result == true;
}

/// 購入結果を短い文で知らせる。
String purchaseOutcomeMessage(AppLocalizations l10n, PurchaseOutcome outcome) =>
    switch (outcome) {
      PurchaseOutcome.success => l10n.purchaseSuccess,
      PurchaseOutcome.cancelled => l10n.purchaseCancelled,
      PurchaseOutcome.notConfigured ||
      PurchaseOutcome.unavailable => l10n.purchaseUnavailable,
      PurchaseOutcome.nothingToRestore => l10n.restoreNothing,
      PurchaseOutcome.failed => l10n.purchaseFailed,
    };

class _PaywallSheet extends StatefulWidget {
  const _PaywallSheet({required this.source});

  final String source;

  @override
  State<_PaywallSheet> createState() => _PaywallSheetState();
}

const _termsUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const _privacyUrl = 'https://fillapps.com/privacy/';

class _PaywallSheetState extends State<_PaywallSheet> {
  /// 処理中のボタン。null は何もしていない。
  Object? _busyWith;
  String? _message;

  bool get _busy => _busyWith != null;

  @override
  void initState() {
    super.initState();
    PurchaseService.instance.refresh().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _run(
    Object key,
    Future<PurchaseOutcome> Function() action,
  ) async {
    setState(() {
      _busyWith = key;
      _message = null;
    });
    final outcome = await action();
    if (!mounted) return;
    if (outcome == PurchaseOutcome.success) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busyWith = null;
      _message = purchaseOutcomeMessage(AppLocalizations.of(context), outcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = PurchaseService.instance;
    final lifetimePrice = service.priceString(PurchasePlan.lifetime);
    final monthlyPrice = service.priceString(PurchasePlan.monthly);
    final small = Theme.of(context).textTheme.bodyMedium;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.block_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            l10n.paywallTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(l10n.paywallBody, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          _bullet(context, l10n.paywallPointNoAds),
          _bullet(context, l10n.paywallPointFree),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy
                ? null
                : () => _run(
                    PurchasePlan.lifetime,
                    () => _buy(PurchasePlan.lifetime),
                  ),
            child: _label(
              PurchasePlan.lifetime,
              lifetimePrice == null
                  ? l10n.buyLifetime
                  : l10n.buyLifetimeWithPrice(lifetimePrice),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              l10n.paywallLifetimeNote,
              textAlign: TextAlign.center,
              style: small,
            ),
          ),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(
                    PurchasePlan.monthly,
                    () => _buy(PurchasePlan.monthly),
                  ),
            child: _label(
              PurchasePlan.monthly,
              monthlyPrice == null
                  ? l10n.buyMonthly
                  : l10n.buyMonthlyWithPrice(monthlyPrice),
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.subscriptionTerms, style: small),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => _open(_termsUrl),
                child: Text(l10n.termsOfUse),
              ),
              TextButton(
                onPressed: () => _open(_privacyUrl),
                child: Text(l10n.privacyPolicy),
              ),
            ],
          ),
          TextButton(
            onPressed: _busy ? null : () => _run(_restoreKey, service.restore),
            child: _label(_restoreKey, l10n.restorePurchase),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  static const _restoreKey = 'restore';

  Future<PurchaseOutcome> _buy(PurchasePlan plan) =>
      PurchaseService.instance.purchase(plan);

  /// 処理中のボタンだけ回転表示にする。
  Widget _label(Object key, String text) => _busyWith == key
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        )
      : Text(text, textAlign: TextAlign.center);

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  Widget _bullet(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(Icons.check, color: AppColors.success, size: 22),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );
}
