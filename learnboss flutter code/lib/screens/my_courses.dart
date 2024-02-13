import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:learndash/screens/take_course.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  void initState() {
    super.initState();
    getEnrolledCourses();
  }

  List<dynamic>? enrolledCourses;
  bool isLoggedIn = false;
  getEnrolledCourses() async {
    if (Hive.box("learndash").get("token") == null) {
      isLoggedIn = false;
    } else {
      isLoggedIn = true;
      EasyLoading.show();
      var response = await BaseApi.getAsync("learndashapp/v1/enrolled-courses",
          requiredToken: true);
      enrolledCourses = response;
      EasyLoading.dismiss();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Courses"),
          centerTitle: true,
        ),
        body: (isLoggedIn)
            ? ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                children: [
                  if (enrolledCourses != null)
                    Column(
                      children: [
                        for (Map course in enrolledCourses!)
                          buildEnrolledCourses(course)
                      ],
                    )
                ],
              )
            : const Center(
                child: Text("Please login/register before visiting this page.",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w400)),
              ));
  }

  Widget buildEnrolledCourses(Map course) {
    return Container(
      width: Get.width * 0.85,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 149, 157, 165),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (course['image'] != null && course['image'] != "")
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    course['image'],
                    height: 150,
                    width: Get.width * 0.85,
                    fit: BoxFit.cover,
                  ))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/coursesPlaceholder.png",
                    height: 150,
                    width: Get.width * 0.85,
                    fit: BoxFit.cover,
                  )),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course["name"],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    buildText("Total lesson", course["total"].toString()),
                    const SizedBox(
                      width: 8,
                    ),
                    buildText("Completed lesson",
                        "${course["completed"]}/${course["total"]}")
                  ],
                ),
                buildSlider(course["completed"] /
                    ((course["total"] == 0) ? 1 : course["total"])),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${(course["completed"] / ((course["total"] == 0) ? 1 : course["total"]) * 100).toInt()}% complete",
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                MaterialButton(
                  onPressed: () {
                    Get.to(TakeCourse(course));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constants.secondaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: const Center(
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSlider(double value) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
          activeTrackColor: Constants.secondaryColor,
          inactiveTrackColor: Constants.secondaryColor.withOpacity(0.2),
          trackShape: const RectangularSliderTrackShape(),
          trackHeight: 3.0,
          thumbColor: Constants.secondaryColor,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          overlayShape: SliderComponentShape.noOverlay),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: Get.width,
        child: Slider(
          value: value,
          onChanged: (double value) {},
          min: 0,
          max: 1,
        ),
      ),
    );
  }

  Widget buildText(String text1, String text2) {
    return Text.rich(TextSpan(children: [
      TextSpan(text: "$text1: ", style: const TextStyle(color: Colors.grey)),
      TextSpan(text: text2, style: const TextStyle())
    ]));
  }
}
