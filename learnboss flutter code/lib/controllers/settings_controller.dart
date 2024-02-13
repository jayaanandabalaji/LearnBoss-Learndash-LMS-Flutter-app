
import 'package:get/get.dart';

class SettingsController extends GetxController {
  var settings = {}.obs;
  setSettings(Map response) {
    settings.value = response;
  }
}
