import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import '../services/base_api.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Map? profile;

  getProfileData() async {
    EasyLoading.show();
    var response = await BaseApi.getAsync("learndashapp/v1/my-profile",
        requiredToken: true);
    profile = response;
    EasyLoading.dismiss();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          if (profile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(20, 149, 157, 165),
                    blurRadius: 24.0,
                    offset: Offset(0, 8),
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  detailsWidget("Register Date",
                      "${DateFormat('yMMMEd').format(DateTime.parse(profile!["user_registered"]))}, ${DateFormat('jms').format(DateTime.parse(profile!["user_registered"]))}"),
                  detailsWidget("First Name", profile!["first_name"]),
                  detailsWidget("Last Name", profile!["last_name"]),
                  detailsWidget("Username", profile!["user_login"]),
                  detailsWidget("Email", profile!["user_email"]),
                  detailsWidget("Bio", profile!["bio"])
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget detailsWidget(String text1, String text2) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (text1 == "") ? "-" : text1,
          style: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text2,
          style: const TextStyle(),
        ),
        const SizedBox(
          height: 18,
        )
      ],
    );
  }
}
