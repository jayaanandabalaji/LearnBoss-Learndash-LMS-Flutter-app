import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:learndash/utils/Constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../models/courses.dart';
import '../services/courses_api.dart';
import 'course_details.dart';

class CategoryCourses extends StatefulWidget {
  final Map? category;
  final String search;
  final bool isAllCourses;
  const CategoryCourses(
      {Key? key, this.category, this.search = "", this.isAllCourses = false})
      : super(key: key);

  @override
  State<CategoryCourses> createState() => _CategoryCoursesState();
}

class _CategoryCoursesState extends State<CategoryCourses> {
  @override
  void initState() {
    super.initState();
    getCategoryCourses();
  }

  List<dynamic>? categoryCourses;
  int pageNumber = 1;

  getNextPage() async {
    pageNumber++;

    if (widget.isAllCourses) {
      var response = await CoursesApi().getCourse(pageId: pageNumber);
      if (response.length == 0) {
        _refreshController.loadNoData();
      }
      categoryCourses!.addAll(response);
    }
    if (widget.category != null) {
      var response = await CoursesApi()
          .getCourse(category: widget.category!['term_id'], pageId: pageNumber);
      if (response.length == 0) {
        _refreshController.loadNoData();
      }
      categoryCourses!.addAll(response);
    }

    if (widget.search != "") {
      var response = await CoursesApi()
          .getCourse(search: widget.search, pageId: pageNumber);
      if (response.length == 0) {
        _refreshController.loadNoData();
      }
      categoryCourses!.addAll(response);
    }
    _refreshController.loadComplete();
    if (categoryCourses!.length % 10 != 0) {
      _refreshController.loadNoData();
    }
    setState(() {});
  }

  getCategoryCourses() async {
    EasyLoading.show();

    if (widget.isAllCourses) {
      var response = await CoursesApi().getCourse(pageId: pageNumber);
      categoryCourses = response;
    }
    if (widget.category != null) {
      var response = await CoursesApi()
          .getCourse(category: widget.category!['term_id'], pageId: pageNumber);
      categoryCourses = response;
    }

    if (widget.search != "") {
      var response = await CoursesApi()
          .getCourse(search: widget.search, pageId: pageNumber);
      categoryCourses = response;
    }

    if (categoryCourses!.length % 10 != 0) {
      _refreshController.loadNoData();
    }

    EasyLoading.dismiss();
    setState(() {});
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(widget.isAllCourses
              ? "All Courses"
              : widget.category != null
                  ? widget.category!["name"]
                  : "\"${widget.search}\"")),
      body: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        header: const WaterDropHeader(),
        controller: _refreshController,
        onLoading: () {
          getNextPage();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          children: [
            if (categoryCourses != null && categoryCourses!.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "All Courses",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  for (Course course in categoryCourses!) buildCourse(course)
                ],
              ),
            if (categoryCourses != null && categoryCourses!.isEmpty)
              SizedBox(
                height: Get.height * 0.7,
                child: const Center(
                    child: Text(
                  "There's no available courses",
                  style: TextStyle(color: Colors.grey, fontSize: 17),
                )),
              )
          ],
        ),
      ),
    );
  }

  Widget buildCourse(Course course) {
    return GestureDetector(
      onTap: () {
        Get.to(CourseDetails(course));
      },
      child: Container(
        height: 120,
        width: Get.width,
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    course.instructor["name"],
                    style: TextStyle(
                        color: Constants.secondaryColor, fontSize: 14),
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
                        fontSize: 16),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
