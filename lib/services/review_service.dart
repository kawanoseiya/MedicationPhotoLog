import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../widgets/review_dialog.dart';

/// App Store レビュー依頼。
///
/// 記録の保存（価値を感じた直後）を数え、しきい値に達したら「応援」ワンクッション
/// （[ReviewDialog]）を挟んでから OS 標準のレビュー依頼を出す。表示可否は最終的に OS が決める。
///
/// 「あとで」も1回の依頼として数え、次は90日以上あけてから出す。合計3回までで打ち止め。
class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  static const _kActionCount = 'review_action_count';
  static const _kRequestCount = 'review_request_count';
  static const _kLastRequestAt = 'review_last_request_at';

  /// 処方ごとの記録を何回か残してもらってから依頼する。
  static const int _threshold = 3;
  static const int _maxRequests = 3;
  static const Duration _minInterval = Duration(days: 90);

  /// 保存が1回終わるごとに呼ぶ。
  ///
  /// 保存後に画面を閉じる場合があるため、その画面の context ではなく
  /// root の [navigator] を渡す。
  Future<void> recordMeaningfulAction({
    required NavigatorState navigator,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requests = prefs.getInt(_kRequestCount) ?? 0;
      if (requests >= _maxRequests) return;

      final count = (prefs.getInt(_kActionCount) ?? 0) + 1;
      await prefs.setInt(_kActionCount, count);
      if (count < _threshold) return;

      final lastRaw = prefs.getString(_kLastRequestAt);
      final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
      if (last != null && DateTime.now().difference(last) < _minInterval) {
        return;
      }

      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;
      if (!navigator.mounted) return;

      final accepted = await ReviewDialog.show(navigator.context);
      await prefs.setInt(_kRequestCount, requests + 1);
      await prefs.setInt(_kActionCount, 0);
      await prefs.setString(_kLastRequestAt, DateTime.now().toIso8601String());
      if (!accepted) return;
      await review.requestReview();
    } on Exception catch (e) {
      debugPrint('レビュー依頼に失敗しました: $e');
    }
  }

  /// 設定の「評価する」から。OS の年3回制限がある `requestReview` ではなく、
  /// App Store のレビュー記入ページを直接開く。
  Future<void> openWriteReview() async {
    const id = AppConfig.appStoreId;
    if (id.isEmpty) return;
    final url = Uri.parse(
      'https://apps.apple.com/app/id$id?action=write-review',
    );
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) await InAppReview.instance.openStoreListing(appStoreId: id);
    } on Exception catch (e) {
      debugPrint('レビューページを開けませんでした: $e');
    }
  }
}
