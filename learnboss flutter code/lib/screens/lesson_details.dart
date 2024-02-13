import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:learndash/screens/quiz_screen.dart';
import 'package:learndash/screens/topic_details.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

class LessonDetails extends StatefulWidget {
  final int lessonId;
  final Map<String, dynamic> lessonsResponse;
  const LessonDetails(this.lessonId, this.lessonsResponse, this.course,
      {Key? key})
      : super(key: key);
  final Map course;
  @override
  State<LessonDetails> createState() => _LessonDetailsState();
}

class _LessonDetailsState extends State<LessonDetails> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back_ios,
                              color: Constants.secondaryColor)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                              onTap: () async {
                                if (getLessonIndex() != 1) {
                                  await Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => LessonDetails(
                                              int.parse(
                                                  ((widget.course["topics"]
                                                              as Map)
                                                          .keys
                                                          .toList())[
                                                      getLessonIndex() - 2]),
                                              widget.lessonsResponse,
                                              widget.course)));
                                  setState(() {});
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xffECEEF1),
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 5),
                                child: Text(
                                  "Prev",
                                  style: TextStyle(
                                      color: Constants.secondaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              )),
                          const SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                              onTap: () async {
                                if (getLessonIndex() !=
                                    widget.lessonsResponse.keys
                                        .toList()
                                        .length) {
                                  await Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => LessonDetails(
                                              int.parse(((widget
                                                      .course["topics"] as Map)
                                                  .keys
                                                  .toList())[getLessonIndex()]),
                                              widget.lessonsResponse,
                                              widget.course)));
                                  setState(() {});
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xffECEEF1),
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 5),
                                child: Text(
                                  "Next",
                                  style: TextStyle(
                                      color: Constants.secondaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ))
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getPostMeta("post_title"),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Lesson ${getLessonIndex()} of ${widget.lessonsResponse.keys.toList().length}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                  child: ListView(
                children: [
                  Container(
                    color: const Color(0xffF6F6F8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        if (getPostMeta("post_content") != "")
                          Container(
                            color: Colors.white,
                            child: Html(
                              data: """${getPostMeta("post_content")}""",
                            ),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        if ((widget.course["topics"].runtimeType.toString() ==
                                    "_InternalLinkedHashMap<String, dynamic>" ||
                                widget.course["topics"].runtimeType
                                        .toString() ==
                                    "_Map<String, dynamic>") &&
                            (widget.course["topics"][widget.lessonId.toString()]
                                        .runtimeType
                                        .toString() ==
                                    "_InternalLinkedHashMap<String, dynamic>" ||
                                widget
                                        .course["topics"]
                                            [widget.lessonId.toString()]
                                        .runtimeType
                                        .toString() ==
                                    "_Map<String, dynamic>") &&
                            (widget.course["topics"][widget.lessonId.toString()]
                                    as Map)
                                .keys
                                .isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Lesson Content",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color:
                                            Color.fromARGB(20, 149, 157, 165),
                                        blurRadius: 24.0,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(children: [
                                    for (String topic in getLessonTopics(
                                        widget.lessonId.toString(),
                                        widget.course["curriculum"]["structure"]
                                            ["h"]))
                                      buildLesson(
                                          topic, widget.course["curriculum"],
                                          showSpace: false)
                                  ]),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  )
                ],
              )),
              if (widget.lessonsResponse[(getLessonIndex()).toString()]
                      ["status"] !=
                  "completed")
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: MaterialButton(
                        height: 40,
                        minWidth: Get.width * 0.8,
                        color: Constants.primaryColor,
                        textColor: Colors.white,
                        onPressed: () async {
                          EasyLoading.show();
                          await BaseApi.getAsync(
                              "learndashapp/v1/complete-lesson?id=${widget.lessonId}",
                              requiredToken: true);
                          EasyLoading.dismiss();
                          widget.lessonsResponse[(getLessonIndex()).toString()]
                              ["status"] = "completed";
                          widget.course["lessons"][widget.lessonId.toString()] =
                              1;
                          setState(() {});
                        },
                        child: const Text("Mark as complete"),
                      ),
                    ),
                  ),
                ),
              if (widget.lessonsResponse[(getLessonIndex()).toString()]
                      ["status"] ==
                  "completed")
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Completed",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                )
            ]),
      )),
    );
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

  Widget buildLesson(String topic, Map curriculum, {bool showSpace = true}) {
    return GestureDetector(
      onTap: () async {
        if (isQuiz(
          curriculum["lesson_details"],
          topic,
        )) {
          EasyLoading.show();

          var box = await Hive.openBox(
            "learndash",
          );

          var response = await BaseApi.getAsync("learndashapp/v1/get-quizzes",
              queryParams: {
                "course_id": widget.course["id"],
                "lesson_id": (widget.lessonId),
                "user_id": box.get("id")
              },
              requiresPurchaseCode: true);
          EasyLoading.dismiss();
          await Get.to(QuizScreen(widget.course, response, int.parse(topic)));
        } else {
          EasyLoading.show();
          var response = await BaseApi.getAsync("learndashapp/v1/get-steps",
              queryParams: {
                "course_id": widget.course["id"],
                "lesson_id": widget.lessonId
              },
              requiresPurchaseCode: true);
          EasyLoading.dismiss();

          await Get.to(TopicDetails(
              int.parse(topic),
              response,
              widget.course,
              getLessonIndex(),
              getTopicIndex(topic, widget.lessonId.toString()),
              (getLessonTopics(widget.lessonId.toString(),
                          widget.course["curriculum"]["structure"]["h"])
                      as List<dynamic>)
                  .length,
              widget.lessonId));
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

  bool isQuizCompleted(String quizId) {
    for (Map quiz in widget.course["curriculum"]["lesson_details"]["quizzes"]) {
      if (quiz["id"].toString() == quizId) {
        if (quiz["status"] == 0) {
          return true;
        }
      }
    }
    return false;
  }

  bool isQuiz(var lessonDetails, var topic) {
    bool isQuiz = false;

    for (var quiz in lessonDetails["quizzes"]) {
      if (topic == quiz["id"].toString()) {
        isQuiz = true;
      }
    }
    return isQuiz;
  }

  getLessonIndex() {
    int index = 0;
    for (String lesson in widget.lessonsResponse.keys) {
      index++;
      if (widget.lessonsResponse[lesson]!["id"] == widget.lessonId) {
        return index;
      }
    }
  }

  getPostMeta(String key) {
    for (String lesson in widget.lessonsResponse.keys) {
      if (widget.lessonsResponse[lesson]!["id"] == widget.lessonId) {
        return widget.lessonsResponse[lesson]!["post"][key];
      }
    }
  }
}
