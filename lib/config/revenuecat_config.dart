/// RevenueCat configuration.
///
/// Dashboard: https://app.revenuecat.com
/// - Product: `snapmed_remove_ads`（非消耗型・買い切りで広告を非表示）
/// - Product: `snapmed_remove_ads_monthly`（自動更新の月額・広告を非表示）
/// - Entitlement `pro` attached to both products
/// - Offering `default` に lifetime と monthly のパッケージとして登録する
class RevenueCatConfig {
  /// 未設定の間は購入ボタンだけ無効になり、アプリはそのまま使える。
  static const String appleApiKey = '';

  /// Entitlement identifier that removes ads.
  static const String proEntitlementId = 'pro';

  static const String productId = 'snapmed_remove_ads';

  static const String monthlyProductId = 'snapmed_remove_ads_monthly';

  static bool get isConfigured => appleApiKey.isNotEmpty;
}
