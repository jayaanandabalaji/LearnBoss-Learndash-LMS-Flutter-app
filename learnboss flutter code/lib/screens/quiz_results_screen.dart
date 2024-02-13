import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:learndash/screens/take_quiz_screen.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

class QuizResultsScreen extends StatefulWidget {
  final Map<String, dynamic> quizResultResponse;
  final DateTime startTime;
  final DateTime endTime;
  final Map course;
  final List<dynamic> quizResponse;
  final int quizId;
  const QuizResultsScreen(this.quizResultResponse, this.quiz, this.startTime,
      this.endTime, this.course, this.quizResponse, this.quizId,
      {Key? key})
      : super(key: key);
  final Map quiz;

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back_ios,
                          color: Constants.secondaryColor)),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 150.0,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              color: Colors.green,
                              backgroundColor: Colors.grey.withOpacity(0.5),
                              strokeWidth: 6,
                              value: getTotalCorrectAnsweredQuestions() /
                                  widget.quiz["questions"].length,
                            ),
                          ),
                        ),
                        Center(
                            child: Text(
                          "${(getTotalCorrectAnsweredQuestions() / widget.quiz["questions"].length * 100).toInt()}%",
                          style: const TextStyle(fontSize: 25),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Center(
                  child: SizedBox(
                width: Get.width * 0.6,
                child: Text(
                  "${getTotalCorrectAnsweredQuestions()} of ${widget.quiz["questions"].length} questions answered correctly.",
                  style: const TextStyle(),
                  textAlign: TextAlign.center,
                ),
              )),
              const SizedBox(
                height: 25,
              ),
              Center(
                child: Container(
                  height: 1,
                  width: Get.width * 0.7,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Points",
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          "${getPoints()[0].toInt()}/${getPoints()[1].toInt()}",
                          style: const TextStyle(fontSize: 20))
                    ]),
              ),
              const SizedBox(
                height: 25,
              ),
              Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Your Time",
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          formatTime(widget.endTime
                              .difference(widget.startTime)
                              .inSeconds),
                          style: const TextStyle(fontSize: 20))
                    ]),
              ),
              const SizedBox(
                height: 45,
              ),
              Center(
                child: MaterialButton(
                  onPressed: () async {
                    EasyLoading.show();
                    await BaseApi.postAsync(
                        "learndashapp/v1/start-quiz",
                        {
                          "quizId": widget.quiz["id"],
                          "course_id": widget.course["id"]
                        },
                        requiredToken: true);
                    EasyLoading.dismiss();
                    Get.off(TakeQuizScreen(
                        widget.course, widget.quizResponse, widget.quizId));
                  },
                  child: Container(
                    width: Get.width * 0.5,
                    decoration: BoxDecoration(
                        color: Constants.primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: const Center(
                      child: Text(
                        "Take Again",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  List<num> getPoints() {
    List<num> response = [0, 0];
    for (Map question in widget.quiz["questions"]) {
      if (widget.quizResultResponse[question["_id"].toString()] != null) {
        response[0] +=
            widget.quizResultResponse[question["_id"].toString()]["p"];
      }
      response[1] += question["_points"];
    }
    return response;
  }

  int getTotalCorrectAnsweredQuestions() {
    int i = 0;
    for (String questionId in widget.quizResultResponse.keys) {
      if (widget.quizResultResponse[questionId]["c"]) {
        i++;
      }
    }
    return i;
  }
}
