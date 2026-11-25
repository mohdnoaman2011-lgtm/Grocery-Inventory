import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'l10n/strings.dart';
import 'screens/splash_screen.dart';
import 'screens/lock_screen.dart';

class InventoryApp extends StatefulWidget {
  const InventoryApp({super.key});
  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused) state.lockNow();
    if (s == AppLifecycleState.resumed) state.maybeAutoBackup();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: tr('app'),
          themeMode: state.theme,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          locale: Locale(state.isAr ? 'ar' : 'en'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              // تحديد تكبير الخط حتى لا تتضخم الواجهة على الأجهزة ذات الخط الكبير
              data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.1)),
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayFor(Theme.of(context).brightness),
                child: Stack(children: [
                  child ?? const SizedBox.shrink(),
                  if (state.locked && state.splashDone) const Positioned.fill(child: LockScreen()),
                ]),
              ),
            );
          },
          home: const SplashScreen(),
        ),
      );
}
