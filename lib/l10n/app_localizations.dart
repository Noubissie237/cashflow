import 'package:flutter/material.dart';

class AppLocalizations {
  final Map<String, String> _localizedStrings;

  AppLocalizations(this._localizedStrings);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}