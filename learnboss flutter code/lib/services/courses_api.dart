import 'package:hive/hive.dart';
import 'package:learndash/models/courses.dart';

import 'base_api.dart';

class CoursesApi {
  getCourse(
      {int? category, String? search, List<int>? id, int pageId = 1}) async {
    Box box = await Hive.openBox(
      "learndash",
    );
    String token = box.get("token", defaultValue: "");
    List response = [];
    if (category != null) {
      response = await BaseApi.getAsync("learndashapp/v1/courses",
          requiredToken: token != "" ? true : false,
          queryParams: {
            "category": category,
            "posts_per_page": 10,
            "offset": pageId
          });
    } else if (search != null) {
      response = await BaseApi.getAsync("learndashapp/v1/courses",
          requiredToken: token != "" ? true : false,
          queryParams: {
            "search": search,
            "posts_per_page": 10,
            "offset": pageId
          });
    } else if (id != null) {
      response = await BaseApi.getAsync("learndashapp/v1/courses",
          requiredToken: token != "" ? true : false,
          queryParams: {
            "id": getCSVFromList(id),
            "posts_per_page": 10,
            "offset": pageId
          });
    } else {
      response = await BaseApi.getAsync("learndashapp/v1/courses",
          queryParams: {"posts_per_page": 10, "offset": pageId},
          requiredToken: token != "" ? true : false);
    }

    response = response.map((course) {
      return Course.fromJson(course);
    }).toList();
    return response as List<Course>;
  }

  getCSVFromList(List<int> list) {
    String output = "";
    for (int id in list) {
      if (id != list.last) {
        output += "$id,";
      } else {
        output += id.toString();
      }
    }
    return output;
  }
}
