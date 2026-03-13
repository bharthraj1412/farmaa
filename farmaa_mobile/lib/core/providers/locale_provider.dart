import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app locale (language) with persistence.
class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'farmaa_locale';

  @override
  Locale build() {
    _loadLocale();
    return const Locale('en'); // default
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null) {
        state = Locale(code);
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale.languageCode);
    } catch (_) {}
  }

  bool get isTamil => state.languageCode == 'ta';
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
