import 'package:flutter/material.dart';

class LocaleConstants {
  static const String defaultLocale = 'en';
  static const Locale enLocale = Locale('en');
  static const Locale arLocale = Locale('ar');
  
  static const List<Locale> supportedLocales = [
    enLocale,
    arLocale,
  ];
  
  static const String languageCodeKey = 'languageCode';
  
  static const String PATH = 'assets/translations';
} 