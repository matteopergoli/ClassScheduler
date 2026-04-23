// lib/providers/locale_provider.dart
//
// Persists the user's language override (FR-I18N-04).
// Falls back to device locale; if unsupported, uses English (FR-I18N-03).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'cs_locale';

/// All supported locales at launch (EN + IT) plus stubs.
const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('it'),
  Locale('es'), // stub
  Locale('fr'), // stub
  Locale('de'), // stub
];

const Locale kDefaultLocale = Locale('en');

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadFromPrefs();
    return null; // null = respect device locale
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kLocaleKey);
    if (stored != null) {
      state = Locale(stored);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  Future<void> clearOverride() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLocaleKey);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
