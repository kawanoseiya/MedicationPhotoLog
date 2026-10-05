import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob の広告ユニット ID。
///
/// アプリ ID は Info.plist の `GADApplicationIdentifier`（現在は Google のテスト用 ID。
/// AdMob でアプリを作成したら差し替える）。
/// 開発ビルドでは Google 公式のテスト ID を使い、本物の広告を出したり押したりしない。
/// 本番 ID が空の間、リリースビルドでは広告を出さない。
class AdIds {
  AdIds._();

  /// 本番のバナー ID（iOS）。
  static const String _prodBanner = '';

  static const String _testBanner = 'ca-app-pub-3940256099942544/2934735716';

  static bool get bannerConfigured =>
      kDebugMode || (Platform.isIOS && _prodBanner.isNotEmpty);

  static String get banner =>
      !kDebugMode && _prodBanner.isNotEmpty ? _prodBanner : _testBanner;
}
