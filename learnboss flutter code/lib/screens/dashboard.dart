import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../controllers/cart_controller.dart';
import 'package:learndash/controllers/wishlist_controller.dart';
import 'package:learndash/screens/resources.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learndash/controllers/settings_controller.dart';
import 'package:learndash/models/courses.dart';
import '../services/base_api.dart';
import '../services/courses_api.dart';
import 'package:learndash/utils/Constants.dart';
import 'package:shimmer/shimmer.dart';

import 'cart_screen.dart';
import 'category_courses.dart';
import 'course_details.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var _courses;
  final SettingsController settingsController = Get.put(SettingsController());
  final WishlistController wishlistController = Get.put(WishlistController());
  final CartController cartController = Get.put(CartController());

  List<dynamic>? _categories;
  @override
  void initState() {
    super.initState();
    CoursesApi().getCourse().then((var response) {
      setState(() {
        _courses = response as List<Course>;
      });
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    getCategories();
    getTopCategories();
    wishlistController.initWishlistedCourses();
    cartController.initcartCourses();
  }

  Map<int, dynamic> topCategories = {};

  getTopCategories() async {
    for (Map category in settingsController.settings["featured_category"]) {
      getSingleTopCategory(category);
    }
  }

  getSingleTopCategory(Map category) async {
    var response = await CoursesApi().getCourse(category: category["term_id"]);
    topCategories[category["term_id"]] = response;
    setState(() {});
  }

  getCategories() async {
    var response = await BaseApi.getAsync("learndashapp/v1/get-categories");
    _categories = response;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            "assets/logo.png",
            width: 150,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(const CartScreen());
                },
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.black,
                ))
          ],
        ),
        body: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            buildHomeBanner(),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTitle("Latest Courses"),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(const CategoryCourses(
                          isAllCourses: true,
                        ));
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Constants.primaryColor),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            (_courses == null)
                ? coursesShimmer()
                : SizedBox(
                    height: 280,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (Course course in _courses) courseGrid(course)
                      ],
                    ),
                  ),
            buildTitle("Top Categories"),
            if (_categories != null)
              SizedBox(
                height: 110,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [buildCategoriesList()],
                ),
              ),
            for (Map category
                in settingsController.settings["featured_category"])
              buildTopCoursesIn(category),
            if (Constants.resourcesSection.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTitle("Resources"),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 220,
                      child: ListView(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: [
                            if (Constants.resourcesSection.contains("blogs"))
                              resourceGrid("blogs"),
                            if (Constants.resourcesSection.contains("others"))
                              resourceGrid("others", initialIndex: 2)
                          ])),
                  const SizedBox(height: 20),
                  Center(
                      child: MaterialButton(
                    onPressed: () {
                      Get.to(const ResourcesScreen());
                    },
                    child: Container(
                        height: 45,
                        width: Get.width * 0.8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Constants.primaryColor,
                              width: 1,
                            )),
                        child: Center(
                          child: Text('View all resources',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Constants.primaryColor)),
                        )),
                  )),
                  const SizedBox(height: 20),
                ],
              ),
          ],
        ));
  }

  Map resourceDetails = {
    "blogs": {
      "color": [const Color(0xff1973D1), const Color(0xff135CC5)],
      "name": "Articles".tr,
      "description": "for comprehensive learning experience".tr
    },
    "others": {
      "color": [const Color(0xff2EB62C), const Color(0xff57C84D)],
      "name": "Other resources".tr,
      "description": "pdf documents, images, Zip or any downloadable files".tr
    }
  };

  Widget resourceGrid(String resource, {int initialIndex = 0}) {
    return InkWell(
      onTap: () {
        if (resource == "blogs") {
          Get.to(const ResourcesScreen(initalIndex: 0));
        } else {
          Get.to(const ResourcesScreen(initalIndex: 1));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        width: Get.width * 0.75,
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: resourceDetails[resource]["color"]),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: SizedBox(
                    width: Get.width * 0.75,
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.elliptical(Get.width * 0.35, 75),
                            bottomRight:
                                Radius.elliptical(Get.width * 0.65, 150)),
                        child: Image.asset("assets/$resource.jpg",
                            fit: BoxFit.cover)))),
            Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 0, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resourceDetails[resource]["name"],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 23)),
                    Text(resourceDetails[resource]["description"],
                        style: const TextStyle(color: Colors.white))
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget buildTopCoursesIn(Map category) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTitle("Top courses in ${category["name"]}"),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(CategoryCourses(
                        category: category,
                      ));
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          (topCategories[category["term_id"]] == null)
              ? coursesShimmer()
              : SizedBox(
                  height: 240,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (Course course in topCategories[category["term_id"]])
                        smallCoursesGrid(course)
                    ],
                  ),
                ),
        ]);
  }

  Widget buildHomeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CarouselSlider(
        items: [
          for (Map carousel in settingsController.settings["banner"])
            singleCarouelImage(carousel)
        ],
        options: CarouselOptions(
          height: 200.0,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 6),
          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          enlargeFactor: 0.3,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  getCourseAndNavigate(String courseId) async {
    EasyLoading.show();
    var response = await CoursesApi().getCourse(id: [int.parse(courseId)]);
    EasyLoading.dismiss();
    Get.to(CourseDetails(response[0]));
  }

  Widget singleCarouelImage(Map carousel) {
    return InkWell(
      onTap: () async {
        if (carousel["onTap"] == "1") {
          await launchUrl(Uri.parse(carousel["value"]));
        }
        if (carousel["onTap"] == "2") {
          Map? findCat;
          for (Map category in _categories!) {
            if (category["term_id"].toString() == carousel["value"]) {
              findCat = category;
            }
          }
          if (findCat != null) {
            Get.to(CategoryCourses(
              category: findCat,
            ));
          }
        }
        if (carousel["onTap"] == "3") {
          getCourseAndNavigate(carousel["value"]);
        }
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ExtendedImage.network(
              carousel["image"],
              cache: true,
              height: 200,
              width: Get.width,
              fit: BoxFit.cover,
            ),
          ),
          if (carousel["label"] != null && carousel["label"] != "")
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(carousel["label"],
                    style: const TextStyle(color: Colors.white)),
              ),
            )
        ],
      ),
    );
  }

  Widget buildCategoriesList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < (_categories!.length / 2).ceil(); i++)
              buildCategory(_categories![i])
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i =
                    _categories!.length - (_categories!.length / 2).ceil() - 1;
                i >= 0;
                i--)
              buildCategory(_categories![_categories!.length - i - 1])
          ],
        )
      ],
    );
  }

  Widget buildCategory(Map category) {
    return InkWell(
      onTap: () {
        Get.to(CategoryCourses(
          category: category,
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.blueAccent.withOpacity(0.1)),
        child: Row(
          children: [
            if (category["icon"] != "" && category["icon"] != null)
              ExtendedImage.network(
                category["icon"],
                height: 15,
                width: 15,
                fit: BoxFit.contain,
              ),
            const SizedBox(
              width: 10,
            ),
            Text(
              category["name"],
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget coursesShimmer() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.white,
        child: SizedBox(
          height: 300,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              for (int i = 0; i < 10; i++)
                Container(
                    height: 300,
                    width: 280,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              "assets/placeholder.png",
                              height: 150,
                              width: 280,
                              fit: BoxFit.cover,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.grey.shade500,
                                height: 20,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                color: Colors.grey.shade500,
                                height: 10,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                color: Colors.grey.shade500,
                                height: 10,
                              ),
                            ],
                          ),
                        )
                      ],
                    ))
            ],
          ),
        ));
  }

  Widget smallCoursesGrid(Course course) {
    return Container(
        height: 220,
        width: 200,
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CourseDetails(course)));
          },
          child: Column(
            children: [
              (course.image != "")
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        course.image,
                        height: 115,
                        width: 200,
                        fit: BoxFit.cover,
                      ))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/coursesPlaceholder.png",
                        height: 115,
                        width: 200,
                        fit: BoxFit.cover,
                      )),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      course.instructor["name"],
                      style: TextStyle(
                          color: Constants.secondaryColor, fontSize: 13),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      (course.price == "")
                          ? "Free"
                          : Constants.currency + course.price,
                      style: TextStyle(
                          color: (course.price == "")
                              ? Colors.green
                              : Constants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget courseGrid(Course course) {
    return Container(
        height: 300,
        width: 280,
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CourseDetails(course)));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (course.image != "")
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        course.image,
                        height: 150,
                        width: 280,
                        fit: BoxFit.cover,
                      ))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/coursesPlaceholder.png",
                        height: 150,
                        width: 280,
                        fit: BoxFit.cover,
                      )),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      course.instructor["name"],
                      style: TextStyle(
                          color: Constants.secondaryColor, fontSize: 13),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      (course.price == "")
                          ? "Free"
                          : Constants.currency + course.price,
                      style: TextStyle(
                          color: (course.price == "")
                              ? Colors.green
                              : Constants.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget buildTitle(String text) {
    return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ));
  }
}
