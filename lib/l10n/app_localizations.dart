import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Smarty'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In de, this message translates to:
  /// **'Startseite'**
  String get home;

  /// No description provided for @shopping.
  ///
  /// In de, this message translates to:
  /// **'Einkaufen'**
  String get shopping;

  /// No description provided for @notifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get notifications;

  /// No description provided for @account.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get account;

  /// No description provided for @myFridge.
  ///
  /// In de, this message translates to:
  /// **'Mein Kühlschrank'**
  String get myFridge;

  /// No description provided for @shoppingList.
  ///
  /// In de, this message translates to:
  /// **'Einkaufsliste'**
  String get shoppingList;

  /// No description provided for @editShelfName.
  ///
  /// In de, this message translates to:
  /// **'Regalnamen bearbeiten'**
  String get editShelfName;

  /// No description provided for @newShelfName.
  ///
  /// In de, this message translates to:
  /// **'Neuer Regalname'**
  String get newShelfName;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @addNewItem.
  ///
  /// In de, this message translates to:
  /// **'Neues Produkt hinzufügen'**
  String get addNewItem;

  /// No description provided for @itemName.
  ///
  /// In de, this message translates to:
  /// **'Produktname'**
  String get itemName;

  /// No description provided for @addItem.
  ///
  /// In de, this message translates to:
  /// **'Produkt hinzufügen'**
  String get addItem;

  /// No description provided for @error.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get error;

  /// No description provided for @yourShoppingListIsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Ihre Einkaufsliste ist leer.'**
  String get yourShoppingListIsEmpty;

  /// No description provided for @noShelvesFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Regale gefunden.'**
  String get noShelvesFound;

  /// No description provided for @logOut.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logOut;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @featureNotAvailable.
  ///
  /// In de, this message translates to:
  /// **'Diese Funktion ist noch nicht verfügbar.'**
  String get featureNotAvailable;

  /// No description provided for @noNewNotifications.
  ///
  /// In de, this message translates to:
  /// **'Keine neuen Benachrichtigungen.'**
  String get noNewNotifications;

  /// No description provided for @login.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get login;

  /// No description provided for @register.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get register;

  /// No description provided for @email.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get password;

  /// No description provided for @dontHaveAccount.
  ///
  /// In de, this message translates to:
  /// **'Sie haben noch kein Konto?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In de, this message translates to:
  /// **'Sie haben bereits ein Konto?'**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie Ihre E-Mail-Adresse ein'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie Ihr Passwort ein'**
  String get pleaseEnterPassword;

  /// No description provided for @recipes.
  ///
  /// In de, this message translates to:
  /// **'Rezepte'**
  String get recipes;

  /// No description provided for @noRecipesFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Rezepte gefunden.'**
  String get noRecipesFound;

  /// No description provided for @ingredients.
  ///
  /// In de, this message translates to:
  /// **'Zutaten'**
  String get ingredients;

  /// No description provided for @instructions.
  ///
  /// In de, this message translates to:
  /// **'Zubereitung'**
  String get instructions;

  /// No description provided for @addRecipe.
  ///
  /// In de, this message translates to:
  /// **'Rezept hinzufügen'**
  String get addRecipe;

  /// No description provided for @recipeName.
  ///
  /// In de, this message translates to:
  /// **'Rezeptname'**
  String get recipeName;

  /// No description provided for @pleaseEnterRecipeName.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie den Rezeptnamen ein'**
  String get pleaseEnterRecipeName;

  /// No description provided for @ingredientName.
  ///
  /// In de, this message translates to:
  /// **'Zutat'**
  String get ingredientName;

  /// No description provided for @quantity.
  ///
  /// In de, this message translates to:
  /// **'Menge'**
  String get quantity;

  /// No description provided for @pleaseAddIngredients.
  ///
  /// In de, this message translates to:
  /// **'Bitte fügen Sie mindestens eine Zutat hinzu'**
  String get pleaseAddIngredients;

  /// No description provided for @pleaseEnterInstructions.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie die Zubereitungsschritte ein'**
  String get pleaseEnterInstructions;

  /// No description provided for @recipesAddedSuccessfully.
  ///
  /// In de, this message translates to:
  /// **'Rezepte erfolgreich hinzugefügt'**
  String get recipesAddedSuccessfully;

  /// No description provided for @fetchRandomRecipes.
  ///
  /// In de, this message translates to:
  /// **'Rezepte finden'**
  String get fetchRandomRecipes;

  /// No description provided for @cuisine.
  ///
  /// In de, this message translates to:
  /// **'Küche'**
  String get cuisine;

  /// No description provided for @category.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get category;

  /// No description provided for @selectCuisine.
  ///
  /// In de, this message translates to:
  /// **'Küche auswählen'**
  String get selectCuisine;

  /// No description provided for @selectCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie auswählen'**
  String get selectCategory;

  /// No description provided for @numberOfRecipes.
  ///
  /// In de, this message translates to:
  /// **'Anzahl der Rezepte'**
  String get numberOfRecipes;

  /// No description provided for @fetch.
  ///
  /// In de, this message translates to:
  /// **'Abrufen'**
  String get fetch;

  /// No description provided for @search.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get search;

  /// No description provided for @searchResults.
  ///
  /// In de, this message translates to:
  /// **'Suchergebnisse'**
  String get searchResults;

  /// No description provided for @addSelected.
  ///
  /// In de, this message translates to:
  /// **'Ausgewählte hinzufügen'**
  String get addSelected;

  /// No description provided for @noResultsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Ergebnisse gefunden.'**
  String get noResultsFound;

  /// No description provided for @bottleVolume.
  ///
  /// In de, this message translates to:
  /// **'Flaschenvolumen (L)'**
  String get bottleVolume;

  /// No description provided for @containerType.
  ///
  /// In de, this message translates to:
  /// **'Behältertyp'**
  String get containerType;

  /// No description provided for @glass.
  ///
  /// In de, this message translates to:
  /// **'Glas'**
  String get glass;

  /// No description provided for @plastic.
  ///
  /// In de, this message translates to:
  /// **'Plastik'**
  String get plastic;

  /// No description provided for @bottles.
  ///
  /// In de, this message translates to:
  /// **'Flaschen'**
  String get bottles;

  /// No description provided for @catBeef.
  ///
  /// In de, this message translates to:
  /// **'Rindfleisch'**
  String get catBeef;

  /// No description provided for @catBreakfast.
  ///
  /// In de, this message translates to:
  /// **'Frühstück'**
  String get catBreakfast;

  /// No description provided for @catChicken.
  ///
  /// In de, this message translates to:
  /// **'Hähnchen'**
  String get catChicken;

  /// No description provided for @catDessert.
  ///
  /// In de, this message translates to:
  /// **'Dessert'**
  String get catDessert;

  /// No description provided for @catGoat.
  ///
  /// In de, this message translates to:
  /// **'Ziegenfleisch'**
  String get catGoat;

  /// No description provided for @catLamb.
  ///
  /// In de, this message translates to:
  /// **'Lammfleisch'**
  String get catLamb;

  /// No description provided for @catMiscellaneous.
  ///
  /// In de, this message translates to:
  /// **'Verschiedenes'**
  String get catMiscellaneous;

  /// No description provided for @catPasta.
  ///
  /// In de, this message translates to:
  /// **'Nudeln'**
  String get catPasta;

  /// No description provided for @catPork.
  ///
  /// In de, this message translates to:
  /// **'Schweinefleisch'**
  String get catPork;

  /// No description provided for @catSeafood.
  ///
  /// In de, this message translates to:
  /// **'Meeresfrüchte'**
  String get catSeafood;

  /// No description provided for @catSide.
  ///
  /// In de, this message translates to:
  /// **'Beilage'**
  String get catSide;

  /// No description provided for @catStarter.
  ///
  /// In de, this message translates to:
  /// **'Vorspeise'**
  String get catStarter;

  /// No description provided for @catVegan.
  ///
  /// In de, this message translates to:
  /// **'Vegan'**
  String get catVegan;

  /// No description provided for @catVegetarian.
  ///
  /// In de, this message translates to:
  /// **'Vegetarisch'**
  String get catVegetarian;

  /// No description provided for @areaAmerican.
  ///
  /// In de, this message translates to:
  /// **'Amerikanisch'**
  String get areaAmerican;

  /// No description provided for @areaBritish.
  ///
  /// In de, this message translates to:
  /// **'Britisch'**
  String get areaBritish;

  /// No description provided for @areaCanadian.
  ///
  /// In de, this message translates to:
  /// **'Kanadisch'**
  String get areaCanadian;

  /// No description provided for @areaChinese.
  ///
  /// In de, this message translates to:
  /// **'Chinesisch'**
  String get areaChinese;

  /// No description provided for @areaDutch.
  ///
  /// In de, this message translates to:
  /// **'Holländisch'**
  String get areaDutch;

  /// No description provided for @areaEgyptian.
  ///
  /// In de, this message translates to:
  /// **'Ägyptisch'**
  String get areaEgyptian;

  /// No description provided for @areaFrench.
  ///
  /// In de, this message translates to:
  /// **'Französisch'**
  String get areaFrench;

  /// No description provided for @areaGreek.
  ///
  /// In de, this message translates to:
  /// **'Griechisch'**
  String get areaGreek;

  /// No description provided for @areaIndian.
  ///
  /// In de, this message translates to:
  /// **'Indisch'**
  String get areaIndian;

  /// No description provided for @areaIrish.
  ///
  /// In de, this message translates to:
  /// **'Irisch'**
  String get areaIrish;

  /// No description provided for @areaItalian.
  ///
  /// In de, this message translates to:
  /// **'Italienisch'**
  String get areaItalian;

  /// No description provided for @areaJamaican.
  ///
  /// In de, this message translates to:
  /// **'Jamaikanisch'**
  String get areaJamaican;

  /// No description provided for @areaJapanese.
  ///
  /// In de, this message translates to:
  /// **'Japanisch'**
  String get areaJapanese;

  /// No description provided for @areaKenyan.
  ///
  /// In de, this message translates to:
  /// **'Kenianisch'**
  String get areaKenyan;

  /// No description provided for @areaMalaysian.
  ///
  /// In de, this message translates to:
  /// **'Malaysisch'**
  String get areaMalaysian;

  /// No description provided for @areaMexican.
  ///
  /// In de, this message translates to:
  /// **'Mexikanisch'**
  String get areaMexican;

  /// No description provided for @areaMoroccan.
  ///
  /// In de, this message translates to:
  /// **'Marokkanisch'**
  String get areaMoroccan;

  /// No description provided for @areaPolish.
  ///
  /// In de, this message translates to:
  /// **'Polnisch'**
  String get areaPolish;

  /// No description provided for @areaPortuguese.
  ///
  /// In de, this message translates to:
  /// **'Portugiesisch'**
  String get areaPortuguese;

  /// No description provided for @areaRussian.
  ///
  /// In de, this message translates to:
  /// **'Russisch'**
  String get areaRussian;

  /// No description provided for @areaSpanish.
  ///
  /// In de, this message translates to:
  /// **'Spanisch'**
  String get areaSpanish;

  /// No description provided for @areaThai.
  ///
  /// In de, this message translates to:
  /// **'Thailändisch'**
  String get areaThai;

  /// No description provided for @areaTunisian.
  ///
  /// In de, this message translates to:
  /// **'Tunesisch'**
  String get areaTunisian;

  /// No description provided for @areaTurkish.
  ///
  /// In de, this message translates to:
  /// **'Türkisch'**
  String get areaTurkish;

  /// No description provided for @areaVietnamese.
  ///
  /// In de, this message translates to:
  /// **'Vietnamesisch'**
  String get areaVietnamese;

  /// No description provided for @calibration.
  ///
  /// In de, this message translates to:
  /// **'Kalibrierung'**
  String get calibration;

  /// No description provided for @sensorCalibration.
  ///
  /// In de, this message translates to:
  /// **'Sensorkalibrierung'**
  String get sensorCalibration;

  /// No description provided for @emptyPlatforms.
  ///
  /// In de, this message translates to:
  /// **'Alle Plattformen leeren.'**
  String get emptyPlatforms;

  /// No description provided for @setZero.
  ///
  /// In de, this message translates to:
  /// **'Nullsetzen (Tara)'**
  String get setZero;

  /// No description provided for @place800gP1.
  ///
  /// In de, this message translates to:
  /// **'Legen Sie 800g auf Plattform 1.'**
  String get place800gP1;

  /// No description provided for @place800gP2.
  ///
  /// In de, this message translates to:
  /// **'Legen Sie 800g auf Plattform 2.'**
  String get place800gP2;

  /// No description provided for @calibrateP1.
  ///
  /// In de, this message translates to:
  /// **'Plattform 1 kalibrieren'**
  String get calibrateP1;

  /// No description provided for @calibrateP2.
  ///
  /// In de, this message translates to:
  /// **'Plattform 2 kalibrieren'**
  String get calibrateP2;

  /// No description provided for @calibrationComplete.
  ///
  /// In de, this message translates to:
  /// **'Kalibrierung erfolgreich abgeschlossen.'**
  String get calibrationComplete;

  /// No description provided for @startCalibration.
  ///
  /// In de, this message translates to:
  /// **'Kalibrierung starten'**
  String get startCalibration;

  /// No description provided for @step.
  ///
  /// In de, this message translates to:
  /// **'Schritt'**
  String get step;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
