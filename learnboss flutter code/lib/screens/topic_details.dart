import 'dart:ui';

import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:get/get.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

import 'html_widget.dart';

class TopicDetails extends StatefulWidget {
  final Map course;
  final Map<String, dynamic> topicsResponse;
  final int lessonId;
  final int lessonIndex;
  final int topicIndex;
  final int totalTopics;
  final int topicId;

  const TopicDetails(this.topicId, this.topicsResponse, this.course,
      this.lessonIndex, this.topicIndex, this.totalTopics, this.lessonId,
      {Key? key})
      : super(key: key);

  @override
  State<TopicDetails> createState() => _TopicDetailsState();
}

class _TopicDetailsState extends State<TopicDetails> {
  @override
  void initState() {
    super.initState();
    checkIfQuiz();
  }

  checkIfQuiz() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: mainWidget(),
    );
  }

  final HtmlWidgetController _htmlController = Get.put(HtmlWidgetController());

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();

    for (MeeduPlayerController controller
        in _htmlController.videoPlayerControllers.values) {
      controller.pause();
    }
    for (ChewieAudioController controller
        in _htmlController.audioPlayerControllers.values) {
      controller.pause();
    }
  }

  Widget mainWidget() {
    return Scaffold(
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
                            onTap: () {
                              if (widget.topicIndex != 1 &&
                                  getTopicIndex(false) != 0) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => TopicDetails(
                                            getTopicIndex(false),
                                            widget.topicsResponse,
                                            widget.course,
                                            widget.lessonIndex,
                                            widget.topicIndex - 1,
                                            widget.totalTopics,
                                            widget.lessonId)));
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
                            onTap: () {
                              if (widget.topicIndex != widget.totalTopics &&
                                  getTopicIndex(true) != 0) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => TopicDetails(
                                            getTopicIndex(true),
                                            widget.topicsResponse,
                                            widget.course,
                                            widget.lessonIndex,
                                            widget.topicIndex + 1,
                                            widget.totalTopics,
                                            widget.lessonId)));
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
                      Row(
                        children: [
                          Text(
                            "Lesson ${widget.lessonIndex}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Container(
                            height: 3,
                            width: 3,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "Topic ${widget.topicIndex}",
                            style: const TextStyle(color: Colors.grey),
                          )
                        ],
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
                          child: HtmlWidget(getPostMeta("post_content")),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )
              ],
            )),
            if (!isLessonCompleted(widget.topicId.toString()))
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
                            "learndashapp/v1/complete-lesson?id=${widget.topicId}",
                            requiredToken: true);
                        EasyLoading.dismiss();
                        widget.course["topics"][widget.lessonId.toString()]
                            [widget.topicId.toString()] = 1;
                        setState(() {});
                      },
                      child: const Text("Mark as complete"),
                    ),
                  ),
                ),
              ),
            if (isLessonCompleted(widget.topicId.toString()))
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
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
                ),
              )
          ]),
    ));
  }

  int getTopicIndex(bool isNext) {
    for (String lesson in widget.course["topics"].keys) {
      for (String topic in widget.course["topics"][lesson].keys) {
        if (topic == widget.topicId.toString()) {
          if (isNext) {
            if (topic !=
                (widget.course["topics"][lesson] as Map).keys.toList().last) {
              return int.parse(((widget.course["topics"][lesson] as Map)
                  .keys
                  .toList())[(widget.course["topics"][lesson] as Map)
                      .keys
                      .toList()
                      .indexOf(topic) +
                  (isNext ? 1 : 0) -
                  (isNext ? 0 : 1)]);
            }
          } else {
            if (topic !=
                (widget.course["topics"][lesson] as Map).keys.toList().first) {
              return int.parse(((widget.course["topics"][lesson] as Map)
                  .keys
                  .toList())[(widget.course["topics"][lesson] as Map)
                      .keys
                      .toList()
                      .indexOf(topic) +
                  (isNext ? 1 : 0) -
                  (isNext ? 0 : 1)]);
            }
          }
        }
      }
    }
    return 0;
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

  isQuiz(var lessonDetails, var topic) {
    var isQuiz = false;

    for (var quiz in lessonDetails["quizzes"]) {
      if (topic == quiz["id"].toString()) {
        isQuiz = true;
      }
    }
    return isQuiz;
  }

  getPostMeta(String key) {
    for (String lesson in widget.topicsResponse.keys) {
      if (widget.topicsResponse[lesson]!["ID"] == widget.topicId) {
        return widget.topicsResponse[lesson][key];
      }
    }
  }
}
