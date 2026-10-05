import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SnapMed Log'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @captureButton.
  ///
  /// In en, this message translates to:
  /// **'Snap to record'**
  String get captureButton;

  /// No description provided for @captureCaption.
  ///
  /// In en, this message translates to:
  /// **'Photograph the medication sheet, bag or label. Several pages are fine.'**
  String get captureCaption;

  /// No description provided for @importPhotos.
  ///
  /// In en, this message translates to:
  /// **'From photos'**
  String get importPhotos;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Type it in'**
  String get manualEntry;

  /// No description provided for @recentRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent records'**
  String get recentRecords;

  /// No description provided for @showAllRecords.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} records'**
  String showAllRecords(int count);

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records yet. Tap \"Snap to record\" and photograph a medication information sheet, a pharmacy bag or a label.'**
  String get homeEmpty;

  /// No description provided for @whoseRecords.
  ///
  /// In en, this message translates to:
  /// **'Whose records?'**
  String get whoseRecords;

  /// No description provided for @manageFamily.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get manageFamily;

  /// No description provided for @switchPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Showing records for {name}. Tap to switch.'**
  String switchPersonLabel(String name);

  /// No description provided for @newRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Check and save'**
  String get newRecordTitle;

  /// No description provided for @editRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editRecordTitle;

  /// No description provided for @readingText.
  ///
  /// In en, this message translates to:
  /// **'Reading the text on this device…'**
  String get readingText;

  /// No description provided for @checkSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Filled in from the photo. Compare with the photo and correct anything that\'s wrong.'**
  String get checkSuggestions;

  /// No description provided for @blankIsOk.
  ///
  /// In en, this message translates to:
  /// **'You can leave anything blank and still save.'**
  String get blankIsOk;

  /// No description provided for @manualHint.
  ///
  /// In en, this message translates to:
  /// **'Type in what you know. Blank fields are fine. You can also add a photo.'**
  String get manualHint;

  /// No description provided for @fieldPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get fieldPerson;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Prescription date'**
  String get fieldDate;

  /// No description provided for @fieldMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get fieldMedicines;

  /// No description provided for @fieldHospital.
  ///
  /// In en, this message translates to:
  /// **'Clinic / hospital'**
  String get fieldHospital;

  /// No description provided for @fieldPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get fieldPharmacy;

  /// No description provided for @fieldMemo.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldMemo;

  /// No description provided for @fieldOcrText.
  ///
  /// In en, this message translates to:
  /// **'Text read from the photo'**
  String get fieldOcrText;

  /// No description provided for @dateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set (tap to choose)'**
  String get dateNotSet;

  /// No description provided for @dateNotSetShort.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get dateNotSetShort;

  /// No description provided for @notEntered.
  ///
  /// In en, this message translates to:
  /// **'Not entered'**
  String get notEntered;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// No description provided for @medicineHint.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medicineHint;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add a medicine'**
  String get addMedicine;

  /// No description provided for @removeMedicine.
  ///
  /// In en, this message translates to:
  /// **'Remove this medicine'**
  String get removeMedicine;

  /// No description provided for @addPage.
  ///
  /// In en, this message translates to:
  /// **'Add page'**
  String get addPage;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @addByCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photos'**
  String get addByCamera;

  /// No description provided for @addFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from Photos'**
  String get addFromLibrary;

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageNumber(int number);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String pageOf(int current, int total);

  /// No description provided for @removePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this page?'**
  String get removePageTitle;

  /// No description provided for @removePageBody.
  ///
  /// In en, this message translates to:
  /// **'The photo and its text will be removed from this record.'**
  String get removePageBody;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get saved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get saveFailed;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this record?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'The photos and what you entered will not be saved.'**
  String get discardBody;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted.'**
  String get deleted;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get detailTitle;

  /// No description provided for @recordNotFound.
  ///
  /// In en, this message translates to:
  /// **'This record no longer exists.'**
  String get recordNotFound;

  /// No description provided for @tapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap a photo to enlarge it'**
  String get tapToZoom;

  /// No description provided for @zoomPhoto.
  ///
  /// In en, this message translates to:
  /// **'Enlarge photo {number}'**
  String zoomPhoto(int number);

  /// No description provided for @showOcrText.
  ///
  /// In en, this message translates to:
  /// **'Show text'**
  String get showOcrText;

  /// No description provided for @ocrTextNote.
  ///
  /// In en, this message translates to:
  /// **'Used for search. It may contain reading errors.'**
  String get ocrTextNote;

  /// No description provided for @registeredAt.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String registeredAt(String date);

  /// No description provided for @deleteRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this record'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordBody.
  ///
  /// In en, this message translates to:
  /// **'The record and its photos will be deleted from this device. This can\'t be undone.'**
  String get deleteRecordBody;

  /// No description provided for @noDateAdded.
  ///
  /// In en, this message translates to:
  /// **'No date (added {date})'**
  String noDateAdded(String date);

  /// No description provided for @noMedicineNames.
  ///
  /// In en, this message translates to:
  /// **'No medicine names entered'**
  String get noMedicineNames;

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search medicines, clinics, pharmacies'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No records match. Search also looks through the text read from photos.'**
  String get noSearchResults;

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record} other{{count} records}}'**
  String searchResultCount(int count);

  /// No description provided for @sectionFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get sectionFamily;

  /// No description provided for @familyNote.
  ///
  /// In en, this message translates to:
  /// **'Keep records separately for each person, such as your parents or children.'**
  String get familyNote;

  /// No description provided for @familyEditNote.
  ///
  /// In en, this message translates to:
  /// **'Tap a name to rename or delete it.'**
  String get familyEditNote;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add a person'**
  String get addPerson;

  /// No description provided for @renamePerson.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renamePerson;

  /// No description provided for @deletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePerson;

  /// No description provided for @deletePersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deletePersonTitle(String name);

  /// No description provided for @deletePersonBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{This person has no records.} =1{1 record and its photos will also be deleted. This can\'t be undone.} other{{count} records and their photos will also be deleted. This can\'t be undone.}}'**
  String deletePersonBody(int count);

  /// No description provided for @personNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Mom)'**
  String get personNameHint;

  /// No description provided for @currentlyShown.
  ///
  /// In en, this message translates to:
  /// **'Currently shown'**
  String get currentlyShown;

  /// No description provided for @sectionPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get sectionPurchase;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as iPhone'**
  String get languageSystem;

  /// No description provided for @sectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get sectionBackup;

  /// No description provided for @backupNote.
  ///
  /// In en, this message translates to:
  /// **'Keep the backup file somewhere other than this iPhone, such as iCloud Drive. To move to a new iPhone, restore the file there.'**
  String get backupNote;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupNote.
  ///
  /// In en, this message translates to:
  /// **'All records and photos in one file'**
  String get exportBackupNote;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupNote.
  ///
  /// In en, this message translates to:
  /// **'Replaces the records on this device'**
  String get restoreBackupNote;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all records?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The records on this device will be replaced with the backup ({persons} people, {records} records). Records not in the backup will be deleted.'**
  String restoreConfirmBody(int persons, int records);

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get restoreAction;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restored from the backup.'**
  String get restoreDone;

  /// No description provided for @restoreUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This file can\'t be restored. Choose a backup exported from this app.'**
  String get restoreUnreadable;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Your records were not changed.'**
  String get backupFailed;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get sectionAbout;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get privacyTitle;

  /// No description provided for @privacyLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device'**
  String get privacyLocalTitle;

  /// No description provided for @privacyLocalBody.
  ///
  /// In en, this message translates to:
  /// **'No account is needed. Records and photos are stored only in this app on your iPhone and are never sent to our servers. Deleting the app deletes them too, so export a backup if you want to keep them.'**
  String get privacyLocalBody;

  /// No description provided for @privacyOcrTitle.
  ///
  /// In en, this message translates to:
  /// **'Text is read on the device'**
  String get privacyOcrTitle;

  /// No description provided for @privacyOcrBody.
  ///
  /// In en, this message translates to:
  /// **'Reading text from photos is done by iOS on this iPhone. Photos and text are not sent anywhere for reading.'**
  String get privacyOcrBody;

  /// No description provided for @privacyBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get privacyBackupTitle;

  /// No description provided for @privacyBackupBody.
  ///
  /// In en, this message translates to:
  /// **'A backup is a single file containing all records and photos. It is not encrypted, so choose carefully where you save or send it.'**
  String get privacyBackupBody;

  /// No description provided for @privacyAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get privacyAdsTitle;

  /// No description provided for @privacyAdsBody.
  ///
  /// In en, this message translates to:
  /// **'The free version shows ads from Google AdMob. Only non-personalized ads are requested, and your records and photos are never shared with the ad service.'**
  String get privacyAdsBody;

  /// No description provided for @privacyMedicalTitle.
  ///
  /// In en, this message translates to:
  /// **'About medical decisions'**
  String get privacyMedicalTitle;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This app keeps a history of medication information you photograph or enter. It does not give dosing instructions, check drug interactions, or send reminders. For questions about your medicines, ask your doctor or pharmacist.'**
  String get medicalDisclaimer;

  /// No description provided for @removeAdsNote.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase or monthly plan'**
  String get removeAdsNote;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'SnapMed Log is free with no limit on records. A one-time purchase or a monthly plan hides the ads.'**
  String get paywallBody;

  /// No description provided for @textSizeNote.
  ///
  /// In en, this message translates to:
  /// **'Added on top of your iPhone\'s text size setting.'**
  String get textSizeNote;

  /// No description provided for @adPrivacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get adPrivacyOptions;

  /// No description provided for @buyLifetime.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get buyLifetime;

  /// No description provided for @buyLifetimeWithPrice.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase: {price}'**
  String buyLifetimeWithPrice(String price);

  /// No description provided for @buyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly plan'**
  String get buyMonthly;

  /// No description provided for @buyMonthlyWithPrice.
  ///
  /// In en, this message translates to:
  /// **'{price} per month'**
  String buyMonthlyWithPrice(String price);

  /// No description provided for @paywallLifetimeNote.
  ///
  /// In en, this message translates to:
  /// **'Pay once and the ads are gone for good.'**
  String get paywallLifetimeNote;

  /// No description provided for @paywallPointFree.
  ///
  /// In en, this message translates to:
  /// **'Every feature works without buying'**
  String get paywallPointFree;

  /// No description provided for @paywallPointNoAds.
  ///
  /// In en, this message translates to:
  /// **'All ads are hidden'**
  String get paywallPointNoAds;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get paywallTitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @purchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'The purchase was cancelled.'**
  String get purchaseCancelled;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Ads removed'**
  String get purchased;

  /// No description provided for @purchasedNote.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support.'**
  String get purchasedNote;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be completed. Your records are safe.'**
  String get purchaseFailed;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Ads are now hidden.'**
  String get purchaseSuccess;

  /// No description provided for @purchaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not available right now. Please try again later.'**
  String get purchaseUnavailable;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get rateApp;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get removeAds;

  /// No description provided for @restoreNothing.
  ///
  /// In en, this message translates to:
  /// **'No purchase to restore was found.'**
  String get restoreNothing;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restorePurchase;

  /// No description provided for @reviewLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get reviewLater;

  /// No description provided for @reviewMessage1.
  ///
  /// In en, this message translates to:
  /// **'This app is made by a solo developer.'**
  String get reviewMessage1;

  /// No description provided for @reviewMessage2.
  ///
  /// In en, this message translates to:
  /// **'If it helps you, a review would be a huge encouragement and helps the app grow.'**
  String get reviewMessage2;

  /// No description provided for @reviewMessage3.
  ///
  /// In en, this message translates to:
  /// **'(\"Later\" is totally fine too.)'**
  String get reviewMessage3;

  /// No description provided for @reviewThankYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using this app!'**
  String get reviewThankYouTitle;

  /// No description provided for @subscriptionTerms.
  ///
  /// In en, this message translates to:
  /// **'The monthly plan renews automatically each month and is charged to your Apple Account unless you cancel at least 24 hours before the renewal date. You can cancel anytime in the Settings app under your name > Subscriptions.'**
  String get subscriptionTerms;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @textExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textExtraLarge;

  /// No description provided for @textLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textLarge;

  /// No description provided for @textStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get textStandard;

  /// No description provided for @sectionTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get sectionTextSize;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
