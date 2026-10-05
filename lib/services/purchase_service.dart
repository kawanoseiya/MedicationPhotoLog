import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/revenuecat_config.dart';
import 'app_state.dart';

enum PurchaseOutcome {
  success,
  cancelled,
  notConfigured,
  unavailable,
  failed,
  nothingToRestore,
}

enum PurchasePlan { lifetime, monthly }

/// 広告を消す購入（RevenueCat）。買い切りと月額のどちらでも entitlement `pro` が付く。
///
/// 確認できた購入状態は [AppState] に保存し、通信できないときもその状態で記録を続けられる。
class PurchaseService {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  bool _configured = false;
  Package? _lifetime;
  Package? _monthly;

  /// 表示用の価格（取得できなければ null）。
  String? priceString(PurchasePlan plan) =>
      _packageFor(plan)?.storeProduct.priceString;

  Package? _packageFor(PurchasePlan plan) => switch (plan) {
    PurchasePlan.lifetime => _lifetime,
    PurchasePlan.monthly => _monthly,
  };

  Future<void> init() async {
    if (!RevenueCatConfig.isConfigured) return;
    try {
      await Purchases.configure(
        PurchasesConfiguration(RevenueCatConfig.appleApiKey),
      );
      _configured = true;
      Purchases.addCustomerInfoUpdateListener(_apply);
      await refresh();
    } on Exception catch (e) {
      debugPrint('RevenueCat の初期化に失敗しました: $e');
    }
  }

  Future<void> refresh() async {
    if (!_configured) return;
    try {
      _apply(await Purchases.getCustomerInfo());
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      Package? byId(String id) => current?.availablePackages
          .where((p) => p.storeProduct.identifier == id)
          .firstOrNull;
      _lifetime = current?.lifetime ?? byId(RevenueCatConfig.productId);
      _monthly = current?.monthly ?? byId(RevenueCatConfig.monthlyProductId);
    } on Exception catch (e) {
      // オフラインなど。保存済みの購入状態をそのまま使う。
      debugPrint('購入状態を確認できませんでした: $e');
    }
  }

  void _apply(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(
      RevenueCatConfig.proEntitlementId,
    );
    AppState.instance.setPro(active);
  }

  Future<PurchaseOutcome> purchase(PurchasePlan plan) async {
    if (!_configured) return PurchaseOutcome.notConfigured;
    if (_packageFor(plan) == null) await refresh();
    final package = _packageFor(plan);
    if (package == null) return PurchaseOutcome.unavailable;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _apply(result.customerInfo);
      return AppState.instance.isPro
          ? PurchaseOutcome.success
          : PurchaseOutcome.failed;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseOutcome.cancelled;
      }
      debugPrint('購入に失敗しました: $e');
      return PurchaseOutcome.failed;
    }
  }

  Future<PurchaseOutcome> restore() async {
    if (!_configured) return PurchaseOutcome.notConfigured;
    try {
      final info = await Purchases.restorePurchases();
      _apply(info);
      return AppState.instance.isPro
          ? PurchaseOutcome.success
          : PurchaseOutcome.nothingToRestore;
    } on PlatformException catch (e) {
      debugPrint('購入の復元に失敗しました: $e');
      return PurchaseOutcome.failed;
    }
  }
}
