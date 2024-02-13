import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../services/base_api.dart';
import 'package:learndash/utils/Constants.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
    profile!["oldPass"] = "";
    profile!["newPass"] = "";
    profile!["confirmNewPass"] = "";
    EasyLoading.dismiss();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Setting"),
            bottom: const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(
                    text: "Profile",
                  ),
                  Tab(
                    text: "Reset Password",
                  )
                ]),
          ),
          body: TabBarView(children: [
            if (profile != null)
              SizedBox(
                height: Get.height,
                width: Get.width,
                child: editProfile(),
              ),
            if (profile == null) Container(),
            SizedBox(
              height: Get.height,
              width: Get.width,
              child: resetPassword(),
            )
          ])),
    );
  }

  Widget resetPassword() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reset Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    textBoxField("Current Password", "oldPass"),
                    textBoxField("New Password", "newPass"),
                    textBoxField("Confirm New Password", "confirmNewPass"),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
            height: Get.height * 0.1,
            child: Center(
              child: MaterialButton(
                color: Constants.primaryColor,
                textColor: Colors.white,
                minWidth: Get.width * 0.8,
                height: 40,
                onPressed: () {
                  if (profile != null &&
                      profile!["newPass"] != null &&
                      profile!["confirmNewPass"] != null &&
                      profile!["oldPass"] != null &&
                      profile!["newPass"] != "" &&
                      profile!["confirmNewPass"] != "" &&
                      profile!["oldPass"] != "") {
                    if (profile!["newPass"] != profile!["confirmNewPass"]) {
                      showSnackBar("password and confirm password must match");
                    } else {
                      doresetPassword(profile!["oldPass"], profile!["newPass"]);
                    }
                  } else {
                    showSnackBar("Fill all fields.");
                  }
                },
                child: const Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ))
      ],
    );
  }

  doresetPassword(String oldPass, String newPass) async {
    EasyLoading.show();
    var response = await BaseApi.postAsync("learndashapp/v1/update-password",
        {"oldPass": oldPass, "newPass": newPass},
        requiredToken: true);
    showSnackBar(response["data"]);
    EasyLoading.dismiss();
  }

  showSnackBar(String message) {
    Get.showSnackbar(GetSnackBar(
      duration: const Duration(seconds: 1),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ));
  }

  Widget editProfile() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Contact Information",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Provide your details below to create your account profile",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    textBoxField("First Name", "first_name"),
                    textBoxField("Last Name", "last_name"),
                    textBoxField("Phone Number", "phone"),
                    textBoxField("Bio", "bio", minlines: 7),
                    textBoxField("Twitter", "twitter"),
                    textBoxField("Facebook", "facebook"),
                    textBoxField("Instagram", "instagram"),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
            height: Get.height * 0.1,
            child: Center(
              child: MaterialButton(
                color: Constants.primaryColor,
                textColor: Colors.white,
                minWidth: Get.width * 0.8,
                height: 40,
                onPressed: () async {
                  EasyLoading.show();
                  await BaseApi.postAsync(
                      "learndashapp/v1/update-profile", profile ?? {},
                      requiredToken: true);
                  EasyLoading.dismiss();
                  Get.showSnackbar(const GetSnackBar(
                    duration: Duration(seconds: 2),
                    messageText: Text("Profile Updated Successfully",
                        style: TextStyle(color: Colors.white)),
                  ));
                },
                child: const Text(
                  "Update Profile",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ))
      ],
    );
  }

  Widget textBoxField(String text, String profileMapKey, {int? minlines}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15,
        ),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          onChanged: (String value) {
            if ((profile ?? {})[profileMapKey] != null) {
              profile![profileMapKey] = value;
            }
          },
          initialValue: (profile ?? {})[profileMapKey] ?? "",
          minLines: minlines,
          maxLines: minlines != null ? 10 : null,
          decoration: InputDecoration(
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              fillColor: Colors.grey.withOpacity(0.12),
              disabledBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              border: const OutlineInputBorder()),
        )
      ],
    );
  }
}
