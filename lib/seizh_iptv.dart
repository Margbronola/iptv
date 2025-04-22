import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/globals/routes.dart';
import 'package:seizhiptv/views/splashscreen.dart';

class SeizhIptv extends StatelessWidget {
  const SeizhIptv({super.key});
  static final Routes _route = Routes.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seizh TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        scaffoldBackgroundColor: ColorPalette().card,
        primaryColor: Colors.orange,
        brightness: Brightness.dark,
        radioTheme: RadioThemeData(
          fillColor: WidgetStateColor.resolveWith((states) => Colors.orange),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashscreenPage(),
      onGenerateRoute: _route.settings,
    );
  }
}
