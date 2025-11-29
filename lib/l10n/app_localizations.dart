import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_de.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';
import 'app_localizations_hi.dart';

/// Base class for app localizations
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('pt'), // Portuguese
    Locale('zh'), // Chinese (Simplified)
    Locale('hi'), // Hindi
  ];

  // Common
  String get appName;
  String get ok;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get loading;
  String get error;
  String get success;
  String get retry;
  String get close;
  String get yes;
  String get no;

  // Navigation
  String get dashboard;
  String get friends;
  String get groups;
  String get activity;
  String get profile;

  // Authentication
  String get login;
  String get register;
  String get logout;
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get resetPassword;
  String get signInWithGoogle;
  String get dontHaveAccount;
  String get alreadyHaveAccount;
  String get createAccount;
  String get passwordResetSent;
  String get loginSuccess;
  String get registerSuccess;
  String get logoutSuccess;

  // Validation
  String get emailRequired;
  String get passwordRequired;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  String get invalidEmail;

  // Profile
  String get displayName;
  String get phoneNumber;
  String get defaultCurrency;
  String get defaultLanguage;
  String get profilePicture;
  String get editProfile;
  String get settings;
  String get currencySettings;
  String get languageSettings;

  // Expenses
  String get expenses;
  String get addExpense;
  String get editExpense;
  String get deleteExpense;
  String get expenseDetails;
  String get amount;
  String get description;
  String get category;
  String get date;
  String get paidBy;
  String get splitType;
  String get participants;
  String get attachReceipt;
  String get notes;
  String get expenseAdded;
  String get expenseUpdated;
  String get expenseDeleted;

  // Split Types
  String get equalSplit;
  String get unequalSplit;
  String get percentageSplit;
  String get sharesSplit;
  String get splitEqually;
  String get splitByAmount;
  String get splitByPercentage;
  String get splitByShares;

  // Categories
  String get food;
  String get entertainment;
  String get utilities;
  String get transportation;
  String get shopping;
  String get travel;
  String get personal;
  String get health;
  String get subscription;
  String get other;

  // Balances
  String get balances;
  String get youOwe;
  String get owesYou;
  String get settleUp;
  String get settled;
  String get simplifyDebts;
  String get detailedView;
  String get simplifiedView;
  String get settlementHistory;
  String get noBalances;

  // Friends
  String get addFriend;
  String get removeFriend;
  String get friendRequests;
  String get sendRequest;
  String get acceptRequest;
  String get declineRequest;
  String get pending;
  String get accepted;
  String get blocked;
  String get noFriends;
  String get friendAdded;
  String get friendRemoved;
  String get requestSent;
  String get requestAccepted;
  String get requestDeclined;

  // Groups
  String get createGroup;
  String get editGroup;
  String get deleteGroup;
  String get leaveGroup;
  String get groupName;
  String get groupDescription;
  String get members;
  String get addMember;
  String get removeMember;
  String get admin;
  String get member;
  String get transferAdmin;
  String get groupSettings;
  String get noGroups;
  String get groupCreated;
  String get groupUpdated;
  String get groupDeleted;
  String get memberAdded;
  String get memberRemoved;

  // Recurring Expenses
  String get recurringExpenses;
  String get createRecurring;
  String get frequency;
  String get daily;
  String get weekly;
  String get monthly;
  String get yearly;
  String get startDate;
  String get endDate;
  String get nextDue;
  String get pause;
  String get resume;
  String get active;
  String get paused;
  String get upcomingExpenses;

  // Saved Splits
  String get savedSplits;
  String get createSavedSplit;
  String get splitName;
  String get applySplit;
  String get noSavedSplits;

  // Currency
  String get currency;
  String get exchangeRate;
  String get convertedAmount;
  String get lastUpdated;
  String get refreshRates;
  String get clearCache;
  String get supportedCurrencies;
  String get popularCurrencies;
  String get allCurrencies;

  // Language
  String get language;
  String get selectLanguage;
  String get languageChanged;

  // Date & Time
  String get today;
  String get yesterday;
  String get tomorrow;
  String get thisWeek;
  String get thisMonth;
  String get thisYear;

  // Errors
  String get errorOccurred;
  String get networkError;
  String get authError;
  String get permissionDenied;
  String get notFound;
  String get tryAgain;

  // Empty States
  String get noExpenses;
  String get noActivity;
  String get noResults;

  // Filters
  String get filterBy;
  String get dateRange;
  String get allCategories;
  String get allMembers;

  // Notifications
  String get notifications;
  String get newExpense;
  String get newFriendRequest;
  String get paymentReceived;

  // Misc
  String get total;
  String get subtotal;
  String get perPerson;
  String get share;
  String get percentage;
  String get shares;
  String get viewDetails;
  String get confirm;
  String get back;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'es',
      'fr',
      'de',
      'pt',
      'zh',
      'hi',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'es':
        return AppLocalizationsEs();
      case 'fr':
        return AppLocalizationsFr();
      case 'de':
        return AppLocalizationsDe();
      case 'pt':
        return AppLocalizationsPt();
      case 'zh':
        return AppLocalizationsZh();
      case 'hi':
        return AppLocalizationsHi();
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
