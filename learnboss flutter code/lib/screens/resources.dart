import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import '../services/base_api.dart';

import '../models/blogs.dart';
import 'blog_details.dart';

class ResourcesScreen extends StatefulWidget {
  final int initalIndex;
  const ResourcesScreen({Key? key, this.initalIndex = 0}) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  int page = 1;
  var unescape = HtmlUnescape();
  List blogsList = [];
  List othersList = [];
  @override
  void initState() {
    super.initState();
    initBlogs();
    initOthers();
  }

  initOthers() async {
    var response = await BaseApi.getAsync(
        "wp/v2/app-resources?_embed&per_page=10&page=$page");
    othersList = response.map((value) => Blogs.fromJson(value)).toList();
    setState(() {});
  }

  initBlogs() async {
    var response =
        await BaseApi.getAsync("wp/v2/posts?_embed&per_page=10&page=$page");
    blogsList = response.map((value) => Blogs.fromJson(value)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        initialIndex: widget.initalIndex,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Resources".tr),
            bottom: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Blogs".tr),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("others".tr),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              (blogsList.isNotEmpty)
                  ? ListView(
                      children: [for (Blogs blog in blogsList) buildBlog(blog)],
                    )
                  : const Center(child: CircularProgressIndicator()),
              (othersList.isNotEmpty)
                  ? ListView(
                      children: [
                        for (Blogs blog in othersList)
                          buildBlog(blog, isOthers: true)
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ],
          ),
        ));
  }

  Widget buildBlog(Blogs blog, {bool isOthers = false}) {
    return InkWell(
      onTap: () {
        Get.to(BlogDetail(
          blog: blog,
          isOthers: isOthers,
        ));
      },
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Expanded(
            flex: 65,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unescape.convert(blog.title.rendered),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ((blog.embedded["author"] != null)
                            ? blog.embedded["author"][0]["name"]
                                .replaceAll("@gmail.com", "")
                            : "") +
                        " . " +
                        blog.modified.substring(0, 10),
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  )
                ]),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 35,
            child: (blog.embedded["wp:featuredmedia"] != null &&
                    blog.embedded["wp:featuredmedia"][0]["source_url"] != null)
                ? ExtendedImage.network(
                    blog.embedded["wp:featuredmedia"][0]["source_url"],
                    height: 80,
                    fit: BoxFit.cover)
                : ExtendedImage.asset("assets/placeholder.jpg",
                    height: 80, fit: BoxFit.cover),
          )
        ]),
      ),
    );
  }
}
