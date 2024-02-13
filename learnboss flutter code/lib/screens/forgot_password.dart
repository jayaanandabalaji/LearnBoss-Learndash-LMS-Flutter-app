import 'package:html/parser.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_api.dart';
import 'package:learndash/utils/Constants.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController login = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        centerTitle: true,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: login,
                validator: (text) {
                  if (text != null && text.isEmpty) {
                    return "This field is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Constants.primaryColor, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                elevation: 0,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    EasyLoading.show();
                    var response = await AuthApi.resetPassword(login.text);
                    EasyLoading.dismiss();
                    if (!response["success"]) {
                      Get.defaultDialog(
                          title: "Error",
                          middleText: _parseHtmlString(jsonDecode(
                              response["data"].toString())["message"]),
                          textConfirm: "ok",
                          cancelTextColor: Constants.primaryColor,
                          confirmTextColor: Colors.white,
                          buttonColor: Constants.primaryColor,
                          onConfirm: () {
                            Get.back();
                          });
                    } else {
                      Get.defaultDialog(
                          title: "Success",
                          middleText:
                              "Password reset link sent to your mail ID successfully",
                          textConfirm: "ok",
                          cancelTextColor: Constants.primaryColor,
                          confirmTextColor: Colors.white,
                          buttonColor: Constants.primaryColor,
                          onConfirm: () {
                            Get.back();
                          });
                    }
                  }
                },
                color: Constants.primaryColor,
                textColor: Colors.white,
                minWidth: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "Reset password",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}
