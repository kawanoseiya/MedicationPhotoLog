import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

import '../config/ad_ids.dart';
import 'app_state.dart';

/// 広告（AdMob のバナー）。
///
/// - 購入済み（広告非表示）の人には SDK を初期化しない
/// - トラッキング許可（ATT）は求めず、すべて非パーソナライズ広告で取得する
/// - EEA などで同意が必要な場合は、先に UMP の同意フォームを出す
/// - 薬の記録・メモ・写真を広告 SDK に渡すことはない
class AdService extends ChangeNotifier {
  AdService._();

  static final AdService instance = AdService._();

  bool _ready = false;
  bool _initializing = false;
  bool privacyOptionsRequired = false;

  /// 広告を出してよい状態か（購入済みでなく、ID が設定済みで、SDK の準備ができている）。
  bool get canShow =>
      _ready && !AppState.instance.isPro && AdIds.bannerConfigured;

  /// 非パーソナライズ広告のリクエスト。
  static const request = AdRequest(nonPersonalizedAds: true);

  Future<void> init() async {
    if (_ready || _initializing) return;
    if (AppState.instance.isPro || !AdIds.bannerConfigured) return;
    _initializing = true;
    try {
      await _gatherConsent();
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      _ready = true;
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('広告の初期化に失敗しました: $e');
    } finally {
      _initializing = false;
    }
  }

  Future<void> _gatherConsent() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (error != null) debugPrint('同意フォームのエラー: ${error.message}');
          if (!completer.isCompleted) completer.complete();
        });
      },
      (FormError error) {
        debugPrint('同意情報を更新できませんでした: ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;
    privacyOptionsRequired =
        await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  /// EEA などの利用者が広告の同意を見直すためのフォーム。
  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (error != null) debugPrint('プライバシー設定フォームのエラー: ${error.message}');
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }
}
