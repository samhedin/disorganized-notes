import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @copyContent.
  ///
  /// In en, this message translates to:
  /// **'Copy content from parent?'**
  String get copyContent;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @webVersion.
  ///
  /// In en, this message translates to:
  /// **'Desktop version'**
  String get webVersion;

  /// No description provided for @listsStartExpanded.
  ///
  /// In en, this message translates to:
  /// **'Checked items list starts expanded'**
  String get listsStartExpanded;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @premiumAccess.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumAccess;

  /// No description provided for @getPremiumAccess.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get getPremiumAccess;

  /// No description provided for @openStore.
  ///
  /// In en, this message translates to:
  /// **'Leave a review/rating'**
  String get openStore;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Input email'**
  String get enterEmail;

  /// No description provided for @inputEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the email of a registered user.\nTo share with an iOS user, use the special email-address listed in their settings.'**
  String get inputEmail;

  /// No description provided for @shareExternal.
  ///
  /// In en, this message translates to:
  /// **'Share externally'**
  String get shareExternal;

  /// No description provided for @shareRegistered.
  ///
  /// In en, this message translates to:
  /// **'Share with registered user'**
  String get shareRegistered;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @accountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account deletion'**
  String get accountDeletion;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @checkboxes.
  ///
  /// In en, this message translates to:
  /// **'Checkboxes'**
  String get checkboxes;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get read;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchbarText.
  ///
  /// In en, this message translates to:
  /// **'Search for anything, also works for #tags'**
  String get searchbarText;

  /// No description provided for @plaintextText.
  ///
  /// In en, this message translates to:
  /// **'Write text here!'**
  String get plaintextText;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @deviceTheme.
  ///
  /// In en, this message translates to:
  /// **'Device theme'**
  String get deviceTheme;

  /// No description provided for @mayrequirerestart.
  ///
  /// In en, this message translates to:
  /// **'May require restart'**
  String get mayrequirerestart;

  /// No description provided for @requiresPremium.
  ///
  /// In en, this message translates to:
  /// **'This feature requires premium'**
  String get requiresPremium;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @misc.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get misc;

  /// No description provided for @viewmanual.
  ///
  /// In en, this message translates to:
  /// **'View Manual'**
  String get viewmanual;

  /// No description provided for @viewchangelog.
  ///
  /// In en, this message translates to:
  /// **'View changelog'**
  String get viewchangelog;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Suggestion box'**
  String get feedback;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @discord.
  ///
  /// In en, this message translates to:
  /// **'Join the'**
  String get discord;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send an email'**
  String get sendEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription details'**
  String get subscriptionDetails;

  /// No description provided for @subscriptionDetailsText.
  ///
  /// In en, this message translates to:
  /// **'Premium costs \$3.99 per month converted to local currency where applicable.'**
  String get subscriptionDetailsText;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsofuseeula.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use/EULA'**
  String get termsofuseeula;

  /// No description provided for @accountid.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get accountid;

  /// No description provided for @childItem.
  ///
  /// In en, this message translates to:
  /// **'Nested item'**
  String get childItem;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @notificationHint.
  ///
  /// In en, this message translates to:
  /// **'To get a notification, you need to be online and set a date at least 3 minutes into the future.'**
  String get notificationHint;

  /// No description provided for @checkedItems.
  ///
  /// In en, this message translates to:
  /// **' checked items'**
  String get checkedItems;

  /// No description provided for @accountidText.
  ///
  /// In en, this message translates to:
  /// **'Include your ID when contacting support'**
  String get accountidText;

  /// No description provided for @dataaccdeletion.
  ///
  /// In en, this message translates to:
  /// **'Data/Account deletion'**
  String get dataaccdeletion;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get deleteAccount;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Really delete note?'**
  String get deleteConfirm;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'We save authentication data and notes.\nYou can delete your data and account from the settings.'**
  String get collection;

  /// No description provided for @clearYourMind.
  ///
  /// In en, this message translates to:
  /// **'Clear your mind - write a note'**
  String get clearYourMind;

  /// No description provided for @reallyDeleteSection.
  ///
  /// In en, this message translates to:
  /// **'Really delete section?'**
  String get reallyDeleteSection;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration enables imports, cloud backups, real-time sync, voice recordings, and media storage. Media storage is a premium feature'**
  String get registration;

  /// No description provided for @genImageWarning.
  ///
  /// In en, this message translates to:
  /// **'Generate public urls for images? \nIf no, will not export media files.\nIf yes, you are responsible for keeping the exported URLs secret.'**
  String get genImageWarning;

  /// No description provided for @batchExport.
  ///
  /// In en, this message translates to:
  /// **'Batch export'**
  String get batchExport;

  /// No description provided for @exportMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Export to Markdown'**
  String get exportMarkdown;

  /// No description provided for @batchExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported notes to '**
  String get batchExportSuccess;

  /// No description provided for @batchExportInfo.
  ///
  /// In en, this message translates to:
  /// **'Export all notes to Markdown.\nThis can be shared with e.g Google Docs for export to PDF, printing, and editing.'**
  String get batchExportInfo;

  /// No description provided for @batchExportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Exporting, do not leave the app.'**
  String get batchExportInProgress;

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'Select a primary color'**
  String get primaryColor;

  /// No description provided for @revertDefault.
  ///
  /// In en, this message translates to:
  /// **'Revert to default'**
  String get revertDefault;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @reorderRowsSections.
  ///
  /// In en, this message translates to:
  /// **'Reorder rows/sections.'**
  String get reorderRowsSections;

  /// No description provided for @reorderColumns.
  ///
  /// In en, this message translates to:
  /// **'Reorder columns'**
  String get reorderColumns;

  /// No description provided for @reorderItems.
  ///
  /// In en, this message translates to:
  /// **'Reorder items/sections.'**
  String get reorderItems;

  /// No description provided for @indent.
  ///
  /// In en, this message translates to:
  /// **'Swipe to indent (Doesn\'t work in settings view)'**
  String get indent;

  /// No description provided for @deindent.
  ///
  /// In en, this message translates to:
  /// **'Swipe to de-indent'**
  String get deindent;

  /// No description provided for @tryHomeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Try this home workout!'**
  String get tryHomeWorkout;

  /// No description provided for @homeWorkoutText.
  ///
  /// In en, this message translates to:
  /// **'Home workout\n\nLinks here create clickable buttons below: \nAssisted pistol squat: https://youtu.be/tiA23NSUm7A\nReverse nordic curl: https://youtu.be/uJSCxJh-tec'**
  String get homeWorkoutText;

  /// No description provided for @nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get nothing;

  /// No description provided for @calculateColumns.
  ///
  /// In en, this message translates to:
  /// **'Calculate column(s)'**
  String get calculateColumns;

  /// No description provided for @windowRatio.
  ///
  /// In en, this message translates to:
  /// **'iPad/tablet/web: Note list vs note editing window ratio'**
  String get windowRatio;

  /// No description provided for @offlineNotes.
  ///
  /// In en, this message translates to:
  /// **'Test: 10 notes before free registration.'**
  String get offlineNotes;

  /// No description provided for @restartAppPremium.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app to load premium access!'**
  String get restartAppPremium;

  /// No description provided for @moveSubscription.
  ///
  /// In en, this message translates to:
  /// **'Move previously purchased subscription to this account ID.'**
  String get moveSubscription;

  /// No description provided for @registerAccount.
  ///
  /// In en, this message translates to:
  /// **'Please register an account before using this!'**
  String get registerAccount;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'If you have premium but you\'re missing access (maybe you are logged in with a new account?), press this button to sync premium. If it doesn\'t work, send an e-mail to support (see below).'**
  String get restorePurchase;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
