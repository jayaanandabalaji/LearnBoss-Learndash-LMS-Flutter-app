import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

import 'quiz_results_screen.dart';

class TakeQuizScreen extends StatefulWidget {
  final Map course;
  final List<dynamic> quizResponse;
  final int quizId;

  const TakeQuizScreen(this.course, this.quizResponse, this.quizId, {Key? key})
      : super(key: key);

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  int currentQuestionIndex = 1;
  Map? quiz;
  Map<String, Map<String, dynamic>> finalResponse = {};
  DateTime? startTime;
  DateTime? endTime;
  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    quiz = (widget.quizResponse)
        .firstWhere((element) => element["id"] == widget.quizId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          if (quiz != null)
            SizedBox(
              height: Get.height - Get.statusBarHeight,
              width: Get.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.grey,
                            )),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                        quiz!["questions"][currentQuestionIndex - 1]["_title"],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "Question $currentQuestionIndex",
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      TextSpan(
                          text: " of ${quiz!["questions"].length}",
                          style: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500)),
                    ])),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.secondaryColor),
                      color: const Color(0xffF3F3F3),
                      backgroundColor: const Color(0xffF3F3F3),
                      value: currentQuestionIndex / quiz!["questions"].length,
                    ),
                  ),
                  Expanded(
                      child: Container(
                    color: const Color(0xffFCFBFC),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      children: [
                        Html(
                          data:
                              """${quiz!["questions"][currentQuestionIndex - 1]["_question"]}""",
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "essay")
                          buildEssayQType(),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "single")
                          buildSingleType(),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "multiple")
                          buildMultipleType(),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "free_answer")
                          freeChoiceAnswerType(),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "sort_answer")
                          sortAnswerType(),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "matrix_sort_answer")
                          matrixSortAnswer(),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "cloze_answer")
                          clozeAnswer(),
                        if (quiz!["questions"][currentQuestionIndex - 1]
                                ["_answerType"] ==
                            "assessment_answer")
                          assessmentAnswer()
                      ],
                    ),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (currentQuestionIndex != 1)
                        SizedBox(
                            height: 40,
                            child: Center(
                              child: MaterialButton(
                                  color: Constants.secondaryColor,
                                  textColor: Colors.white,
                                  height: 35,
                                  minWidth: Get.width * 0.4,
                                  onPressed: () {
                                    setState(() {
                                      currentQuestionIndex--;
                                    });
                                    setVariables();
                                  },
                                  child: const Text("Previous")),
                            )),
                      if (currentQuestionIndex == quiz!["questions"].length)
                        SizedBox(
                            height: 40,
                            child: Center(
                              child: MaterialButton(
                                  color: Constants.secondaryColor,
                                  textColor: Colors.white,
                                  height: 35,
                                  minWidth: Get.width * 0.4,
                                  onPressed: () {
                                    submitAllResponses();
                                  },
                                  child: const Text("Submit")),
                            )),
                      if (currentQuestionIndex != quiz!["questions"].length)
                        SizedBox(
                            height: 40,
                            child: Center(
                              child: MaterialButton(
                                  color: Constants.secondaryColor,
                                  textColor: Colors.white,
                                  height: 35,
                                  minWidth: (currentQuestionIndex == 1)
                                      ? Get.width * 0.7
                                      : Get.width * 0.4,
                                  onPressed: () {
                                    setState(() {
                                      currentQuestionIndex++;
                                    });
                                    setVariables();
                                  },
                                  child: const Text("Next")),
                            )),
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    ));
  }

  void submitAllResponses() async {
    EasyLoading.show();

    var response = await BaseApi.postAsync(
        "learndashapp/v1/submit-quiz",
        {
          "quizId": int.parse(quiz!['quiz_pro_id']),
          "quiz": quiz!['id'],
          "course_id": widget.course["id"],
          "responses": finalResponse,
        },
        requiredToken: true);

    EasyLoading.dismiss();
    endTime = DateTime.now();
    Get.off(QuizResultsScreen(jsonDecode(response["data"]), quiz!, startTime!,
        endTime!, widget.course, widget.quizResponse, widget.quizId));
  }

  List<String> getOptions(String options) {
    List<String> returnList = [];
    String optionsStr = options.replaceAll("{", "").replaceAll("}", "").trim();

    RegExp exp = RegExp(r'\[(.*?)\]');
    for (var m in exp.allMatches(optionsStr)) {
      returnList.add(m[0] ?? "");
    }

    return returnList;
  }

  Widget assessmentAnswer() {
    return Column(children: [
      for (List assessment in getMatch())
        Container(
            padding: const EdgeInsets.symmetric(vertical: 3),
            width: Get.width,
            child: Wrap(
              children: [
                for (String text in assessment)
                  Wrap(
                    children: [
                      if ((text.contains("{") && text.contains("}")))
                        for (String option in (getOptions(text)))
                          Container(
                            padding: const EdgeInsets.only(right: 5),
                            child: Wrap(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Radio(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: const VisualDensity(
                                          horizontal:
                                              VisualDensity.minimumDensity,
                                          vertical:
                                              VisualDensity.minimumDensity,
                                        ),
                                        value: option
                                            .replaceAll("[", "")
                                            .replaceAll("]", "")
                                            .trim(),
                                        groupValue: getCurrentResponse(),
                                        onChanged: (dynamic value) {
                                          setCurrentResponse(value);
                                          setState(() {});
                                        }),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(option
                                        .replaceAll("[", "")
                                        .replaceAll("]", "")
                                        .trim()),
                                  ),
                                )
                              ],
                            ),
                          ),
                      if (!(text.contains("{") && text.contains("}")))
                        Text(
                          text,
                          maxLines: 1,
                        )
                    ],
                  )
              ],
            ))
    ]);
  }

  void setVariables() {
    if (quiz!["questions"][currentQuestionIndex - 1]["_answerType"] ==
        "sort_answer") {
      if (getCurrentResponse() == "") {
        Map<String, String> items = {};
        int answerCount =
            quiz!["questions"][currentQuestionIndex - 1]["_answerData"].length;

        List<int> randomAns = [];
        for (int i = 0; i < answerCount; i++) {
          randomAns.add(i);
        }
        randomAns.shuffle();
        for (int i = 0; i < answerCount; i++) {
          items[i.toString()] = quiz!["questions"][currentQuestionIndex - 1]
              ["datapos_array"][randomAns[i]];
        }
        setCurrentResponse(items);

        setState(() {});
      }
    }
    if (quiz!["questions"][currentQuestionIndex - 1]["_answerType"] ==
        "matrix_sort_answer") {
      if (getCurrentResponse() == "") {
        Map<String, dynamic> items = {};
        int answerCount =
            quiz!["questions"][currentQuestionIndex - 1]["_answerData"].length;

        List<int> randomAns = [];
        for (int i = 0; i < answerCount; i++) {
          randomAns.add(i);
        }
        randomAns.shuffle();
        for (int i = 0; i < answerCount; i++) {
          items[i.toString()] = null;
        }
        setCurrentResponse(items);
      }
    }
    if (quiz!["questions"][currentQuestionIndex - 1]["_answerType"] ==
        "cloze_answer") {
      if (getCurrentResponse() == "") {
        Map<String, String> fillUps = {};

        for (int i = 0; i < getFillUps().length; i++) {
          fillUps[i.toString()] = "";
        }
        setCurrentResponse(fillUps);
      }
    }
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  List<String> getFillUps() {
    List<String> fillUps = [];
    String answer = _parseHtmlString(quiz!["questions"]
        [currentQuestionIndex - 1]["_answerData"][0]["_answer"]);
    RegExp exp = RegExp(r'\{(.*?)\}');
    for (var m in exp.allMatches(answer)) {
      fillUps.add(m[0] ?? "");
    }
    return fillUps;
  }

  List<List<String>> getMatch() {
    String answer = _parseHtmlString(quiz!["questions"]
        [currentQuestionIndex - 1]["_answerData"][0]["_answer"]);
    List<String> splitAns = answer.split("\n");
    List<List<String>> finalList = [];
    for (String ans in splitAns) {
      List<String> fillUps = [];

      RegExp exp = RegExp(r'\{(.*?)\}');
      for (var m in exp.allMatches(ans)) {
        fillUps.add(m[0] ?? "");
      }

      List<String> returnList = [];
      for (String fillUp in fillUps) {
        returnList.add(ans.split(fillUp).first);
        returnList.add(fillUp);
        ans = ans.split(fillUp).last;
        if (fillUp == fillUps.last) {
          returnList.add(ans.split(fillUp).last);
        }
      }
      finalList.add(returnList);
    }

    return finalList;
  }

  Widget clozeAnswer() {
    return Text.rich(WidgetSpan(
        child: Column(
      children: [
        for (List singleFillUp in getMatch())
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                for (String fillUp in singleFillUp)
                  Row(
                    children: [
                      if (fillUp.contains("{") && fillUp.contains("}"))
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: getCurrentResponse()[
                                getFillUps().indexOf(fillUp).toString()],
                            onChanged: (String value) {
                              Map response = getCurrentResponse();
                              response[getFillUps()
                                  .indexOf(fillUp)
                                  .toString()] = value;
                              setCurrentResponse(response);
                            },
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10)),
                          ),
                        ),
                      if (!(fillUp.contains("{") && fillUp.contains("}")))
                        Text(fillUp.replaceAll("\n", " ")),
                    ],
                  ),
              ],
            ),
          )
      ],
    )));
  }

  Widget answerWidget(String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Text(answer),
    );
  }

  bool atleastOneNull() {
    bool returnBool = false;
    for (dynamic value in (getCurrentResponse() as Map).values) {
      if (value == null) {
        returnBool = true;
      }
    }
    return returnBool;
  }

  List<String> topColumnAnswers() {
    List<String> dataPosesUsed = [];
    for (dynamic datapos in getCurrentResponse().values) {
      if (datapos != null) {
        dataPosesUsed.add(datapos);
      }
    }
    List<String> dataposesNotSet = [];
    for (String datapos in quiz!["questions"][currentQuestionIndex - 1]
        ["datapos_array"]) {
      if (!dataPosesUsed.contains(datapos)) {
        dataposesNotSet.add(datapos);
      }
    }
    List<String> answersNotUsed = [];
    for (String dataposes in dataposesNotSet) {
      answersNotUsed.add(getAnswerByDataPos(dataposes, isSortString: true));
    }
    return answersNotUsed;
  }

  String getKeyByDataPos(String dataPos) {
    for (String index in (getCurrentResponse() as Map).keys) {
      if (getCurrentResponse()[index] == dataPos) {
        return index;
      }
    }
    return "";
  }

  Widget matrixSortAnswer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (atleastOneNull())
          Wrap(
            children: [
              for (String answer in topColumnAnswers())
                Draggable(
                  data: answer,
                  feedback: answerWidget(answer),
                  childWhenDragging: answerWidget(answer),
                  child: answerWidget(answer),
                )
            ],
          ),
        if (!atleastOneNull())
          SizedBox(
            height: 30,
            width: Get.width,
            child: DragTarget(
              builder: (BuildContext context, List<dynamic> candidateData,
                  List<dynamic> rejectedData) {
                return Container(
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      color: candidateData.isNotEmpty
                          ? Colors.orange
                          : Colors.transparent),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Container(),
                );
              },
              onWillAccept: (data) {
                return true;
              },
              onAccept: (String answer) {
                Map<String, dynamic> response = getCurrentResponse();
                response[getKeyByDataPos(
                    getDataPosByAnswer(answer, isSortString: true))] = null;
                setCurrentResponse(response);
                setState(() {});
              },
            ),
          ),
        const SizedBox(
          height: 30,
        ),
        for (int questionIndex = 0;
            questionIndex <
                quiz!["questions"][currentQuestionIndex - 1]["_answerData"]
                    .length;
            questionIndex++)
          Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 2))),
                    child: Text(
                        quiz!["questions"][currentQuestionIndex - 1]
                            ["_answerData"][questionIndex]["_answer"],
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Expanded(
                    child: DragTarget(
                      builder: (BuildContext context,
                          List<dynamic> candidateData,
                          List<dynamic> rejectedData) {
                        return Container(
                          alignment: Alignment.bottomLeft,
                          decoration: BoxDecoration(
                              color: candidateData.isNotEmpty &&
                                      getCurrentResponse()[
                                              questionIndex.toString()] ==
                                          null
                                  ? Colors.orange
                                  : Colors.transparent),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child:
                              getCurrentResponse()[questionIndex.toString()] !=
                                      null
                                  ? draggableAnswerWidget(questionIndex)
                                  : Container(),
                        );
                      },
                      onWillAccept: (data) {
                        if (getCurrentResponse()[questionIndex.toString()] ==
                            null) {
                          return true;
                        }
                        return false;
                      },
                      onAccept: (String data) {
                        Map currentResponse = getCurrentResponse();
                        for (int i = 0;
                            i < currentResponse.values.toList().length;
                            i++) {
                          if (currentResponse[
                                  currentResponse.keys.toList()[i]] ==
                              getDataPosByAnswer(data, isSortString: true)) {
                            currentResponse[i.toString()] = null;
                          }
                        }
                        currentResponse[questionIndex.toString()] =
                            getDataPosByAnswer(data, isSortString: true);
                        setCurrentResponse(currentResponse);
                        setState(() {});
                      },
                    ),
                  )
                ],
              ))
      ],
    );
  }

  Widget draggableAnswerWidget(int questionIndex) {
    String answer = getAnswerByDataPos(
        getCurrentResponse()[questionIndex.toString()],
        isSortString: true);
    return Align(
        alignment: Alignment.bottomLeft,
        child: Draggable(
          data: answer,
          feedback: answerWidget(answer),
          childWhenDragging: answerWidget(answer),
          child: answerWidget(answer),
        ));
  }

  String getActualKeyOfDatPos(String dataPos) {
    for (int i = 0;
        i <
            quiz!["questions"][currentQuestionIndex - 1]["datapos_array"]
                .length;
        i++) {
      if (dataPos ==
          quiz!["questions"][currentQuestionIndex - 1]["datapos_array"][i]) {
        return i.toString();
      }
    }
    return "";
  }

  String getAnswerByDataPos(String dataPos, {bool isSortString = false}) {
    List<dynamic> dataPosList =
        quiz!["questions"][currentQuestionIndex - 1]["datapos_array"];
    for (int i = 0; i < dataPosList.length; i++) {
      if (dataPosList[i] == dataPos) {
        return quiz!["questions"][currentQuestionIndex - 1]["_answerData"][i]
            [isSortString ? "_sortString" : "_answer"];
      }
    }
    return "";
  }

  String getDataPosByAnswer(String answer, {bool isSortString = false}) {
    List<dynamic> answerList = [];
    for (Map answer in quiz!["questions"][currentQuestionIndex - 1]
        ["_answerData"]) {
      answerList.add(answer[isSortString ? "_sortString" : "_answer"]);
    }
    for (int i = 0; i < answerList.length; i++) {
      if (answerList[i] == answer) {
        return quiz!["questions"][currentQuestionIndex - 1]["datapos_array"][i];
      }
    }
    return "";
  }

  Widget sortAnswerType() {
    return ReorderableListView(
        shrinkWrap: true,
        children: [
          for (String item in (getCurrentResponse() as Map).values)
            Container(
              key: ValueKey(getAnswerByDataPos(item)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  const Icon(Icons.list),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(getAnswerByDataPos(item))
                ],
              ),
            )
        ],
        onReorder: (int oldIndex, int newIndex) {
          List<String> reorderableItems = [];

          for (String item in (getCurrentResponse() as Map).values) {
            reorderableItems.add(getAnswerByDataPos(item));
          }
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          String items = reorderableItems.removeAt(oldIndex);
          reorderableItems.insert(newIndex, items);

          Map<String, String> responseMap = {};
          for (int i = 0; i < reorderableItems.length; i++) {
            responseMap[i.toString()] = getDataPosByAnswer(reorderableItems[i]);
          }
          setCurrentResponse(responseMap);
          setState(() {});
        });
  }

  Widget freeChoiceAnswerType() {
    return TextFormField(
      initialValue: getCurrentResponse(),
      onChanged: (String value) {
        setCurrentResponse(value);
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget buildMultipleType() {
    return Column(
      children: [
        for (Map answer in quiz!["questions"][currentQuestionIndex - 1]
            ["_answerData"])
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 5,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(10)),
            child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(answer["_answer"]),
                value: getCurrentResponse() == ""
                    ? false
                    : getCurrentResponse()[getIndex(answer["_answer"])],
                onChanged: (bool? value) {
                  if (value != null) {
                    Map currentResponse = getCurrentResponse() == ""
                        ? {
                            for (int i = 0;
                                i <
                                    quiz!["questions"][currentQuestionIndex - 1]
                                            ["_answerData"]
                                        .length;
                                i++)
                              i.toString(): false
                          }
                        : getCurrentResponse();
                    currentResponse[getIndex(answer["_answer"])] = value;
                    setCurrentResponse(currentResponse);
                    setState(() {});
                  }
                }),
          )
      ],
    );
  }

  Widget buildSingleType() {
    return Column(
      children: [
        for (Map answer in quiz!["questions"][currentQuestionIndex - 1]
            ["_answerData"])
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 5,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(10)),
            child: RadioListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(answer["_answer"]),
                value: (answer["_answer"]),
                groupValue: getCurrentRadioButtonSelected(answer["_answer"]),
                onChanged: (dynamic value) {
                  Map currentResponse = getCurrentResponse() == ""
                      ? {
                          for (int i = 0;
                              i <
                                  quiz!["questions"][currentQuestionIndex - 1]
                                          ["_answerData"]
                                      .length;
                              i++)
                            i.toString(): false
                        }
                      : getCurrentResponse();
                  currentResponse[getIndex(value)] = true;
                  for (int i = 0;
                      i <
                          quiz!["questions"][currentQuestionIndex - 1]
                                  ["_answerData"]
                              .length;
                      i++) {
                    if (i.toString() != getIndex(value)) {
                      currentResponse[i.toString()] = false;
                    }
                  }
                  setCurrentResponse(currentResponse);
                  setState(() {});
                }),
          )
      ],
    );
  }

  getCurrentRadioButtonSelected(String answer) {
    if (getCurrentResponse() == "") {
      return null;
    }
    if (getCurrentResponse()[getIndex(answer)]) {
      return answer;
    }
    return null;
  }

  String getIndex(String value) {
    for (int i = 0;
        i < quiz!["questions"][currentQuestionIndex - 1]["_answerData"].length;
        i++) {
      if (quiz!["questions"][currentQuestionIndex - 1]["_answerData"][i]
              ["_answer"] ==
          value) {
        return i.toString();
      }
    }
    return "";
  }

  setCurrentResponse(var value) {
    finalResponse[
        quiz!["questions"][currentQuestionIndex - 1]["_id"].toString()] = {
      "response": value,
      "question_pro_id": quiz!["questions"][currentQuestionIndex - 1]["_id"],
      "question_post_id": quiz!["questions"][currentQuestionIndex - 1]
          ["question_post_id"]
    };
  }

  getCurrentResponse() {
    if (finalResponse[
            quiz!["questions"][currentQuestionIndex - 1]["_id"].toString()] ==
        null) {
      return "";
    }
    return finalResponse[quiz!["questions"][currentQuestionIndex - 1]["_id"]
        .toString()]!["response"];
  }

  Widget buildEssayQType() {
    return Column(
      children: [
        TextFormField(
          initialValue: getCurrentResponse(),
          onChanged: (String value) {
            setCurrentResponse(value);
          },
          decoration: const InputDecoration(
              hintText: "Type your response here",
              border: OutlineInputBorder()),
          minLines: 5,
          maxLines: 10,
        ),
        const SizedBox(
          height: 5,
        ),
        const Text(
          "This response will be reviewed and graded after submission.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        )
      ],
    );
  }
}
