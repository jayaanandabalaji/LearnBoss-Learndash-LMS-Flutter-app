import 'package:learndash/utils/Constants.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learndash/controllers/settings_controller.dart';
import '../services/base_api.dart';
import 'package:learndash/widgets/navigation_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    getSettings();
  }

  getSettings() async {
    if (Constants.screenProtectOn) {
      if (GetPlatform.isAndroid) {
        ScreenProtector.protectDataLeakageOn();
      }
      if (GetPlatform.isIOS) {
        await ScreenProtector.protectDataLeakageWithColor(Colors.white);
      }
    }
    var response = await BaseApi.getAsync("learndashapp/v1/app-settings");
    SettingsController settingsController = Get.put(SettingsController());
    settingsController.setSettings(response);
    Get.off(const Navbar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ExtendedImage.asset(
          "assets/logo.png",
          width: Get.width * 0.8,
        ),
      ),
    );
  }
}
