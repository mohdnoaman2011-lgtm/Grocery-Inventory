import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'l10n/strings.dart';
import 'screens/splash_screen.dart';

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: tr('app'),
          themeMode: state.theme,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: kGreen),
          darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: kGreen, brightness: Brightness.dark),
          locale: Locale(state.isAr ? 'ar' : 'en'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        ),
      );
}
