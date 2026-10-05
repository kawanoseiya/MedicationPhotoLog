// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '撮るだけお薬手帳';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabHistory => '履歴';

  @override
  String get settings => '設定';

  @override
  String get captureButton => '撮って記録';

  @override
  String get captureCaption => '薬の説明書・薬袋を撮るだけ。複数ページも続けて撮れます';

  @override
  String get importPhotos => '写真から';

  @override
  String get manualEntry => '手入力';

  @override
  String get recentRecords => '最近の記録';

  @override
  String showAllRecords(int count) {
    return '$count件の記録をすべて見る';
  }

  @override
  String get homeEmpty => 'まだ記録がありません。「撮って記録」から、薬の説明書（薬剤情報提供書）や薬袋を撮ってみましょう';

  @override
  String get whoseRecords => '誰の記録を見ますか';

  @override
  String get manageFamily => '家族の管理';

  @override
  String switchPersonLabel(String name) {
    return '$nameの記録を表示中。押すと切り替えます';
  }

  @override
  String get newRecordTitle => '内容を確認して保存';

  @override
  String get editRecordTitle => '記録を編集';

  @override
  String get readingText => '端末内で文字を読み取っています…';

  @override
  String get checkSuggestions => '写真から読み取った内容を入れました。写真と見比べて、違うところは直してください';

  @override
  String get blankIsOk => 'わからない項目は空欄のままで保存できます';

  @override
  String get manualHint => 'わかる項目だけ入力してください。空欄でも保存できます。写真もあとから追加できます';

  @override
  String get fieldPerson => '対象者';

  @override
  String get fieldDate => '処方日';

  @override
  String get fieldMedicines => '薬の名前';

  @override
  String get fieldHospital => '医療機関';

  @override
  String get fieldPharmacy => '薬局';

  @override
  String get fieldMemo => 'メモ';

  @override
  String get fieldOcrText => '写真から読み取った文字';

  @override
  String get dateNotSet => '未入力（押して選ぶ）';

  @override
  String get dateNotSetShort => '未入力';

  @override
  String get notEntered => '未入力';

  @override
  String get clearDate => '日付を消す';

  @override
  String get medicineHint => '薬の名前';

  @override
  String get addMedicine => '薬を追加';

  @override
  String get removeMedicine => 'この薬を消す';

  @override
  String get addPage => 'ページを追加';

  @override
  String get addPhoto => '写真を追加';

  @override
  String get addByCamera => '撮影して追加';

  @override
  String get addFromLibrary => '写真から選ぶ';

  @override
  String pageNumber(int number) {
    return '$numberページ';
  }

  @override
  String pageOf(int current, int total) {
    return '$current / $total';
  }

  @override
  String get removePageTitle => 'このページを外しますか';

  @override
  String get removePageBody => '写真と、そのページから読み取った文字を記録から外します';

  @override
  String get remove => '外す';

  @override
  String get save => '保存';

  @override
  String get saved => '保存しました';

  @override
  String get saveFailed => '保存できませんでした。もう一度お試しください';

  @override
  String get discardTitle => 'この記録を破棄しますか';

  @override
  String get discardBody => '写真と入力した内容は保存されません';

  @override
  String get discard => '破棄';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get delete => '削除';

  @override
  String get deleted => '削除しました';

  @override
  String get edit => '編集';

  @override
  String get detailTitle => '記録の詳細';

  @override
  String get recordNotFound => 'この記録は見つかりませんでした';

  @override
  String get tapToZoom => '写真を押すと拡大できます';

  @override
  String zoomPhoto(int number) {
    return '$number枚目の写真を拡大';
  }

  @override
  String get showOcrText => '全文を表示';

  @override
  String get ocrTextNote => '検索に使います。読み間違いを含むことがあります';

  @override
  String registeredAt(String date) {
    return '登録日 $date';
  }

  @override
  String get deleteRecordTitle => 'この記録を削除';

  @override
  String get deleteRecordBody => '記録と写真をこの端末から削除します。元には戻せません';

  @override
  String noDateAdded(String date) {
    return '処方日なし（登録 $date）';
  }

  @override
  String get noMedicineNames => '薬の名前は未入力';

  @override
  String get listSeparator => '、';

  @override
  String get searchHint => '薬名・医療機関・薬局で検索';

  @override
  String get clearSearch => '検索を消す';

  @override
  String get noSearchResults => '見つかりませんでした。写真から読み取った文字も検索の対象です';

  @override
  String searchResultCount(int count) {
    return '$count件';
  }

  @override
  String get sectionFamily => '家族';

  @override
  String get familyNote => '親や子どもなど、人ごとに記録を分けられます';

  @override
  String get familyEditNote => '名前を押すと、変更・削除ができます';

  @override
  String get addPerson => '家族を追加';

  @override
  String get renamePerson => '名前を変更';

  @override
  String get deletePerson => '削除';

  @override
  String deletePersonTitle(String name) {
    return '$nameを削除しますか';
  }

  @override
  String deletePersonBody(int count) {
    return '$count件の記録と写真も削除します。元には戻せません';
  }

  @override
  String get personNameHint => '名前（例: 母）';

  @override
  String get currentlyShown => '表示中';

  @override
  String get sectionPurchase => '購入';

  @override
  String get sectionLanguage => '言語';

  @override
  String get languageSystem => 'iPhoneの設定に合わせる';

  @override
  String get sectionBackup => 'バックアップ';

  @override
  String get backupNote =>
      'バックアップのファイルは iCloud Drive など、このiPhone以外の場所に保存してください。機種変更のときは、新しいiPhoneで復元します';

  @override
  String get exportBackup => 'バックアップを書き出す';

  @override
  String get exportBackupNote => 'すべての記録と写真を1つのファイルに';

  @override
  String get restoreBackup => 'バックアップから復元';

  @override
  String get restoreBackupNote => 'この端末の記録を置き換えます';

  @override
  String get restoreConfirmTitle => '記録を置き換えますか';

  @override
  String restoreConfirmBody(int persons, int records) {
    return 'この端末の記録を、バックアップの内容（$persons人・$records件）に置き換えます。バックアップに無い記録は削除されます';
  }

  @override
  String get restoreAction => '置き換える';

  @override
  String get restoreDone => 'バックアップから復元しました';

  @override
  String get restoreUnreadable => 'このファイルは復元できません。このアプリで書き出したバックアップを選んでください';

  @override
  String get backupFailed => 'うまくいきませんでした。記録は変更されていません';

  @override
  String get sectionAbout => 'このアプリについて';

  @override
  String get privacyTitle => 'プライバシーとデータ';

  @override
  String get privacyLocalTitle => '記録はこの端末の中だけに';

  @override
  String get privacyLocalBody =>
      'アカウント登録は不要です。記録と写真はこのiPhoneのアプリ内にだけ保存され、開発者のサーバーへ送られることはありません。アプリを削除すると記録も消えるので、残したいときはバックアップを書き出してください';

  @override
  String get privacyOcrTitle => '文字の読み取りも端末内で';

  @override
  String get privacyOcrBody =>
      '写真の文字の読み取りは、iPhoneに組み込まれた機能で端末内で行います。読み取りのために写真や文字を外部へ送ることはありません';

  @override
  String get privacyBackupTitle => 'バックアップ';

  @override
  String get privacyBackupBody =>
      'バックアップは、すべての記録と写真を含む1つのファイルです。暗号化されていないので、保存先・送り先に気をつけてください';

  @override
  String get privacyAdsTitle => '広告';

  @override
  String get privacyAdsBody =>
      '無料版では Google AdMob の広告を表示します。広告はすべて非パーソナライズ広告として取得し、記録や写真を広告サービスに渡すことはありません';

  @override
  String get privacyMedicalTitle => '医療の判断について';

  @override
  String get medicalDisclaimer =>
      'このアプリは、撮影・入力した薬の情報を履歴として残すものです。飲み方の判断・飲み合わせの判定・服薬の通知は行いません。お薬についてわからないことは、医師・薬剤師に相談してください';

  @override
  String get removeAdsNote => '買い切りまたは月額で広告を非表示にします';

  @override
  String get paywallBody => '記録は無料で、件数の制限なく使えます。買い切りか月額プランで、広告を表示しないようにできます';

  @override
  String get textSizeNote => 'iPhoneの文字サイズ設定に上乗せされます';

  @override
  String get adPrivacyOptions => '広告のプライバシー設定';

  @override
  String get buyLifetime => '買い切りで広告を消す';

  @override
  String buyLifetimeWithPrice(String price) {
    return '買い切り $price';
  }

  @override
  String get buyMonthly => '月額プランで広告を消す';

  @override
  String buyMonthlyWithPrice(String price) {
    return '月額 $price';
  }

  @override
  String get paywallLifetimeNote => '一度の購入で、ずっと広告が表示されません';

  @override
  String get paywallPointFree => '購入しなくても、すべての機能を使えます';

  @override
  String get paywallPointNoAds => 'すべての広告が表示されなくなります';

  @override
  String get paywallTitle => '広告を消す';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get purchaseCancelled => '購入をキャンセルしました';

  @override
  String get purchased => '広告非表示（購入済み）';

  @override
  String get purchasedNote => 'ご購入ありがとうございます';

  @override
  String get purchaseFailed => '購入を完了できませんでした。記録はそのまま残っています';

  @override
  String get purchaseSuccess => 'ありがとうございます。広告を非表示にしました';

  @override
  String get purchaseUnavailable => '現在購入できません。時間をおいてお試しください';

  @override
  String get rateApp => 'このアプリを評価する';

  @override
  String get removeAds => '広告を消す';

  @override
  String get restoreNothing => '復元できる購入が見つかりませんでした';

  @override
  String get restorePurchase => '購入を復元';

  @override
  String get reviewLater => 'あとで';

  @override
  String get reviewMessage1 => 'このアプリは個人で開発しています。';

  @override
  String get reviewMessage2 =>
      'もしお役に立てていたら、レビューで応援していただけると励みになり、アプリの成長につながります。';

  @override
  String get reviewMessage3 => '（もちろん「あとで」でも大丈夫です）';

  @override
  String get reviewThankYouTitle => 'いつもご利用ありがとうございます！';

  @override
  String get subscriptionTerms =>
      '月額プランは毎月自動で更新され、更新日の24時間前までに解約しない限り Apple アカウントに請求されます。解約は設定アプリの「ご自身の名前」→「サブスクリプション」からいつでもできます';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get textExtraLarge => '特大';

  @override
  String get textLarge => '大きい';

  @override
  String get textStandard => '標準';

  @override
  String get sectionTextSize => '文字表示';

  @override
  String get version => 'バージョン';

  @override
  String get writeReview => 'レビューを書く';
}
