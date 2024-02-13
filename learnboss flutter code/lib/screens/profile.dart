import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learndash/screens/login.dart';
import 'package:learndash/screens/setting.dart';
import 'package:learndash/utils/Constants.dart';

import 'dashboard_screen.dart';
import 'my_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    if (Hive.box("learndash").get("token") == null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                (Hive.box("learndash").get("avatar") == null)
                    ? Image.asset(
                        "assets/user.png",
                        height: 70,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: Image.network(
                            Hive.box("learndash").get("avatar"),
                            height: 70,
                            width: 70),
                      ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Hive.box("learndash").get("name") != null)
                      Text(
                        Hive.box("learndash").get("name"),
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(const SettingScreen());
                      },
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Constants.secondaryColor),
                      ),
                    ),
                  ],
                ),
              ])),
          const SizedBox(
            height: 20,
          ),
          buildSingleRow("Dashboard", Icons.dashboard_outlined, () {
            Get.to(const AnalyticsScreen());
          }),
          buildSingleRow("My Profile", Icons.account_circle_outlined, () {
            Get.to(const MyProfile());
          }),
          buildSingleRow("Quiz Attempts", Icons.quiz_outlined, () {}),
          buildSingleRow("Purchase History", Icons.history_outlined, () {}),
          buildSingleRow("Logout", Icons.logout, () {
            Get.defaultDialog(
                title: "Confirm",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Ok",
                textCancel: "cancel",
                buttonColor: Constants.secondaryColor,
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  await Hive.box("learndash").clear();
                  Get.back();
                  await Get.deleteAll(force: true);
                  Phoenix.rebirth(Get.context!);
                  Get.reset();
                });
          }),
        ],
      ),
    );
  }

  Widget buildSingleRow(String name, IconData icon, Function onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 1, color: Colors.grey.shade300))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              Icon(
                icon,
                color: Constants.secondaryColor,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                name,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800),
              ),
            ],
          ),
          const FaIcon(
            FontAwesomeIcons.angleRight,
            color: Colors.grey,
          )
        ]),
      ),
    );
  }
}
