import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

import '../config/ad_ids.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/app_state.dart';
import '../theme.dart';
import 'paywall_sheet.dart';

/// バナー広告。既定は標準サイズ（320×50）。
///
/// 購入済み・準備前・読み込み失敗の間は何も表示しないので、常に置いておける。
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({
    super.key,
    this.framed = true,
    this.size = AdSize.banner,
  });

  /// 広告の大きさ。
  final AdSize size;

  /// 画面下部に置くときの上の区切り線と白い背景。
  final bool framed;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;
  int _retries = 0;
  Timer? _retryTimer;

  final _listenable = Listenable.merge([AppState.instance, AdService.instance]);

  Future<void> _load() async {
    _requested = true;
    _ad?.dispose();
    _ad = null;
    _loaded = false;
    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: widget.size,
      request: AdService.request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _ad = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('バナーを読み込めませんでした: $error');
          ad.dispose();
          // 在庫切れや一時的な通信エラーは数回だけ間をあけて再試行する。
          if (_retries < 3) {
            _retries++;
            _retryTimer?.cancel();
            _retryTimer = Timer(const Duration(seconds: 20), () {
              if (mounted) _load();
            });
          }
        },
      ),
    );
    await ad.load();
  }

  void _drop() {
    _ad?.dispose();
    _ad = null;
    _loaded = false;
    _requested = false;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _listenable,
      builder: (context, _) {
        if (!AdService.instance.canShow) {
          _drop();
          return const SizedBox.shrink();
        }
        if (!_requested) _load();
        final ad = _ad;
        if (!_loaded || ad == null) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        return DecoratedBox(
          decoration: widget.framed
              ? const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.hairline)),
                )
              : const BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showPaywall(context, source: 'ad'),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 40)),
                  child: Text(
                    l10n.removeAds,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                width: ad.size.width.toDouble(),
                height: ad.size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            ],
          ),
        );
      },
    );
  }
}
