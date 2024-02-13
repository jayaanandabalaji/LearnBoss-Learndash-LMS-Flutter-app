import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:learndash/screens/take_quiz_screen.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

class QuizScreen extends StatefulWidget {
  final Map course;
  final List<dynamic> quizResponse;
  final int quizId;
  const QuizScreen(this.course, this.quizResponse, this.quizId, {Key? key})
      : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
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
                      /* Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                                onTap: () async {
                                  /* if (getLessonIndex() != 1) {
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
                                  }*/
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xffECEEF1),
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 5),
                                  child: Text(
                                    "Prev",
                                    style: TextStyle(
                                        color: Constants.secondaryColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )),
                            SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  /*if (getLessonIndex() !=
                                      widget.lessonsResponse.keys
                                          .toList()
                                          .length) {
                                    await Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) => LessonDetails(
                                                int.parse(
                                                    ((widget.course["topics"]
                                                                as Map)
                                                            .keys
                                                            .toList())[
                                                        getLessonIndex()]),
                                                widget.lessonsResponse,
                                                widget.course)));
                                    setState(() {});
                                  }*/
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xffECEEF1),
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: EdgeInsets.symmetric(
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
                        )*/
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
                        const Text(
                          "Quiz",
                          style: TextStyle(color: Colors.grey),
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
                      ],
                    ),
                  )
                ],
              )),
              if (widget.quizResponse[getQuizid()]["status"] == "notcompleted")
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
                          await BaseApi.postAsync(
                              "learndashapp/v1/start-quiz",
                              {
                                "quizId": (widget.quizResponse[getQuizid()]
                                    ["id"]),
                                "course_id": widget.course["id"]
                              },
                              requiredToken: true);
                          EasyLoading.dismiss();
                          Get.to(TakeQuizScreen(widget.course,
                              widget.quizResponse, widget.quizId));
                        },
                        child: const Text("Start Quiz"),
                      ),
                    ),
                  ),
                ),
              /*if (widget.lessonsResponse[(getLessonIndex()).toString()]
                      ["status"] ==
                  "completed")
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                )*/
            ]),
      )),
    );
  }

  int getQuizid() {
    for (int i = 0; i < widget.quizResponse.length; i++) {
      if (widget.quizResponse[i]["id"] == widget.quizId) {
        return i;
      }
    }
    return 0;
  }

  getPostMeta(String key) {
    for (Map<String, dynamic> lesson in widget.quizResponse) {
      if (lesson["id"] == widget.quizId) {
        return lesson["post"][key];
      }
    }
  }
}
