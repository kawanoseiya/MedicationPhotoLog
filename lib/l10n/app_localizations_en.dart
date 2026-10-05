// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SnapMed Log';

  @override
  String get tabHome => 'Home';

  @override
  String get tabHistory => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get captureButton => 'Snap to record';

  @override
  String get captureCaption =>
      'Photograph the medication sheet, bag or label. Several pages are fine.';

  @override
  String get importPhotos => 'From photos';

  @override
  String get manualEntry => 'Type it in';

  @override
  String get recentRecords => 'Recent records';

  @override
  String showAllRecords(int count) {
    return 'Show all $count records';
  }

  @override
  String get homeEmpty =>
      'No records yet. Tap \"Snap to record\" and photograph a medication information sheet, a pharmacy bag or a label.';

  @override
  String get whoseRecords => 'Whose records?';

  @override
  String get manageFamily => 'Family members';

  @override
  String switchPersonLabel(String name) {
    return 'Showing records for $name. Tap to switch.';
  }

  @override
  String get newRecordTitle => 'Check and save';

  @override
  String get editRecordTitle => 'Edit record';

  @override
  String get readingText => 'Reading the text on this device…';

  @override
  String get checkSuggestions =>
      'Filled in from the photo. Compare with the photo and correct anything that\'s wrong.';

  @override
  String get blankIsOk => 'You can leave anything blank and still save.';

  @override
  String get manualHint =>
      'Type in what you know. Blank fields are fine. You can also add a photo.';

  @override
  String get fieldPerson => 'Person';

  @override
  String get fieldDate => 'Prescription date';

  @override
  String get fieldMedicines => 'Medicines';

  @override
  String get fieldHospital => 'Clinic / hospital';

  @override
  String get fieldPharmacy => 'Pharmacy';

  @override
  String get fieldMemo => 'Notes';

  @override
  String get fieldOcrText => 'Text read from the photo';

  @override
  String get dateNotSet => 'Not set (tap to choose)';

  @override
  String get dateNotSetShort => 'Not set';

  @override
  String get notEntered => 'Not entered';

  @override
  String get clearDate => 'Clear date';

  @override
  String get medicineHint => 'Medicine name';

  @override
  String get addMedicine => 'Add a medicine';

  @override
  String get removeMedicine => 'Remove this medicine';

  @override
  String get addPage => 'Add page';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get addByCamera => 'Take photos';

  @override
  String get addFromLibrary => 'Choose from Photos';

  @override
  String pageNumber(int number) {
    return 'Page $number';
  }

  @override
  String pageOf(int current, int total) {
    return '$current / $total';
  }

  @override
  String get removePageTitle => 'Remove this page?';

  @override
  String get removePageBody =>
      'The photo and its text will be removed from this record.';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved.';

  @override
  String get saveFailed => 'Couldn\'t save. Please try again.';

  @override
  String get discardTitle => 'Discard this record?';

  @override
  String get discardBody =>
      'The photos and what you entered will not be saved.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Deleted.';

  @override
  String get edit => 'Edit';

  @override
  String get detailTitle => 'Record';

  @override
  String get recordNotFound => 'This record no longer exists.';

  @override
  String get tapToZoom => 'Tap a photo to enlarge it';

  @override
  String zoomPhoto(int number) {
    return 'Enlarge photo $number';
  }

  @override
  String get showOcrText => 'Show text';

  @override
  String get ocrTextNote => 'Used for search. It may contain reading errors.';

  @override
  String registeredAt(String date) {
    return 'Added $date';
  }

  @override
  String get deleteRecordTitle => 'Delete this record';

  @override
  String get deleteRecordBody =>
      'The record and its photos will be deleted from this device. This can\'t be undone.';

  @override
  String noDateAdded(String date) {
    return 'No date (added $date)';
  }

  @override
  String get noMedicineNames => 'No medicine names entered';

  @override
  String get listSeparator => ', ';

  @override
  String get searchHint => 'Search medicines, clinics, pharmacies';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noSearchResults =>
      'No records match. Search also looks through the text read from photos.';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get sectionFamily => 'Family';

  @override
  String get familyNote =>
      'Keep records separately for each person, such as your parents or children.';

  @override
  String get familyEditNote => 'Tap a name to rename or delete it.';

  @override
  String get addPerson => 'Add a person';

  @override
  String get renamePerson => 'Rename';

  @override
  String get deletePerson => 'Delete';

  @override
  String deletePersonTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deletePersonBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count records and their photos will also be deleted. This can\'t be undone.',
      one: '1 record and its photos will also be deleted. This can\'t be undone.',
      zero: 'This person has no records.',
    );
    return '$_temp0';
  }

  @override
  String get personNameHint => 'Name (e.g. Mom)';

  @override
  String get currentlyShown => 'Currently shown';

  @override
  String get sectionPurchase => 'Purchase';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languageSystem => 'Same as iPhone';

  @override
  String get sectionBackup => 'Backup';

  @override
  String get backupNote =>
      'Keep the backup file somewhere other than this iPhone, such as iCloud Drive. To move to a new iPhone, restore the file there.';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupNote => 'All records and photos in one file';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String get restoreBackupNote => 'Replaces the records on this device';

  @override
  String get restoreConfirmTitle => 'Replace all records?';

  @override
  String restoreConfirmBody(int persons, int records) {
    return 'The records on this device will be replaced with the backup ($persons people, $records records). Records not in the backup will be deleted.';
  }

  @override
  String get restoreAction => 'Replace';

  @override
  String get restoreDone => 'Restored from the backup.';

  @override
  String get restoreUnreadable =>
      'This file can\'t be restored. Choose a backup exported from this app.';

  @override
  String get backupFailed =>
      'Something went wrong. Your records were not changed.';

  @override
  String get sectionAbout => 'About this app';

  @override
  String get privacyTitle => 'Privacy and data';

  @override
  String get privacyLocalTitle => 'Stored only on this device';

  @override
  String get privacyLocalBody =>
      'No account is needed. Records and photos are stored only in this app on your iPhone and are never sent to our servers. Deleting the app deletes them too, so export a backup if you want to keep them.';

  @override
  String get privacyOcrTitle => 'Text is read on the device';

  @override
  String get privacyOcrBody =>
      'Reading text from photos is done by iOS on this iPhone. Photos and text are not sent anywhere for reading.';

  @override
  String get privacyBackupTitle => 'Backups';

  @override
  String get privacyBackupBody =>
      'A backup is a single file containing all records and photos. It is not encrypted, so choose carefully where you save or send it.';

  @override
  String get privacyAdsTitle => 'Ads';

  @override
  String get privacyAdsBody =>
      'The free version shows ads from Google AdMob. Only non-personalized ads are requested, and your records and photos are never shared with the ad service.';

  @override
  String get privacyMedicalTitle => 'About medical decisions';

  @override
  String get medicalDisclaimer =>
      'This app keeps a history of medication information you photograph or enter. It does not give dosing instructions, check drug interactions, or send reminders. For questions about your medicines, ask your doctor or pharmacist.';

  @override
  String get removeAdsNote => 'One-time purchase or monthly plan';

  @override
  String get paywallBody =>
      'SnapMed Log is free with no limit on records. A one-time purchase or a monthly plan hides the ads.';

  @override
  String get textSizeNote =>
      'Added on top of your iPhone\'s text size setting.';

  @override
  String get adPrivacyOptions => 'Ad privacy choices';

  @override
  String get buyLifetime => 'One-time purchase';

  @override
  String buyLifetimeWithPrice(String price) {
    return 'One-time purchase: $price';
  }

  @override
  String get buyMonthly => 'Monthly plan';

  @override
  String buyMonthlyWithPrice(String price) {
    return '$price per month';
  }

  @override
  String get paywallLifetimeNote => 'Pay once and the ads are gone for good.';

  @override
  String get paywallPointFree => 'Every feature works without buying';

  @override
  String get paywallPointNoAds => 'All ads are hidden';

  @override
  String get paywallTitle => 'Remove ads';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get purchaseCancelled => 'The purchase was cancelled.';

  @override
  String get purchased => 'Ads removed';

  @override
  String get purchasedNote => 'Thank you for your support.';

  @override
  String get purchaseFailed =>
      'The purchase could not be completed. Your records are safe.';

  @override
  String get purchaseSuccess => 'Thank you! Ads are now hidden.';

  @override
  String get purchaseUnavailable =>
      'Purchases are not available right now. Please try again later.';

  @override
  String get rateApp => 'Rate this app';

  @override
  String get removeAds => 'Remove ads';

  @override
  String get restoreNothing => 'No purchase to restore was found.';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get reviewLater => 'Later';

  @override
  String get reviewMessage1 => 'This app is made by a solo developer.';

  @override
  String get reviewMessage2 =>
      'If it helps you, a review would be a huge encouragement and helps the app grow.';

  @override
  String get reviewMessage3 => '(\"Later\" is totally fine too.)';

  @override
  String get reviewThankYouTitle => 'Thank you for using this app!';

  @override
  String get subscriptionTerms =>
      'The monthly plan renews automatically each month and is charged to your Apple Account unless you cancel at least 24 hours before the renewal date. You can cancel anytime in the Settings app under your name > Subscriptions.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get textExtraLarge => 'Extra large';

  @override
  String get textLarge => 'Large';

  @override
  String get textStandard => 'Standard';

  @override
  String get sectionTextSize => 'Text size';

  @override
  String get version => 'Version';

  @override
  String get writeReview => 'Write a review';
}
