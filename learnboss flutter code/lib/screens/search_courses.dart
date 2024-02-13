import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../services/base_api.dart';

import 'category_courses.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> categories = [];
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  getCategories() async {
    EasyLoading.show();
    var response = await BaseApi.getAsync("learndashapp/v1/get-categories");
    categories = response;
    EasyLoading.dismiss();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          TextField(
            textInputAction: TextInputAction.search,
            onSubmitted: (String value) {
              Get.to(CategoryCourses(
                search: value,
              ));
            },
            decoration: InputDecoration(
                hintText: "Search",
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                enabledBorder: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                fillColor: Colors.grey.withOpacity(0.15),
                filled: true),
          ),
          const SizedBox(
            height: 5,
          ),
          Image.asset("assets/courses.jpg", height: 200),
          const SizedBox(height: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Discover Courses",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: Get.width * 0.7,
                child: const Text(
                  "Try discovering new courses with search or browse out categories",
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          const Text("Browse Categories",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 15),
          Column(
            children: [
              for (Map category in categories) singleCategory(category)
            ],
          )
        ],
      ),
    );
  }

  Widget singleCategory(Map category) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: InkWell(
        onTap: () {
          Get.to(CategoryCourses(
            category: category,
          ));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (category["icon"] != "")
                  ExtendedImage.network(
                    category["icon"],
                    height: 30,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                if (category["icon"] == "")
                  Container(
                    width: 20,
                  ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  category["name"],
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.navigate_next_outlined,
                  color: Colors.grey,
                ))
          ],
        ),
      ),
    );
  }
}
