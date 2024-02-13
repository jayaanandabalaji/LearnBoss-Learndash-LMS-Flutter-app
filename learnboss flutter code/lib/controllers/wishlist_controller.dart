import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/courses.dart';

class WishlistController extends GetxController {
  var wishlistedCourses = [].obs;
  var wishlistedCoursesList = [].obs;
  initWishlistedCourses() async {
    var box = await Hive.openBox(
      "learndash",
    );
    wishlistedCourses.value = (await box.get("wishlisted", defaultValue: []));
  }

  addtoWishlistedCourses(String id, Course course) async {
    wishlistedCourses.add(id);
    wishlistedCoursesList.add(course);
    await storeWishlistedCourses();
  }

  removeFromWishlistedCourses(String id, Course course) async {
    wishlistedCourses.remove(id);
    wishlistedCoursesList.remove(course);
    await storeWishlistedCourses();
  }

  storeWishlistedCourses() async {
    var box = await Hive.openBox(
      "learndash",
    );
    box.put("wishlisted", wishlistedCourses);
    wishlistedCourses.refresh();
    wishlistedCoursesList.refresh();
  }
}
