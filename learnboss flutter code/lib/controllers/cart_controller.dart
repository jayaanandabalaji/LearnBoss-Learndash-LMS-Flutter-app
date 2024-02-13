import 'package:get/get.dart';
import 'package:hive/hive.dart';

class CartController extends GetxController {
  var cartCourses = [].obs;
  initcartCourses() async {
    var box = await Hive.openBox(
      "learndash",
    );
    cartCourses.value = (await box.get("cart", defaultValue: []));
  }

  addtocartCourses(String id) async {
    cartCourses.add(id);
    await storecartCourses();
  }

  removeFromcartCourses(String id) async {
    cartCourses.remove(id);
    await storecartCourses();
  }

  storecartCourses() async {
    var box = await Hive.openBox(
      "learndash",
    );
    box.put("cart", cartCourses);
    cartCourses.refresh();
  }
}
