import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:learndash/utils/Constants.dart';

class BaseApi {
  static getAsync(String endpoint,
      {bool requiredToken = false,
      Map<String, dynamic>? queryParams,
      bool requiresPurchaseCode = false}) async {
    var dio = Dio();
    if (requiredToken) {
      Box box = await Hive.openBox(
        "learndash",
      );
      String token = box.get("token");
      dio.options.headers["Authorization"] = "Bearer $token";
    }
    if (requiresPurchaseCode) {
      dio.options.headers["Authorization"] = "Bearer ${Constants.purchaseCode}";
    }
    Response response = await dio.get(
        '${Constants.baseUrl}/?rest_route=/${endpoint.replaceAll("?", "&")}',
        queryParameters: queryParams);
    return response.data;
  }

  static postAsync(String endpoint, Map params,
      {bool requiredToken = false, bool requiresPurchaseCode = false}) async {
    var dio = Dio();
    Response response;
    try {
      if (requiredToken) {
        Box box = await Hive.openBox(
          "learndash",
        );
        String token = box.get("token");
        dio.options.headers["Authorization"] = "Bearer $token";
      }
      if (requiresPurchaseCode) {
        dio.options.headers["Authorization"] =
            "Bearer ${Constants.purchaseCode}";
      }
      response = await dio.post(
          '${Constants.baseUrl}/?rest_route=/${endpoint.replaceAll("?", "&")}',
          data: params);
      return {"success": true, "data": response.data};
    } on DioError catch (e) {
      return {"success": false, "data": e.response};
    }
  }
}
