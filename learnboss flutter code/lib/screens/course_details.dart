import 'package:extended_image/extended_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/cart_controller.dart';
import 'package:learndash/controllers/wishlist_controller.dart';
import 'package:learndash/screens/login.dart';
import 'package:learndash/screens/take_course.dart';
import 'package:learndash/utils/Constants.dart';

import '../models/courses.dart';
import '../services/base_api.dart';
import '../widgets/custom_expansion_tile.dart';
import '../widgets/navigation_bar.dart';
import 'cart_screen.dart';

class CourseDetails extends StatefulWidget {
  final Course course;
  const CourseDetails(this.course, {Key? key}) : super(key: key);

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  final WishlistController wishlistController = Get.put(WishlistController());
  final CartController cartController = Get.put(CartController());
  Future isLoggedIn() async {
    Box box = await Hive.openBox(
      "learndash",
    );
    String token = box.get("token", defaultValue: "");
    if (token == "") {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Constants.primaryColor,
          shadowColor: Colors.transparent),
      body: ListView(children: [
        SizedBox(
            height: 400,
            child: Stack(
              children: [
                Container(
                  height: 300,
                  color: Constants.primaryColor,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                      height: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.course.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: Colors.white)),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                  constraints: const BoxConstraints(
                                      minHeight: 60, maxHeight: 60),
                                  child: SingleChildScrollView(
                                      child: Wrap(
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: [
                                      for (Map category
                                          in widget.course.category)
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Constants.secondaryColor
                                                .withAlpha(100),
                                          ),
                                          child: Text(
                                            category["title"].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                    ],
                                  ))),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  (widget.course.instructor["avatar"] == "")
                                      ? Image.asset("assets/user.png",
                                          height: 20)
                                      : Image.network(
                                          widget.course.instructor["avatar"],
                                          height: 20,
                                          width: 20,
                                        ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.course.instructor["name"],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Last Updated ${DateFormat("MMMM d y").format(DateTime.now())}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ExtendedImage.network(
                                widget.course.image,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ],
            )),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.course.price == "")
                            ? "Free"
                            : Constants.currency + widget.course.price,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: (widget.course.price == "")
                                ? Colors.green
                                : Constants.primaryColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FutureBuilder(
                          future: isLoggedIn(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data == null) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.data) {
                              return Column(
                                children: [
                                  if (!widget.course.enrolled &&
                                      widget.course.price_type == "paynow" &&
                                      widget.course.price != "")
                                    paidCourseButtons(),
                                  if (widget.course.enrolled)
                                    continueCourseButton(),
                                  if (!widget.course.enrolled &&
                                      widget.course.price_type == "free" &&
                                      widget.course.price == "")
                                    enrollFreeCourseButton(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  wishlistButton()
                                ],
                              );
                            }
                            return MaterialButton(
                                color: Constants.primaryColor,
                                textColor: Colors.white,
                                minWidth: MediaQuery.of(context).size.width,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                                },
                                child: const Text("Login",
                                    style: TextStyle(fontSize: 17)));
                          })
                    ])),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 20,
              color: Colors.grey.shade200,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("About this course",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17)),
                    Html(
                      data: widget.course.content,
                    )
                  ]),
            ),
            Container(
              height: 20,
              color: Colors.grey.shade200,
            ),
            Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Curriculum",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 17)),
                      const SizedBox(height: 5),
                      Text("${widget.course.lectures} lectures total",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 17)),
                      const SizedBox(height: 6),
                      for (var lesson in getLessonIdsInOrder(
                          widget.course.curriculum.structure["h"]))
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1, color: Colors.grey.shade500)),
                          child: ListTileTheme(
                              minVerticalPadding: 0,
                              child: CustomExpansionTile(
                                isQuiz: isQuiz(
                                  widget.course.curriculum.lesson_details,
                                  lesson,
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                iconColor: Constants.secondaryColor,
                                collapsedIconColor: Constants.secondaryColor,
                                textColor: Constants.secondaryColor,
                                collapsedTextColor: Constants.secondaryColor,
                                title: Text(
                                    getTopicName(
                                      widget.course.curriculum.lesson_details,
                                      lesson,
                                    ),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                children: <Widget>[
                                  for (var topic in getLessonTopics(lesson,
                                      widget.course.curriculum.structure["h"]))
                                    ListTile(
                                        leading: FaIcon(
                                            isQuiz(
                                              widget.course.curriculum
                                                  .lesson_details,
                                              topic,
                                            )
                                                ? FontAwesomeIcons.clock
                                                : FontAwesomeIcons.file,
                                            size: 20),
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20),
                                        visualDensity: const VisualDensity(
                                            horizontal: 0, vertical: 0),
                                        title: Text(
                                          getTopicName(
                                            widget.course.curriculum
                                                .lesson_details,
                                            topic,
                                          ),
                                          style: const TextStyle(fontSize: 15),
                                        )),
                                ],
                              )),
                        ),
                    ]))
          ],
        )
      ]),
    ));
  }

  Widget enrollFreeCourseButton() {
    return MaterialButton(
      color: Constants.primaryColor,
      textColor: Colors.white,
      minWidth: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 12),
      onPressed: () async {
        EasyLoading.show();
        var box = await Hive.openBox(
          "learndash",
        );
        await BaseApi.postAsync("learndashapp/v1/enroll-course",
            {"id": widget.course.id, "user_id": box.get("id")},
            requiresPurchaseCode: true);
        EasyLoading.dismiss();
        Get.offAll(const Navbar());
      },
      child: const Text("Enroll Course", style: TextStyle(fontSize: 17)),
    );
  }

  Widget continueCourseButton() {
    return MaterialButton(
      color: Constants.primaryColor,
      textColor: Colors.white,
      minWidth: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 12),
      onPressed: () async {
        EasyLoading.show();
        var response = await BaseApi.getAsync(
            "learndashapp/v1/enrolled-courses",
            requiredToken: true);
        for (Map course in response!) {
          if (course["id"] == widget.course.id) {
            Get.to(TakeCourse(course));
          }
        }
        EasyLoading.dismiss();
      },
      child: const Text("Continue Course", style: TextStyle(fontSize: 17)),
    );
  }

  Widget wishlistButton() {
    return Obx(() {
      return InkWell(
        onTap: () async {
          EasyLoading.show();
          if (wishlistController.wishlistedCourses
              .contains(widget.course.id.toString())) {
            await wishlistController.removeFromWishlistedCourses(
                widget.course.id.toString(), widget.course);
          } else {
            await wishlistController.addtoWishlistedCourses(
                widget.course.id.toString(), widget.course);
          }

          EasyLoading.dismiss();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  (wishlistController.wishlistedCourses
                          .contains(widget.course.id.toString()))
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  color: Colors.red),
              const SizedBox(
                width: 10,
              ),
              Text(
                  (wishlistController.wishlistedCourses
                          .contains(widget.course.id.toString()))
                      ? "Remove to wishlist"
                      : "Add to wishlist",
                  style: const TextStyle(color: Colors.red, fontSize: 18))
            ],
          ),
        ),
      );
    });
  }

  Widget paidCourseButtons() {
    return Column(
      children: [
        Obx(() {
          return MaterialButton(
            color: Constants.primaryColor,
            textColor: Colors.white,
            minWidth: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 12),
            onPressed: () {
              EasyLoading.show();
              if (cartController.cartCourses
                  .contains(widget.course.id.toString())) {
                cartController
                    .removeFromcartCourses(widget.course.id.toString());
              } else {
                cartController.addtocartCourses(widget.course.id.toString());
              }
              EasyLoading.dismiss();
            },
            child: Text(
                cartController.cartCourses.contains(widget.course.id.toString())
                    ? "Remove to cart"
                    : "Add to cart",
                style: const TextStyle(fontSize: 17)),
          );
        }),
        const SizedBox(
          height: 15,
        ),
        MaterialButton(
          color: Colors.grey.shade200,
          textColor: Constants.primaryColor,
          minWidth: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 12),
          onPressed: () {
            Get.to(CartScreen(
              id: 2,
              course: widget.course,
            ));
          },
          child: const Text("Buy Now", style: TextStyle(fontSize: 17)),
        ),
      ],
    );
  }

  isQuiz(var lessonDetails, var topic) {
    var isQuiz = false;

    for (var quiz in lessonDetails.quizzes) {
      if (topic == quiz["id"].toString()) {
        isQuiz = true;
      }
    }
    return isQuiz;
  }

  getTopicName(var lessonDetails, var topic) {
    var topicName = "";
    for (var topicI in lessonDetails.topics) {
      if (topic == topicI["id"].toString()) {
        topicName = topicI["title"];
      }
    }
    for (var quiz in lessonDetails.quizzes) {
      if (topic == quiz["id"].toString()) {
        topicName = quiz["title"];
      }
    }
    return topicName;
  }

  getLessonTopics(var lesson, var structure) {
    var topicsList = [];
    if (structure.runtimeType.toString() ==
            "_InternalLinkedHashMap<String, dynamic>" ||
        structure.runtimeType.toString() == "_Map<String, dynamic>") {
      for (var lessonStr in structure.keys) {
        if (structure[lessonStr].runtimeType.toString() ==
                "_InternalLinkedHashMap<String, dynamic>" ||
            structure[lessonStr].runtimeType.toString() ==
                "_Map<String, dynamic>") {
          for (var lessonId in structure[lessonStr].keys) {
            if (lessonId == lesson) {
              if (structure[lessonStr][lessonId].runtimeType.toString() ==
                      "_InternalLinkedHashMap<String, dynamic>" ||
                  structure[lessonStr][lessonId].runtimeType.toString() ==
                      "_Map<String, dynamic>") {
                for (var topicsStr in structure[lessonStr][lessonId].keys) {
                  if (structure[lessonStr][lessonId][topicsStr]
                              .runtimeType
                              .toString() ==
                          "_InternalLinkedHashMap<String, dynamic>" ||
                      structure[lessonStr][lessonId][topicsStr]
                              .runtimeType
                              .toString() ==
                          "_Map<String, dynamic>") {
                    for (var topicsId
                        in structure[lessonStr][lessonId][topicsStr].keys) {
                      topicsList.add(topicsId);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return topicsList;
  }

  getLessonIdsInOrder(var structure) {
    List lessonsList = [];
    for (var lesson in structure.keys) {
      if (structure[lesson].runtimeType.toString() ==
              "_InternalLinkedHashMap<String, dynamic>" ||
          structure[lesson].runtimeType.toString() == "_Map<String, dynamic>") {
        for (var topics in structure[lesson].keys) {
          lessonsList.add(topics);
        }
      }
    }
    return lessonsList;
  }
}
