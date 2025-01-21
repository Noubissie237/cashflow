import 'package:cashflow/l10n/app_localizations.dart';
import 'package:cashflow/l10n/strings_en.dart';
import 'package:cashflow/l10n/strings_fr.dart';
import 'package:flutter/material.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Map<String, String> localizedStrings;
    switch (locale.languageCode) {
      case 'fr':
        localizedStrings = fr;
        break;
      case 'en':
        localizedStrings = en;
        break;
      default:
        localizedStrings = en;
    }
    return AppLocalizations(localizedStrings);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
