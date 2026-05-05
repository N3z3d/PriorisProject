import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prioris/l10n/app_localizations.dart';

Widget localizedApp(Widget body, {Locale locale = const Locale('fr')}) {
  return MaterialApp(
    locale: locale,
    theme: ThemeData(splashFactory: InkRipple.splashFactory),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('fr'), Locale('en'), Locale('es'), Locale('de')],
    home: Scaffold(body: body),
  );
}
