import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_api.dart';
import 'package:learndash/utils/Constants.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmpasswordVisible = false;
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController password = TextEditingController();
  bool acceptChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: username,
                validator: (text) {
                  if (text != null && text.isEmpty) {
                    return "This field is required";
                  }
                  if (text!.length < 6) {
                    return "Username must be atleast 6 characters";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'username',
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Constants.primaryColor, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: email,
                validator: (text) {
                  if (text != null && text.isEmpty) {
                    return "This field is required";
                  }
                  if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(text ?? "")) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
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
              TextFormField(
                controller: password,
                validator: (text) {
                  if (text != null && text.isEmpty) {
                    return "This field is required";
                  }
                  if (text!.length < 6) {
                    return "Password must be atleast 6 characters";
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                autofocus: false,
                obscureText:
                    !_passwordVisible, //This will obscure text dynamically
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Constants.primaryColor, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: confirmPassword,
                validator: (text) {
                  if (text != null && text.isEmpty) {
                    return "This field is required";
                  }
                  if (password.text != confirmPassword.text) {
                    return "Doesn't match with password field";
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                autofocus: false,
                obscureText:
                    !_confirmpasswordVisible, //This will obscure text dynamically
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _confirmpasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        _confirmpasswordVisible = !_confirmpasswordVisible;
                      });
                    },
                  ),
                  labelText: 'Confirm password',
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Constants.primaryColor, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Checkbox(
                      value: acceptChecked,
                      onChanged: (checked) {
                        setState(() {
                          acceptChecked = checked ?? false;
                        });
                      }),
                  const Text("I accept the terms and privacy policy",
                      style: TextStyle(fontSize: 16))
                ],
              ),
              const SizedBox(height: 10),
              MaterialButton(
                elevation: 0,
                onPressed: () async {
                  if (_formKey.currentState!.validate() && acceptChecked) {
                    EasyLoading.show();
                    var response = await AuthApi.register(
                        username.text, password.text, email.text);
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
                      var box = await Hive.openBox(
                        "learndash",
                      );
                      box.put("token", response["data"]["token"]);
                      box.put("email", response["data"]["user_email"]);
                      box.put("name", response["data"]["user_display_name"]);
                      box.put("avatar", response["data"]["avatar"]);
                      box.put("id", response["data"]["id"]);
                      await Get.deleteAll(force: true);
                      Phoenix.rebirth(Get.context!);
                      Get.reset();
                    }
                  }
                },
                color: (acceptChecked) ? Constants.primaryColor : Colors.grey,
                textColor: Colors.white,
                minWidth: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "Sign Up",
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
