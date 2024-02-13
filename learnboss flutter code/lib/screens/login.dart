import 'package:extended_image/extended_image.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learndash/screens/register.dart';
import '../services/auth_api.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  void initState() {
    super.initState();
    signinWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
                controller: password,
                validator: (text) {
                  if (text != null && text.isEmpty) {
                    return "This field is required";
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
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ForgotPassScreen()));
                  },
                  child: Text("Forgot Password",
                      style: TextStyle(
                          color: Constants.primaryColor,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                elevation: 0,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    EasyLoading.show();
                    var response =
                        await AuthApi.login(username.text, password.text);
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
                color: Constants.primaryColor,
                textColor: Colors.white,
                minWidth: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                elevation: 0,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegisterScreen()));
                },
                color: Colors.grey.shade200,
                textColor: Constants.primaryColor,
                minWidth: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 18),
              const Text("Or",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 18),
              googleSignInButton()
            ],
          ),
        )
      ]),
    );
  }

  void signinWithGoogle() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      if (account != null) {
        EasyLoading.show();
        var response = await BaseApi.postAsync(
            "jwt-auth/v1/social-login",
            {
              "email": account.email,
              "accessToken": account.id,
              "loginType": "google"
            },
            requiresPurchaseCode: true);
        EasyLoading.dismiss();
        if (response["success"]) {
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
    });
  }

  Widget googleSignInButton() {
    return InkWell(
      onTap: () async {
        await _googleSignIn.signIn();
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(20, 149, 157, 165),
                blurRadius: 24.0,
                offset: Offset(0, 8),
              ),
            ],
            color: const Color(0xff4285F4),
          ),
          height: 50,
          width: Get.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: ExtendedImage.asset(
                  'assets/google.png',
                  height: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text("SIGN IN WITH GOOGLE",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )),
    );
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}
