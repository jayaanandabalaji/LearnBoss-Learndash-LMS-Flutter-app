import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:learndash/screens/quiz_screen.dart';
import 'package:learndash/screens/topic_details.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

import 'lesson_details.dart';

class TakeCourse extends StatefulWidget {
  final Map course;
  const TakeCourse(this.course, {Key? key}) : super(key: key);

  @override
  State<TakeCourse> createState() => _TakeCourseState();
}

class _TakeCourseState extends State<TakeCourse> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color(0xffF6F6F8),
          body: ListView(physics: const BouncingScrollPhysics(), children: [
            Stack(
              children: [
                topArea(),
                SizedBox(
                  height: 280,
                  width: Get.width,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      width: Get.width * 0.85,
                      height: 80,
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
                      child: courseProgressDetails(),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: courseContent())
          ])),
    );
  }

  bool isAllOpened() {
    for (String lesson
        in getLessonIdsInOrder(widget.course["curriculum"]['structure']["h"])) {
      if (isOpened[lesson] == null || !isOpened[lesson]!) {
        return false;
      }
    }
    return true;
  }

  Widget courseContent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Course Content",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            GestureDetector(
              onTap: () {
                if (isAllOpened()) {
                  for (String lesson in getLessonIdsInOrder(
                      widget.course["curriculum"]['structure']["h"])) {
                    isOpened[lesson] = false;
                  }
                } else {
                  for (String lesson in getLessonIdsInOrder(
                      widget.course["curriculum"]['structure']["h"])) {
                    isOpened[lesson] = true;
                  }
                }

                setState(() {});
              },
              child: Text(
                (isAllOpened()) ? "Collapse All" : "Expand All",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    color: Constants.secondaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        buildCurriculum(widget.course["curriculum"]),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget buildCurriculum(Map curriculum) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        children: [
          for (String lesson
              in getLessonIdsInOrder(curriculum['structure']["h"]))
            buildChapter(lesson, curriculum)
        ],
      ),
    );
  }

  Map<String, bool> isOpened = {};
  Map<String, dynamic> lessonsResponse = {};

  Widget buildChapter(String chapter, Map curriculum) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.4), width: 1))),
            height: 35,
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Get.width * 0.55,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isOpened[chapter] == null) {
                            isOpened[chapter] = true;
                          } else {
                            isOpened[chapter] = !(isOpened[chapter]!);
                          }
                          setState(() {});
                        },
                        child: Icon(
                          (isOpened[chapter] != null && isOpened[chapter]!)
                              ? Icons.arrow_drop_down
                              : Icons.arrow_drop_up,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (lessonsResponse.isEmpty) {
                              var box = await Hive.openBox(
                                "learndash",
                              );
                              EasyLoading.show();
                              lessonsResponse = await BaseApi.getAsync(
                                  "learndashapp/v1/get-lesson?user_id=${box.get("id")}&course_id=${widget.course["id"]}",
                                  requiresPurchaseCode: true);
                              EasyLoading.dismiss();
                            }

                            if (!isQuiz(
                                widget.course["curriculum"]["lesson_details"],
                                chapter)) {
                              await Get.to(LessonDetails(int.parse(chapter),
                                  lessonsResponse, widget.course));
                            } else {
                              EasyLoading.show();

                              var box = await Hive.openBox(
                                "learndash",
                              );

                              var response = await BaseApi.getAsync(
                                  "learndashapp/v1/get-quizzes",
                                  queryParams: {
                                    "course_id": widget.course["id"],
                                    "user_id": box.get("id")
                                  },
                                  requiresPurchaseCode: true);
                              EasyLoading.dismiss();

                              await Get.to(QuizScreen(
                                  widget.course, response, int.parse(chapter)));
                            }

                            setState(() {});
                          },
                          child: Text(
                            getTopicName(
                              curriculum["lesson_details"],
                              chapter,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "${getChaptersCompleted(chapter)[0]}/${getChaptersCompleted(chapter)[1]} steps",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    if (widget.course["lessons"][chapter] == 0)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.grey.withOpacity(0.4),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Constants.secondaryColor),
                            value: getChaptersCompleted(chapter)[0] /
                                getChaptersCompleted(chapter)[1]),
                      ),
                    if (widget.course["lessons"][chapter] == 1)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Icon(Icons.check_circle,
                            color: Constants.secondaryColor),
                      ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                )
              ],
            ),
          ),
          if (isOpened[chapter] != null && isOpened[chapter]!)
            for (String topic
                in getLessonTopics(chapter, curriculum["structure"]["h"]))
              buildLesson(topic, curriculum, chapter)
        ],
      ),
    );
  }

  isLessonCompleted(String lesson) {
    bool isCompleted = false;

    if (widget.course["topics"].runtimeType.toString() ==
            "_InternalLinkedHashMap<String, dynamic>" ||
        widget.course["topics"].runtimeType.toString() ==
            "_Map<String, dynamic>") {
      for (String chapters in widget.course["topics"].keys) {
        if (widget.course["topics"][chapters].runtimeType.toString() ==
                "_InternalLinkedHashMap<String, dynamic>" ||
            widget.course["topics"][chapters].runtimeType.toString() ==
                "_Map<String, dynamic>") {
          for (String singleLesson in widget.course["topics"][chapters].keys) {
            if (lesson == singleLesson &&
                widget.course["topics"][chapters][lesson] == 1) {
              isCompleted = true;
            }
          }
        }
      }
    }
    if (isQuiz(widget.course["curriculum"]["lesson_details"], lesson)) {
      if (isQuizCompleted(lesson)) {
        isCompleted = true;
      }
    }
    return isCompleted;
  }

  getChaptersCompleted(String chapter) {
    int total = 0;
    int completed = 0;
    if (widget.course["curriculum"]["structure"]["h"]["sfwd-lessons"][chapter]
                .runtimeType
                .toString() ==
            "_InternalLinkedHashMap<String, dynamic>" ||
        widget.course["curriculum"]["structure"]["h"]["sfwd-lessons"][chapter]
                .runtimeType
                .toString() ==
            "_Map<String, dynamic>") {
      for (String lessonType in widget
          .course["curriculum"]["structure"]["h"]["sfwd-lessons"][chapter]
          .keys) {
        if (widget
                    .course["curriculum"]["structure"]["h"]["sfwd-lessons"]
                        [chapter][lessonType]
                    .runtimeType
                    .toString() ==
                "_InternalLinkedHashMap<String, dynamic>" ||
            widget
                    .course["curriculum"]["structure"]["h"]["sfwd-lessons"]
                        [chapter][lessonType]
                    .runtimeType
                    .toString() ==
                "_Map<String, dynamic>") {
          // ignore: unused_local_variable
          for (String topicId in widget
              .course["curriculum"]["structure"]["h"]["sfwd-lessons"][chapter]
                  [lessonType]
              .keys) {
            total++;
          }
        }
      }
    }
    if (widget.course["curriculum"]["structure"]["h"]["sfwd-lessons"]
                [chapter] !=
            null &&
        (widget
                    .course["curriculum"]["structure"]["h"]["sfwd-lessons"]
                        [chapter]["sfwd-quiz"]
                    .runtimeType
                    .toString() ==
                "_InternalLinkedHashMap<String, dynamic>" ||
            widget
                    .course["curriculum"]["structure"]["h"]["sfwd-lessons"]
                        [chapter]["sfwd-quiz"]
                    .runtimeType
                    .toString() ==
                "_Map<String, dynamic>")) {
      for (String quizId in widget
          .course["curriculum"]["structure"]["h"]["sfwd-lessons"][chapter]
              ["sfwd-quiz"]
          .keys) {
        if (isQuizCompleted(quizId)) {
          completed++;
        }
      }
    }
    if (widget.course["topics"][chapter].runtimeType.toString() ==
            "_InternalLinkedHashMap<String, dynamic>" ||
        widget.course["topics"][chapter].runtimeType.toString() ==
            "_Map<String, dynamic>") {
      for (String stepId in widget.course["topics"][chapter].keys) {
        if (widget.course["topics"][chapter][stepId] == 1) {
          completed++;
        }
      }
    }

    return [completed, total != 0 ? total : 1];
  }

  isQuizCompleted(String quizId) {
    for (Map quiz in widget.course["curriculum"]["lesson_details"]["quizzes"]) {
      if (quiz["id"].toString() == quizId) {
        if (quiz["status"] == 0) {
          return true;
        }
      }
    }
    return false;
  }

  int getLessonIndex(String chapter) {
    int index = 0;
    for (String lesson in widget.course["lessons"].keys) {
      index++;
      if (chapter == lesson) {
        return index;
      }
    }
    return 0;
  }

  int getTopicIndex(String topic, String lesson) {
    int index = 0;
    List<dynamic> topics =
        getLessonTopics(lesson, widget.course["curriculum"]["structure"]["h"]);
    for (String singleTopic in topics) {
      index++;
      if (singleTopic == (topic)) {
        return index;
      }
    }
    return 0;
  }

  Widget buildLesson(String topic, Map curriculum, String chapter,
      {bool showSpace = true}) {
    return GestureDetector(
      onTap: () async {
        EasyLoading.show();
        var box = await Hive.openBox(
          "learndash",
        );
        if (isQuiz(
          curriculum["lesson_details"],
          topic,
        )) {
          var response = await BaseApi.getAsync("learndashapp/v1/get-quizzes",
              queryParams: {
                "course_id": widget.course["id"],
                "lesson_id": int.parse(chapter),
                "user_id": box.get("id")
              },
              requiresPurchaseCode: true);
          EasyLoading.dismiss();
          await Get.to(QuizScreen(widget.course, response, int.parse(topic)));
        } else {
          var response = await BaseApi.getAsync("learndashapp/v1/get-steps",
              queryParams: {
                "course_id": widget.course["id"],
                "lesson_id": int.parse(chapter)
              },
              requiresPurchaseCode: true);
          EasyLoading.dismiss();
          await Get.to(TopicDetails(
              int.parse(topic),
              response,
              widget.course,
              getLessonIndex(chapter),
              getTopicIndex(topic, chapter),
              (getLessonTopics(chapter,
                          widget.course["curriculum"]["structure"]["h"])
                      as List<dynamic>)
                  .length,
              int.parse(chapter)));
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.4), width: 1))),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (showSpace) const SizedBox(width: 40),
                    Icon(
                      isQuiz(
                        curriculum["lesson_details"],
                        topic,
                      )
                          ? Icons.quiz
                          : Icons.menu_book,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        getTopicName(
                          curriculum["lesson_details"],
                          topic,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  if (!isLessonCompleted(topic))
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.grey.withOpacity(0.4),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Constants.secondaryColor),
                          value: 0),
                    ),
                  if (isLessonCompleted(topic))
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Icon(
                        Icons.check_circle,
                        color: Constants.secondaryColor,
                      ),
                    ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  isQuiz(var lessonDetails, var topic) {
    var isQuiz = false;

    for (var quiz in lessonDetails["quizzes"]) {
      if (topic == quiz["id"].toString()) {
        isQuiz = true;
      }
    }
    return isQuiz;
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

  getTopicName(var lessonDetails, var topic) {
    var topicName = "";
    for (var topicI in lessonDetails["topics"]) {
      if (topic == topicI["id"].toString()) {
        topicName = topicI["title"];
      }
    }
    for (var quiz in lessonDetails["quizzes"]) {
      if (topic == quiz["id"].toString()) {
        topicName = quiz["title"];
      }
    }
    return topicName;
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

  Widget courseProgressDetails() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              width: Get.width * 0.45,
              height: 50,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (widget.course["status"] as String)
                          .replaceAll("_", " ")
                          .capitalize!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    if (widget.course["last_activity"] != "" &&
                        widget.course["last_activity"] != null)
                      Text(
                        "Last Activity: ${DateFormat("MMM d, y").format(DateTime.fromMillisecondsSinceEpoch(widget.course["last_activity"] * 1000))}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      )
                  ]),
            ),
            const Spacer(),
            Expanded(
                child: Center(
              child: Row(
                children: [
                  Text(
                    "${(widget.course["total"] != 0) ? ((((widget.course["completed"] as int) / (widget.course["total"] as int)) * 100).toInt().toString()) : "0"}%",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.withOpacity(0.4),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Constants.secondaryColor),
                        value: (widget.course["total"] != 0)
                            ? ((((widget.course["completed"] as int) /
                                    (widget.course["total"] as int)))
                                .toDouble())
                            : 0,
                      ))
                ],
              ),
            ))
          ],
        )
      ],
    );
  }

  double topImageContainerHeight = 250;
  Widget topArea() {
    return Stack(
      children: [
        SizedBox(
          height: topImageContainerHeight,
          width: Get.width,
          child: Column(
            children: [
              (widget.course["image"] != null && widget.course["image"] != "")
                  ? ExtendedImage.network(
                      widget.course["image"],
                      height: topImageContainerHeight,
                      fit: BoxFit.cover,
                    )
                  : ExtendedImage.asset(
                      "assets/coursesPlaceholder.png",
                      height: topImageContainerHeight,
                      fit: BoxFit.cover,
                    ),
            ],
          ),
        ),
        Container(
          height: topImageContainerHeight,
          width: Get.width,
          color: Colors.black.withOpacity(0.3),
        ),
        Container(
          height: topImageContainerHeight,
          padding: const EdgeInsets.all(20),
          width: Get.width,
          child: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Center(
                          child: Icon(Icons.arrow_back_ios, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: SizedBox(
                      width: Get.width * 0.7,
                      child: Text(
                        widget.course["name"],
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: SizedBox(
                      width: Get.width * 0.7,
                      child: Row(children: [
                        if (widget.course["instructor"]["avatar"] != "" &&
                            widget.course["instructor"]["avatar"] != null)
                          ExtendedImage.network(
                            widget.course["instructor"]["avatar"],
                            shape: BoxShape.circle,
                            height: 20,
                            width: 20,
                            fit: BoxFit.cover,
                          ),
                        if (widget.course["instructor"]["avatar"] == "" ||
                            widget.course["instructor"]["avatar"] == null)
                          ExtendedImage.asset(
                            "assets/user.png",
                            shape: BoxShape.circle,
                            height: 20,
                            width: 20,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.course["instructor"]["name"],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          height: 4,
                          width: 4,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          DateFormat("MMMM d, y")
                              .format(DateTime.parse(widget.course["date"])),
                          style: const TextStyle(color: Colors.white),
                        )
                      ]),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
