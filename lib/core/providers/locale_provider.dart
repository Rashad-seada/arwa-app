import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_starter_package/core/config/locale_constants.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(LocaleConstants.enLocale) {
    loadSavedLocale();
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(LocaleConstants.languageCodeKey);
    
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocaleConstants.languageCodeKey, locale.languageCode);
    state = locale;
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en' 
        ? LocaleConstants.arLocale 
        : LocaleConstants.enLocale;
    await setLocale(newLocale);
  }

  bool get isRtl => state.languageCode == 'ar';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
}); 