# 開発メモ

## 構成

| 場所 | 内容 |
|---|---|
| `ios/Runner/AppDelegate.swift` | `MedScanPlugin`（チャンネル `snapmed/scanner`）: `scan` は VNDocumentCameraViewController で撮って長辺2400pxの JPEG を一時フォルダへ。`recognize` は Vision（accurate・ja-JP/en-US）で読み、同じ高さのまとまりを1行として上から順に返す |
| `lib/services/scan_service.dart` | 撮影（書類スキャナが使えない端末はカメラ1枚）・写真ライブラリ・OCR の呼び出し |
| `lib/logic/med_parser.dart` | OCR の行 → 処方日（和暦・西暦・米国式・月名。処方日/調剤日/Date Filled の見出しを優先、期限・生年月日・次回予約は除外）、薬名（カタカナ名＋剤形 or 含量、英語は名前＋含量。用法の後ろは切る）、医療機関、薬局 |
| `lib/data/` | sqflite（persons / records）と写真フォルダ（書類フォルダの `photos/`、記録にはファイル名だけ持つ） |
| `lib/models/med_record.dart` | OCR 全文はページごとに `\f` で区切り、写真と同じ順 |
| `lib/services/backup_service.dart` | zip（`backup.json`＋`photos/`）の書き出し・検証・復元 |
| `lib/screens/` | ホーム・履歴・確認/編集・詳細・写真拡大・設定・家族・プライバシー |

確認画面では、利用者が触った欄・消した薬名は、ページを足して読み直しても上書きしない。

## 確認

```sh
flutter test                                  # 解析ロジックとモデル
python3 tools/samples/make_samples.py         # 架空の薬剤情報提供書・米国ラベルの見本画像
flutter build ios --simulator --debug --dart-define=DEMO=true \
  --dart-define=DEMO_ENTRY=$PWD/tools/samples/out/jp_sheet.jpg
```

- `DEMO_ENTRY` で起動するとその画像で確認画面が開き、読み取った行と候補を書類フォルダの `demo_ocr.txt` に書き出す
- `DEMO=true` は見本の記録（家族2人）を入れ、広告なし扱い。`DEMO_PHOTOS=a.jpg,...` で1件目に写真、`START_TAB=1` で履歴タブ
- 2026-10-06 シミュレータ（iOS 26.2）で見本2枚とも、処方日・薬名（日本4件・米国1件）・医療機関・薬局がすべて正しく入ることを確認

アイコン: `python3 tools/icon/make_icon.py && dart run flutter_launcher_icons`

## 未確認・残り作業

- [ ] **実機での読み取り精度**（書類スキャナはシミュレータで動かない）。日本の薬剤情報提供書・薬袋、海外のラベル・箱・処方書類で、項目ごとの一致率を記録する。光沢・曲面ラベル・縦書き・手書きは要注意
- [ ] 同名アプリ・商標の確認（英語名 SnapMed Log は仮称）
- [ ] ASC アプリ作成、メタデータ ja/en、スクリーンショット
- [ ] AdMob のアプリとバナーユニット作成 → `Info.plist` の `GADApplicationIdentifier`（現在 Google のテスト ID）と `lib/config/ad_ids.dart` の `_prodBanner`
- [ ] RevenueCat プロジェクト・公開キー（`lib/config/revenuecat_config.dart`、空の間は購入ボタンが無効）、In-App Purchase Key、ASC の課金商品（ja/en ローカライズ）
- [ ] App Store ID を `lib/config/app_config.dart` に設定（設定画面の「評価する」）
- [ ] App のプライバシー回答（AdMob・購入履歴）。医療機器の申告は「いいえ」（記録のみで判断をしない）
