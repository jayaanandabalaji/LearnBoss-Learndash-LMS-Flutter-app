import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:learndash/controllers/wishlist_controller.dart';
import 'package:learndash/models/courses.dart';
import '../services/courses_api.dart';
import 'package:learndash/utils/Constants.dart';

import 'course_details.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    getWishlistedCourses();
  }

  final WishlistController wishlistController = Get.put(WishlistController());

  bool isLoading = true;
  getWishlistedCourses() async {
    List<int> coursesWish = [];
    if (wishlistController.wishlistedCourses.isNotEmpty) {
      for (String id in wishlistController.wishlistedCourses) {
        coursesWish.add(int.parse(id));
      }
      EasyLoading.show();
      var response = await CoursesApi().getCourse(id: coursesWish);
      wishlistController.wishlistedCoursesList.value = response;
      EasyLoading.dismiss();
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlists"),
        centerTitle: true,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          children: [
            if (wishlistController.wishlistedCoursesList.isNotEmpty &&
                !isLoading)
              Column(
                children: [
                  for (Course course
                      in wishlistController.wishlistedCoursesList)
                    wishlistedGrid(course)
                ],
              ),
            if (!isLoading && wishlistController.wishlistedCoursesList.isEmpty)
              SizedBox(
                height: Get.height * 0.8,
                child: const Center(
                  child: Text(
                    "There's no available courses",
                    style: TextStyle(color: Colors.grey, fontSize: 17),
                  ),
                ),
              )
          ],
        );
      }),
    );
  }

  Widget wishlistedGrid(Course course) {
    return GestureDetector(
      onTap: () {
        Get.to(CourseDetails(course));
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(width: 1, color: Colors.grey.withOpacity(0.4)))),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          // ignore: unrelated_type_equality_checks
          if (course.image != "" && course.image != false)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ExtendedImage.network(
                course.image,
                height: 100,
                width: 110,
                fit: BoxFit.cover,
              ),
            ),
          // ignore: unrelated_type_equality_checks
          if (course.image == "" || course.image == false)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ExtendedImage.asset(
                "assets/coursesPlaceholder.png",
                height: 100,
                width: 110,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      course.instructor["name"],
                      style: TextStyle(
                          color: Constants.secondaryColor, fontSize: 13),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      (course.price == "")
                          ? "Free"
                          : Constants.currency + course.price,
                      style: TextStyle(
                          color: (course.price == "")
                              ? Colors.green
                              : Constants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MaterialButton(
                      onPressed: () {
                        wishlistController.removeFromWishlistedCourses(
                            course.id.toString(), course);
                      },
                      child: Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Constants.secondaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                          child: Text(
                            "Remove",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ]),
            ),
          )
        ]),
      ),
    );
  }
}
