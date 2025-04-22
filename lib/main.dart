import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhiptv/globals/data_cacher.dart';
import 'package:seizhiptv/seizh_iptv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DataCacher cacher = DataCacher.instance;
  await cacher.init();
  await dotenv.load();
  await Firebase.initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/lang', // <-- change the path of the translation files
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: SeizhIptv(),
    ),
  );
}
