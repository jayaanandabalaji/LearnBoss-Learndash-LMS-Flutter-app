import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:learndash/utils/Constants.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'screens/splash_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Firebase.initializeApp();

  await Hive.openBox("learndash");
  try {
    Stripe.publishableKey = Constants.stripePublishableKey;
    await Stripe.instance.applySettings();
  } finally {
    await FlutterDownloader.initialize(
        debug:
            true, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl:
            true // option: set to false to disable working with http links (default: false)
        );
    HttpOverrides.global = MyHttpOverrides();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    runApp(
      Phoenix(
        child: const MyApp(),
      ),
    );
  }

  configLoading();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Constants.primaryColor, // status bar color
  ));
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 55.0
    ..radius = 10.0
    ..progressColor = Constants.primaryColor
    ..backgroundColor = Colors.white
    ..indicatorColor = Constants.primaryColor
    ..textColor = Colors.yellow
    ..maskColor = Colors.black.withOpacity(0.3)
    ..maskType = EasyLoadingMaskType.custom
    ..userInteractions = true
    ..contentPadding = const EdgeInsets.all(25)
    ..dismissOnTap = true;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            elevation: 3,
            shadowColor: Colors.grey.shade100.withOpacity(0.7),
            foregroundColor: Colors.black,
            color: Colors.white),
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
